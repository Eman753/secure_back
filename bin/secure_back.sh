#!/bin/bash

DATEHOUR=$(date +%Y-%m-%d-%Hh%M)

DIR="/var/local/secure_back"

#echo $DATEHOUR

if ! test -d $DIR
then
	mkdir $DIR
	if ! test -d $DIR/tmp
	then
		mkdir $DIR/tmp
	fi

	if ! test -d $DIR/backups
	then
		mkdir $DIR/backups
	fi
	touch $DIR/example.txt
	echo "Hello world ! Thanks using secure_back !" > $DIR/example.txt
fi

if [ $# -eq 0 ]
then
	echo "Cette commande doit être appelée avec le service secure_back !"
	echo "Préférez l'utilisation de : systemctl start secure_back.service"
	exit
fi

if [ $1 = "start" ]
then
	# Archivage de tous les répertoires à sauvegarder
	tar cvf $DIR/tmp/host_$DATEHOUR.tar $DIR/example.txt 2> /var/log/secure_back_error_$DATEHOUR
	# Copie de l'archive créée dans le répertoire tmp dans celui des backups
	cp $DIR/tmp/host_$DATEHOUR.tar $DIR/backups/ 2>> /var/log/secure_back_error_$DATEHOUR
	# Compression maximale sur l'archive afin de gagner en espace disque
	gzip -9 $DIR/backups/host_$DATEHOUR.tar 2>> /var/log/secure_back_error_$DATEHOUR
	# Supression de l'archive initiale
	rm $DIR/tmp/host_$DATEHOUR.tar 2>> /var/log/secure_back_error_$DATEHOUR

	# On teste ensuite si l'archive existe (preuve de la sauvegarde) ; on ne prend pas en compte la copie et la compression du fait que ce soit une optimisation"
	if test -f $DIR/backups/host_$DATEHOUR.tar
	then
		echo "La sauvegarde du "$DATEHOUR" a bien été effectuée" >> /var/log/secure_back_$DATEHOUR
	else
		echo "Une erreur est survenue dans la sauvegarde du "$DATEHOUR >> /var/log/secure_back_$DATEHOUR
	fi
else
	echo "" > /dev/null
fi

if [ $1 = "stop" ]
then
	if `pgrep 'tar cvf $DIR'` -ne "" || `pgrep 'cp $DIR'` -ne ""
	then
		echo "Un processus de sauvegarde est actuellement en cours ! Forcer l'arrêt avec condstop" >> /var/log/secure_back_error_$DATEHOUR
	else
		echo "Arrêt du service secure_back le "$DATEHOUR >> /var/log/secure_back_$DATEHOUR
	fi
else
	echo "" > /dev/null
fi

if [ $1 = "condstop" ]
then
	echo "Arrêt de force de secure_back à "$DATEHOUR" !" >> /var/log/secure_back_error_$DATEHOUR
	skill secure_back.sh
else
	echo "" > /dev/null
fi

