#!/bin/bash

# Script d'installation du service systemd pour AFFiNE
# Utilise les helpers YunoHost v2.1

set -e

# Chargement des helpers YunoHost
source /usr/share/yunohost/helpers

# Variables de configuration
APP_ID="affine"
APP_USER="affine"
APP_GROUP="affine"
APP_DIR="/var/www/$APP_ID"
APP_PORT="3000"
NODE_VERSION="18"

# Fonction de nettoyage en cas d'erreur
cleanup_on_error() {
    ynh_clean_setup
    exit 1
}

# Gestion des erreurs
trap cleanup_on_error ERR

# 1) Installation du service systemd
ynh_script_progression "Installation du service systemd..." 0 100

# Récupération de la version Node.js installée
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | sed 's/v//')
    ynh_log_info "Version Node.js détectée : $NODE_VERSION"
else
    ynh_log_error "Node.js n'est pas installé"
    exit 1
fi

# Remplacement des placeholders dans le fichier de service
ynh_log_info "Configuration du service systemd..."
sed -i "s/__APP__/$APP_USER/g" "conf/systemd/affine.service"
sed -i "s/__VERSION__/$NODE_VERSION/g" "conf/systemd/affine.service"

# Installation du service
ynh_add_systemd_config "$APP_ID" "$APP_USER" "$APP_GROUP" "$APP_DIR" "$APP_PORT"

ynh_script_progression "Service systemd installé" 25 100

# 2) Activation du service
ynh_script_progression "Activation du service..." 50 100

ynh_systemd_action --service_name="$APP_ID" --action=enable

ynh_log_info "Service $APP_ID activé"

# 3) Démarrage du service
ynh_script_progression "Démarrage du service..." 75 100

ynh_systemd_action --service_name="$APP_ID" --action=start

ynh_log_info "Service $APP_ID démarré"

# 4) Vérification du statut
ynh_script_progression "Vérification du statut..." 90 100

# Attendre que le service soit prêt
sleep 5

# Vérification du statut
if systemctl is-active --quiet "$APP_ID"; then
    ynh_log_info "✅ Service $APP_ID est actif"
else
    ynh_log_error "❌ Service $APP_ID n'est pas actif"
    systemctl status "$APP_ID" --no-pager
    exit 1
fi

# Vérification des logs
ynh_log_info "Vérification des logs..."
if journalctl -u "$APP_ID" --no-pager -n 10 | grep -q "error\|Error\|ERROR"; then
    ynh_log_warning "⚠️  Des erreurs détectées dans les logs"
    journalctl -u "$APP_ID" --no-pager -n 20
else
    ynh_log_info "✅ Aucune erreur dans les logs"
fi

# 5) Healthcheck
ynh_script_progression "Healthcheck..." 95 100

# Attendre que l'application soit prête
sleep 10

# Healthcheck local
ynh_log_info "Test de santé local..."
if curl -f "http://127.0.0.1:$APP_PORT/health" > /dev/null 2>&1; then
    ynh_log_info "✅ Healthcheck local réussi"
else
    ynh_log_warning "⚠️  Healthcheck local échoué, vérification des logs..."
    journalctl -u "$APP_ID" --no-pager -n 20
fi

# Test de l'application principale
if curl -f "http://127.0.0.1:$APP_PORT/" > /dev/null 2>&1; then
    ynh_log_info "✅ Application accessible localement"
else
    ynh_log_warning "⚠️  Application non accessible localement"
fi

# Finalisation
ynh_script_progression "Installation terminée !" 100 100

# Enregistrement des paramètres
ynh_app_setting_set "$APP_ID" "systemd_installed" "true"
ynh_app_setting_set "$APP_ID" "systemd_status" "active"
ynh_app_setting_set "$APP_ID" "node_version" "$NODE_VERSION"
ynh_app_setting_set "$APP_ID" "service_port" "$APP_PORT"

# Message de fin
echo ""
echo "🎉 Service systemd AFFiNE installé avec succès !"
echo ""
echo "📊 Informations du service :"
echo "   • Service : $APP_ID"
echo "   • Utilisateur : $APP_USER"
echo "   • Port : $APP_PORT"
echo "   • Version Node.js : $NODE_VERSION"
echo "   • Statut : $(systemctl is-active $APP_ID)"
echo ""
echo "🔧 Gestion du service :"
echo "   • Démarrer : systemctl start $APP_ID"
echo "   • Arrêter : systemctl stop $APP_ID"
echo "   • Redémarrer : systemctl restart $APP_ID"
echo "   • Statut : systemctl status $APP_ID"
echo "   • Logs : journalctl -u $APP_ID -f"
echo ""
echo "✅ Installation terminée !"
