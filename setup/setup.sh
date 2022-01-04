#!/bin/bash

CONFIG=/etc/secure_back

echo "Bienvenue sur l'utilitaire d'installation et de configuration de secure_back !"
if ! $UID = 0
then
    echo "Ce programme doit être lancé en superutilisateur :("
    exit
fi

if [ $# -eq 0 ]
then
    echo "Veuillez utiliser une des options du script setup.sh !"
    echo "SYNOPSIS : setup.sh -[option]"
    echo "-i : installation (ou réinstallation) de secure_back"
    echo "-c : configuration de secure_back"
    echo "-u : désinstallation de secure_back"
    exit 22
fi

if [ $1 -eq "-i"]
then
    # Mise en place du fichier de configuration de secure_back
    mkdir $CONFIG
    echo "# Config file for secure_back" > $CONFIG/secure_back.config
    echo "# DO NOT MAKE ANY CHANGES. USE SETUP.SH FROM THE INSTALLATION PACKAGE TO MODIFY THIS FILE" >> $CONFIG/secure_back.config
    
    read -p "Où souhaitez-vous que les backups soit stockées ?" FILES
    echo "Les backups seront stockées dans $FILES/backups"
    echo "$FILES" >> $CONFIG/secure_back.config
    
    # On met les services en place
    echo "Mise en place des services secure_back.service et secure_back.timer"
    cp ../systemd/* /etc/systemd/system
    systemctl enable secure_back.service
    systemctl enable secure_back.timer

    echo "Fin de l'installation !"
fi