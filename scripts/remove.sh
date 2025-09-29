#!/bin/bash

# Script de test de désinstallation propre pour AFFiNE YunoHost
# Teste la désinstallation complète sans résidus (vhost/unit)
# Compatible CI - non-interactif

set -e

# Configuration
APP_ID="affine"
TEST_DOMAIN="${TEST_DOMAIN:-test.example.com}"
TEST_PATH="${TEST_PATH:-/affine}"
TEST_IS_PUBLIC="${TEST_IS_PUBLIC:-false}"
TIMEOUT="${TIMEOUT:-300}"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions de logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction de nettoyage
cleanup() {
    log_info "Nettoyage en cours..."
    ynh_app_remove "$APP_ID" 2>/dev/null || true
    log_info "Nettoyage terminé"
}

# Gestion des erreurs
trap cleanup EXIT

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérification de YunoHost
    if ! command -v yunohost &> /dev/null; then
        log_error "YunoHost n'est pas installé"
        exit 1
    fi
    
    log_success "Prérequis validés"
}

# Installation de l'application
install_app() {
    log_info "Installation de l'application AFFiNE..."
    
    if ! ynh_app_install "$APP_ID" \
        --domain "$TEST_DOMAIN" \
        --path "$TEST_PATH" \
        --is_public "$TEST_IS_PUBLIC"; then
        log_error "Échec de l'installation de l'application"
        exit 1
    fi
    
    log_success "Application installée avec succès"
}

# Test de fonctionnement initial
test_initial_functionality() {
    log_info "Test de fonctionnement initial..."
    
    # Vérification que le service est actif
    if ! systemctl is-active --quiet "$APP_ID"; then
        log_error "Le service n'est pas actif"
        exit 1
    fi
    
    # Test de connectivité locale
    local port=$(ynh_app_setting_get "$APP_ID" "app_port")
    if [ -z "$port" ]; then
        log_error "Port de l'application non défini"
        exit 1
    fi
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f "http://127.0.0.1:$port/health" > /dev/null 2>&1; then
            log_success "Service accessible localement"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "Service non accessible localement"
            exit 1
        else
            log_warning "Tentative $attempt/$max_attempts..."
            sleep 2
            attempt=$((attempt + 1))
        fi
    done
    
    # Test de l'URL publique
    local public_url="https://$TEST_DOMAIN$TEST_PATH"
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        local http_status=$(curl -s -o /dev/null -w "%{http_code}" "$public_url" || echo "000")
        
        if [ "$http_status" = "200" ]; then
            log_success "URL publique accessible (HTTP 200 OK)"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "URL publique non accessible (HTTP $http_status)"
            exit 1
        else
            log_warning "Code HTTP $http_status (tentative $attempt/$max_attempts)"
            sleep 5
            attempt=$((attempt + 1))
        fi
    done
}

# Enregistrement de l'état avant désinstallation
record_pre_removal_state() {
    log_info "Enregistrement de l'état avant désinstallation..."
    
    # Enregistrement des paramètres de l'application
    local app_port=$(ynh_app_setting_get "$APP_ID" "app_port")
    local app_user=$(ynh_app_setting_get "$APP_ID" "app_user")
    local app_group=$(ynh_app_setting_get "$APP_ID" "app_group")
    local app_dir=$(ynh_app_setting_get "$APP_ID" "app_dir")
    local db_name=$(ynh_app_setting_get "$APP_ID" "db_name")
    local redis_db=$(ynh_app_setting_get "$APP_ID" "redis_db")
    
    # Sauvegarde des informations dans des fichiers temporaires
    echo "$app_port" > /tmp/pre_removal_port.txt
    echo "$app_user" > /tmp/pre_removal_user.txt
    echo "$app_group" > /tmp/pre_removal_group.txt
    echo "$app_dir" > /tmp/pre_removal_dir.txt
    echo "$db_name" > /tmp/pre_removal_db.txt
    echo "$redis_db" > /tmp/pre_removal_redis.txt
    
    # Enregistrement des fichiers de configuration
    local nginx_config="/etc/nginx/conf.d/$TEST_DOMAIN.d/$APP_ID.conf"
    local systemd_config="/etc/systemd/system/$APP_ID.service"
    local ssowat_config="/etc/ssowat/conf.d/$APP_ID.yml"
    
    if [ -f "$nginx_config" ]; then
        cp "$nginx_config" /tmp/pre_removal_nginx.conf
    fi
    
    if [ -f "$systemd_config" ]; then
        cp "$systemd_config" /tmp/pre_removal_systemd.service
    fi
    
    if [ -f "$ssowat_config" ]; then
        cp "$ssowat_config" /tmp/pre_removal_ssowat.yml
    fi
    
    log_success "État avant désinstallation enregistré"
}

