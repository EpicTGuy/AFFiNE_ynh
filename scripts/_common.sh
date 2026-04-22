#!/bin/bash
# Variables partagées — structure de l'image Docker extraite dans $install_dir :
#
#   $install_dir/usr/local/bin/node  → Node.js 22 (inclus dans l'image)
#   $install_dir/app/                → répertoire de travail de l'app
#   $install_dir/app/dist/main.js    → point d'entrée du serveur
#   $install_dir/app/scripts/        → scripts de migration
#
# Données persistantes dans $data_dir :
#   $data_dir/config/private.key     → clé privée générée au 1er lancement
#   $data_dir/storage/               → uploads utilisateurs

nodejs_bin="$install_dir/usr/local/bin/node"
app_dir="$install_dir/app"
# yarn est bundlé dans l'image Docker — on l'expose via PATH pour self-host-predeploy.js
export PATH="$install_dir/usr/local/bin:$PATH"
