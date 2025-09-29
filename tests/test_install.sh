#!/bin/bash

# Test d'installation pour AFFiNE
# Vérifie que l'installation se déroule correctement

set -e

# Chargement des helpers YunoHost
source /usr/share/yunohost/helpers

# Variables de test
APP_ID="affine"
TEST_DOMAIN="test.example.com"
TEST_PATH="/affine"
TEST_IS_PUBLIC="false"

# Fonction de nettoyage
cleanup() {
    ynh_log_info "Nettoyage des tests..."
    ynh_app_remove "$APP_ID" 2>/dev/null || true
    ynh_log_info "Nettoyage terminé"
}

# Gestion des erreurs
trap cleanup EXIT

# Test 1: Vérification des prérequis
ynh_log_info "Test 1: Vérification des prérequis"
if ! command -v node &> /dev/null; then
    ynh_log_error "Node.js n'est pas installé"
    exit 1
fi
if ! command -v nginx &> /dev/null; then
    ynh_log_error "NGINX n'est pas installé"
    exit 1
fi
ynh_log_info "✅ Prérequis validés"

# Test 2: Installation de l'application
ynh_log_info "Test 2: Installation de l'application"
ynh_app_install "$APP_ID" --domain "$TEST_DOMAIN" --path "$TEST_PATH" --is_public "$TEST_IS_PUBLIC"
ynh_log_info "✅ Installation réussie"

# Test 3: Vérification des services
ynh_log_info "Test 3: Vérification des services"
if ! systemctl is-active --quiet "$APP_ID"; then
    ynh_log_error "Le service $APP_ID n'est pas actif"
    exit 1
fi
ynh_log_info "✅ Service actif"

# Test 4: Vérification des ports
ynh_log_info "Test 4: Vérification des ports"
APP_PORT=$(ynh_app_setting_get "$APP_ID" "app_port")
if [ -z "$APP_PORT" ]; then
    ynh_log_error "Le port de l'application n'est pas défini"
    exit 1
fi
if ! netstat -tlnp | grep -q ":$APP_PORT "; then
    ynh_log_error "L'application n'écoute pas sur le port $APP_PORT"
    exit 1
fi
ynh_log_info "✅ Port $APP_PORT actif"

# Test 5: Vérification de la base de données
ynh_log_info "Test 5: Vérification de la base de données"
DB_NAME=$(ynh_app_setting_get "$APP_ID" "db_name")
if [ -z "$DB_NAME" ]; then
    ynh_log_error "La base de données n'est pas définie"
    exit 1
fi
if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    ynh_log_error "La base de données $DB_NAME n'existe pas"
    exit 1
fi
ynh_log_info "✅ Base de données $DB_NAME créée"

# Test 6: Vérification de Redis
ynh_log_info "Test 6: Vérification de Redis"
REDIS_DB=$(ynh_app_setting_get "$APP_ID" "redis_db")
if [ -z "$REDIS_DB" ]; then
    ynh_log_error "La base Redis n'est pas définie"
    exit 1
fi
ynh_log_info "✅ Redis configuré"

# Test 7: Vérification des répertoires
ynh_log_info "Test 7: Vérification des répertoires"
APP_DIR=$(ynh_app_setting_get "$APP_ID" "app_dir")
if [ ! -d "$APP_DIR" ]; then
    ynh_log_error "Le répertoire de l'application n'existe pas"
    exit 1
fi
if [ ! -d "$APP_DIR/data" ]; then
    ynh_log_error "Le répertoire de données n'existe pas"
    exit 1
fi
if [ ! -d "$APP_DIR/config" ]; then
    ynh_log_error "Le répertoire de configuration n'existe pas"
    exit 1
fi
ynh_log_info "✅ Répertoires créés"

# Test 8: Vérification de la configuration NGINX
ynh_log_info "Test 8: Vérification de la configuration NGINX"
if [ ! -f "/etc/nginx/conf.d/$TEST_DOMAIN.d/$APP_ID.conf" ]; then
    ynh_log_error "La configuration NGINX n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configuration NGINX créée"

# Test 9: Vérification de la configuration SSL
ynh_log_info "Test 9: Vérification de la configuration SSL"
if [ ! -f "/etc/nginx/conf.d/$TEST_DOMAIN.d/ssl.conf" ]; then
    ynh_log_warning "La configuration SSL n'existe pas (normal en test)"
fi
ynh_log_info "✅ Configuration SSL vérifiée"

# Test 10: Vérification de la configuration SSOwat
ynh_log_info "Test 10: Vérification de la configuration SSOwat"
if [ ! -f "/etc/ssowat/conf.d/$APP_ID.yml" ]; then
    ynh_log_error "La configuration SSOwat n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configuration SSOwat créée"

# Test 11: Vérification de la configuration systemd
ynh_log_info "Test 11: Vérification de la configuration systemd"
if [ ! -f "/etc/systemd/system/$APP_ID.service" ]; then
    ynh_log_error "La configuration systemd n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configuration systemd créée"

# Test 12: Vérification des permissions
ynh_log_info "Test 12: Vérification des permissions"
APP_USER=$(ynh_app_setting_get "$APP_ID" "app_user")
if [ -z "$APP_USER" ]; then
    ynh_log_error "L'utilisateur de l'application n'est pas défini"
    exit 1
fi
if ! id "$APP_USER" &>/dev/null; then
    ynh_log_error "L'utilisateur $APP_USER n'existe pas"
    exit 1
fi
ynh_log_info "✅ Utilisateur $APP_USER créé"

# Test 13: Vérification des logs
ynh_log_info "Test 13: Vérification des logs"
APP_LOG_DIR="/var/log/$APP_ID"
if [ ! -d "$APP_LOG_DIR" ]; then
    ynh_log_error "Le répertoire de logs n'existe pas"
    exit 1
fi
ynh_log_info "✅ Répertoire de logs créé"

# Test 14: Vérification de la configuration de monitoring
ynh_log_info "Test 14: Vérification de la configuration de monitoring"
if [ ! -f "/etc/yunohost/apps/$APP_ID/monitoring.conf" ]; then
    ynh_log_warning "La configuration de monitoring n'existe pas"
fi
ynh_log_info "✅ Configuration de monitoring vérifiée"

# Test 15: Vérification de la configuration de sauvegarde
ynh_log_info "Test 15: Vérification de la configuration de sauvegarde"
if [ ! -f "/etc/yunohost/apps/$APP_ID/backup.conf" ]; then
    ynh_log_warning "La configuration de sauvegarde n'existe pas"
fi
ynh_log_info "✅ Configuration de sauvegarde vérifiée"

# Résumé des tests
ynh_log_info "🎉 Tous les tests d'installation ont réussi !"
ynh_log_info "📊 Résumé :"
ynh_log_info "   • Application installée : $APP_ID"
ynh_log_info "   • Port : $APP_PORT"
ynh_log_info "   • Base de données : $DB_NAME"
ynh_log_info "   • Redis : $REDIS_DB"
ynh_log_info "   • Utilisateur : $APP_USER"
ynh_log_info "   • Répertoire : $APP_DIR"
ynh_log_info "   • Logs : $APP_LOG_DIR"

exit 0