# Désinstallation de l'application
uninstall_app() {
    log_info "Désinstallation de l'application..."
    
    if ! ynh_app_remove "$APP_ID"; then
        log_error "Échec de la désinstallation de l'application"
        exit 1
    fi
    
    log_success "Application désinstallée avec succès"
}

# Vérification de la suppression du service
verify_service_removal() {
    log_info "Vérification de la suppression du service..."
    
    # Vérification que le service n'est plus actif
    if systemctl is-active --quiet "$APP_ID" 2>/dev/null; then
        log_error "Le service est encore actif après désinstallation"
        exit 1
    fi
    
    # Vérification que le service n'est plus dans la liste des services
    if systemctl list-units --type=service | grep -q "$APP_ID"; then
        log_error "Le service est encore dans la liste des services"
        exit 1
    fi
    
    # Vérification que le service n'est plus dans la liste des services activés
    if systemctl list-unit-files --type=service | grep -q "$APP_ID"; then
        log_error "Le service est encore dans la liste des services activés"
        exit 1
    fi
    
    log_success "Service supprimé correctement"
}

# Vérification de la suppression des répertoires
verify_directory_removal() {
    log_info "Vérification de la suppression des répertoires..."
    
    local app_dir=$(cat /tmp/pre_removal_dir.txt)
    local app_user=$(cat /tmp/pre_removal_user.txt)
    
    # Vérification que le répertoire de l'application est supprimé
    if [ -d "$app_dir" ]; then
        log_error "Le répertoire de l'application existe encore: $app_dir"
        exit 1
    fi
    
    # Vérification que le répertoire de logs est supprimé
    local log_dir="/var/log/$APP_ID"
    if [ -d "$log_dir" ]; then
        log_error "Le répertoire de logs existe encore: $log_dir"
        exit 1
    fi
    
    # Vérification que l'utilisateur système est supprimé
    if id "$app_user" &>/dev/null; then
        log_error "L'utilisateur système existe encore: $app_user"
        exit 1
    fi
    
    log_success "Répertoires supprimés correctement"
}

# Vérification de la suppression des configurations NGINX
verify_nginx_removal() {
    log_info "Vérification de la suppression des configurations NGINX..."
    
    local nginx_config="/etc/nginx/conf.d/$TEST_DOMAIN.d/$APP_ID.conf"
    
    # Vérification que le fichier de configuration NGINX est supprimé
    if [ -f "$nginx_config" ]; then
        log_error "Le fichier de configuration NGINX existe encore: $nginx_config"
        exit 1
    fi
    
    # Vérification que le répertoire de configuration NGINX est vide ou n'existe pas
    local nginx_dir="/etc/nginx/conf.d/$TEST_DOMAIN.d"
    if [ -d "$nginx_dir" ]; then
        local file_count=$(find "$nginx_dir" -name "*$APP_ID*" | wc -l)
        if [ "$file_count" -gt 0 ]; then
            log_error "Des fichiers de configuration NGINX liés à $APP_ID existent encore"
            exit 1
        fi
    fi
    
    # Vérification de la syntaxe NGINX
    if ! nginx -t > /dev/null 2>&1; then
        log_error "La configuration NGINX contient des erreurs après désinstallation"
        exit 1
    fi
    
    log_success "Configurations NGINX supprimées correctement"
}

# Vérification de la suppression des configurations systemd
verify_systemd_removal() {
    log_info "Vérification de la suppression des configurations systemd..."
    
    local systemd_config="/etc/systemd/system/$APP_ID.service"
    
    # Vérification que le fichier de service systemd est supprimé
    if [ -f "$systemd_config" ]; then
        log_error "Le fichier de service systemd existe encore: $systemd_config"
        exit 1
    fi
    
    # Vérification que le service n'est plus dans la liste des services systemd
    if systemctl list-unit-files --type=service | grep -q "$APP_ID"; then
        log_error "Le service est encore dans la liste des services systemd"
        exit 1
    fi
    
    # Vérification que le service n'est plus dans la liste des services activés
    if systemctl list-unit-files --type=service --state=enabled | grep -q "$APP_ID"; then
        log_error "Le service est encore activé dans systemd"
        exit 1
    fi
    
    log_success "Configurations systemd supprimées correctement"
}

# Vérification de la suppression des configurations SSOwat
verify_ssowat_removal() {
    log_info "Vérification de la suppression des configurations SSOwat..."
    
    local ssowat_config="/etc/ssowat/conf.d/$APP_ID.yml"
    
    # Vérification que le fichier de configuration SSOwat est supprimé
    if [ -f "$ssowat_config" ]; then
        log_error "Le fichier de configuration SSOwat existe encore: $ssowat_config"
        exit 1
    fi
    
    # Vérification que le répertoire de configuration SSOwat est vide ou n'existe pas
    local ssowat_dir="/etc/ssowat/conf.d"
    if [ -d "$ssowat_dir" ]; then
        local file_count=$(find "$ssowat_dir" -name "*$APP_ID*" | wc -l)
        if [ "$file_count" -gt 0 ]; then
            log_error "Des fichiers de configuration SSOwat liés à $APP_ID existent encore"
            exit 1
        fi
    fi
    
    log_success "Configurations SSOwat supprimées correctement"
}

# Vérification de la suppression des bases de données
verify_database_removal() {
    log_info "Vérification de la suppression des bases de données..."
    
    local db_name=$(cat /tmp/pre_removal_db.txt)
    local redis_db=$(cat /tmp/pre_removal_redis.txt)
    
    # Vérification de la suppression de la base de données PostgreSQL
    if [ -n "$db_name" ]; then
        if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
            log_error "La base de données PostgreSQL existe encore: $db_name"
            exit 1
        fi
    fi
    
    # Vérification de la suppression de l'utilisateur PostgreSQL
    local app_user=$(cat /tmp/pre_removal_user.txt)
    if [ -n "$app_user" ]; then
        if sudo -u postgres psql -c "SELECT 1 FROM pg_user WHERE usename='$app_user';" | grep -q "1 row"; then
            log_error "L'utilisateur PostgreSQL existe encore: $app_user"
            exit 1
        fi
    fi
    
    # Vérification de la suppression des données Redis
    if [ -n "$redis_db" ]; then
        if redis-cli -n "$redis_db" ping > /dev/null 2>&1; then
            log_error "La base Redis existe encore: $redis_db"
            exit 1
        fi
    fi
    
    log_success "Bases de données supprimées correctement"
}

# Vérification de la suppression des paramètres de l'application
verify_app_settings_removal() {
    log_info "Vérification de la suppression des paramètres de l'application..."
    
    # Vérification que les paramètres de l'application sont supprimés
    local app_settings_dir="/etc/yunohost/apps/$APP_ID"
    if [ -d "$app_settings_dir" ]; then
        log_error "Le répertoire de paramètres de l'application existe encore: $app_settings_dir"
        exit 1
    fi
    
    # Vérification que l'application n'est plus dans la liste des applications
    if yunohost app list | grep -q "$APP_ID"; then
        log_error "L'application est encore dans la liste des applications"
        exit 1
    fi
    
    log_success "Paramètres de l'application supprimés correctement"
}

# Vérification de la suppression des ports
verify_port_removal() {
    log_info "Vérification de la suppression des ports..."
    
    local app_port=$(cat /tmp/pre_removal_port.txt)
    
    if [ -n "$app_port" ]; then
        # Vérification que le port n'est plus utilisé
        if netstat -tlnp | grep -q ":$app_port "; then
            log_error "Le port $app_port est encore utilisé"
            exit 1
        fi
        
        # Vérification que le port n'est plus dans la liste des ports YunoHost
        if yunohost firewall list | grep -q "$app_port"; then
            log_error "Le port $app_port est encore dans la configuration du firewall"
            exit 1
        fi
    fi
    
    log_success "Ports libérés correctement"
}

# Vérification de la suppression des logs
verify_logs_removal() {
    log_info "Vérification de la suppression des logs..."
    
    # Vérification que les logs de l'application sont supprimés
    local log_dir="/var/log/$APP_ID"
    if [ -d "$log_dir" ]; then
        log_error "Le répertoire de logs existe encore: $log_dir"
        exit 1
    fi
    
    # Vérification que les logs systemd sont supprimés
    if journalctl -u "$APP_ID" --no-pager | grep -q "No entries"; then
        log_success "Logs systemd supprimés"
    else
        log_warning "Des logs systemd existent encore (normal si récents)"
    fi
    
    log_success "Logs supprimés correctement"
}

# Vérification de la suppression des sauvegardes
verify_backup_removal() {
    log_info "Vérification de la suppression des sauvegardes..."
    
    local backup_dir="/opt/yunohost/backup/$APP_ID"
    
    # Vérification que le répertoire de sauvegarde est supprimé
    if [ -d "$backup_dir" ]; then
        log_error "Le répertoire de sauvegarde existe encore: $backup_dir"
        exit 1
    fi
    
    log_success "Sauvegardes supprimées correctement"
}

# Vérification de la suppression des configurations de monitoring
verify_monitoring_removal() {
    log_info "Vérification de la suppression des configurations de monitoring..."
    
    local monitoring_config="/etc/yunohost/apps/$APP_ID/monitoring.conf"
    
    # Vérification que le fichier de configuration de monitoring est supprimé
    if [ -f "$monitoring_config" ]; then
        log_error "Le fichier de configuration de monitoring existe encore: $monitoring_config"
        exit 1
    fi
    
    log_success "Configurations de monitoring supprimées correctement"
}

# Test de réinstallation après désinstallation
test_reinstall_after_removal() {
    log_info "Test de réinstallation après désinstallation..."
    
    # Réinstallation de l'application
    if ! ynh_app_install "$APP_ID" \
        --domain "$TEST_DOMAIN" \
        --path "$TEST_PATH" \
        --is_public "$TEST_IS_PUBLIC"; then
        log_error "Échec de la réinstallation après désinstallation"
        exit 1
    fi
    
    # Vérification que l'application fonctionne
    sleep 10
    
    if ! systemctl is-active --quiet "$APP_ID"; then
        log_error "Le service n'est pas actif après réinstallation"
        exit 1
    fi
    
    local port=$(ynh_app_setting_get "$APP_ID" "app_port")
    if ! curl -f "http://127.0.0.1:$port/health" > /dev/null 2>&1; then
        log_error "Le service n'est pas accessible après réinstallation"
        exit 1
    fi
    
    log_success "Réinstallation réussie après désinstallation"
}

# Nettoyage des fichiers temporaires
cleanup_temp_files() {
    log_info "Nettoyage des fichiers temporaires..."
    
    rm -f /tmp/pre_removal_*.txt
    rm -f /tmp/pre_removal_*.conf
    rm -f /tmp/pre_removal_*.service
    rm -f /tmp/pre_removal_*.yml
    
    log_success "Fichiers temporaires supprimés"
}

# Fonction principale
main() {
    log_info "=== DÉMARRAGE DU TEST DE DÉSINSTALLATION AFFiNE ==="
    log_info "Domaine: $TEST_DOMAIN"
    log_info "Chemin: $TEST_PATH"
    log_info "Public: $TEST_IS_PUBLIC"
    log_info "Timeout: ${TIMEOUT}s"
    echo ""
    
    # Vérification des prérequis
    check_prerequisites
    
    # Installation de l'application
    install_app
    
    # Test de fonctionnement initial
    test_initial_functionality
    
    # Enregistrement de l'état avant désinstallation
    record_pre_removal_state
    
    # Désinstallation de l'application
    uninstall_app
    
    # Vérification de la suppression du service
    verify_service_removal
    
    # Vérification de la suppression des répertoires
    verify_directory_removal
    
    # Vérification de la suppression des configurations NGINX
    verify_nginx_removal
    
    # Vérification de la suppression des configurations systemd
    verify_systemd_removal
    
    # Vérification de la suppression des configurations SSOwat
    verify_ssowat_removal
    
    # Vérification de la suppression des bases de données
    verify_database_removal
    
    # Vérification de la suppression des paramètres de l'application
    verify_app_settings_removal
    
    # Vérification de la suppression des ports
    verify_port_removal
    
    # Vérification de la suppression des logs
    verify_logs_removal
    
    # Vérification de la suppression des sauvegardes
    verify_backup_removal
    
    # Vérification de la suppression des configurations de monitoring
    verify_monitoring_removal
    
    # Test de réinstallation après désinstallation
    test_reinstall_after_removal
    
    # Nettoyage des fichiers temporaires
    cleanup_temp_files
    
    # Résumé final
    echo ""
    log_success "=== TEST DE DÉSINSTALLATION RÉUSSI ==="
    log_success "Application: $APP_ID"
    log_success "Désinstallation: Complète et propre"
    log_success "Résidus: Aucun (vhost/unit supprimés)"
    log_success "Réinstallation: Possible et fonctionnelle"
    log_success "État: Système propre et prêt pour une nouvelle installation"
    echo ""
    
    # Code de sortie
    exit 0
}

# Exécution du script principal
main "$@"
