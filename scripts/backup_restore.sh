#!/bin/bash

# Script de test backup/restore pour AFFiNE YunoHost
# Teste le cycle complet: backup → uninstall → restore → 200 OK
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
    # Suppression des sauvegardes de test
    rm -rf "/opt/yunohost/backup/$APP_ID/test_*" 2>/dev/null || true
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
    
    # Vérification de jq
    if ! command -v jq &> /dev/null; then
        log_error "jq n'est pas installé"
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

# Création de données de test
create_test_data() {
    log_info "Création de données de test..."
    
    local app_dir=$(ynh_app_setting_get "$APP_ID" "app_dir")
    local app_user=$(ynh_app_setting_get "$APP_ID" "app_user")
    
    # Création de fichiers de test
    echo "test_data_$(date +%s)" > "$app_dir/data/test_file.txt"
    echo "test_config_$(date +%s)" > "$app_dir/config/test_config.txt"
    
    # Création de données dans la base de données
    local db_name=$(ynh_app_setting_get "$APP_ID" "db_name")
    if [ -n "$db_name" ]; then
        sudo -u postgres psql -d "$db_name" -c "CREATE TABLE IF NOT EXISTS test_table (id SERIAL PRIMARY KEY, data TEXT);"
        sudo -u postgres psql -d "$db_name" -c "INSERT INTO test_table (data) VALUES ('test_data_$(date +%s)');"
    fi
    
    # Création de données Redis
    local redis_db=$(ynh_app_setting_get "$APP_ID" "redis_db")
    if [ -n "$redis_db" ]; then
        redis-cli -n "$redis_db" set "test_key" "test_value_$(date +%s)"
    fi
    
    log_success "Données de test créées"
}

# Création de la sauvegarde
create_backup() {
    log_info "Création de la sauvegarde..."
    
    local backup_name="test_backup_$(date +%Y%m%d_%H%M%S)"
    
    if ! ynh_backup_create "$APP_ID" "$backup_name"; then
        log_error "Échec de la création de la sauvegarde"
        exit 1
    fi
    
    # Vérification de l'existence de la sauvegarde
    if [ ! -d "/opt/yunohost/backup/$APP_ID/$backup_name" ]; then
        log_error "Le répertoire de sauvegarde n'existe pas"
        exit 1
    fi
    
    # Vérification des fichiers de sauvegarde
    local backup_dir="/opt/yunohost/backup/$APP_ID/$backup_name"
    local required_files=("metadata.json" "data.tar.gz" "config.tar.gz")
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$backup_dir/$file" ]; then
            log_error "Fichier de sauvegarde manquant: $file"
            exit 1
        fi
    done
    
    log_success "Sauvegarde créée: $backup_name"
    echo "$backup_name" > /tmp/backup_name.txt
}

# Vérification de la sauvegarde
verify_backup() {
    log_info "Vérification de la sauvegarde..."
    
    local backup_name=$(cat /tmp/backup_name.txt)
    local backup_dir="/opt/yunohost/backup/$APP_ID/$backup_name"
    
    # Vérification du fichier de métadonnées
    if [ ! -f "$backup_dir/metadata.json" ]; then
        log_error "Fichier de métadonnées manquant"
        exit 1
    fi
    
    # Vérification de la validité JSON
    if ! jq empty "$backup_dir/metadata.json" 2>/dev/null; then
        log_error "Fichier de métadonnées JSON invalide"
        exit 1
    fi
    
    # Vérification des données sauvegardées
    local app_dir=$(ynh_app_setting_get "$APP_ID" "app_dir")
    local test_file_content=$(echo "test_data_$(date +%s)")
    
    # Extraction temporaire pour vérification
    local temp_dir="/tmp/backup_verify"
    mkdir -p "$temp_dir"
    
    # Vérification des données
    tar -xzf "$backup_dir/data.tar.gz" -C "$temp_dir"
    if [ ! -f "$temp_dir/data/test_file.txt" ]; then
        log_error "Fichier de test non trouvé dans la sauvegarde des données"
        exit 1
    fi
    
    # Vérification de la configuration
    tar -xzf "$backup_dir/config.tar.gz" -C "$temp_dir"
    if [ ! -f "$temp_dir/config/test_config.txt" ]; then
        log_error "Fichier de configuration de test non trouvé dans la sauvegarde"
        exit 1
    fi
    
    # Nettoyage
    rm -rf "$temp_dir"
    
    log_success "Sauvegarde vérifiée"
}

# Désinstallation de l'application
uninstall_app() {
    log_info "Désinstallation de l'application..."
    
    if ! ynh_app_remove "$APP_ID"; then
        log_error "Échec de la désinstallation de l'application"
        exit 1
    fi
    
    # Vérification que l'application est bien supprimée
    if systemctl is-active --quiet "$APP_ID" 2>/dev/null; then
        log_error "Le service est encore actif après désinstallation"
        exit 1
    fi
    
    # Vérification que les répertoires sont supprimés
    local app_dir="/var/www/$APP_ID"
    if [ -d "$app_dir" ]; then
        log_error "Le répertoire de l'application existe encore après désinstallation"
        exit 1
    fi
    
    log_success "Application désinstallée avec succès"
}

# Vérification de la suppression complète
verify_complete_removal() {
    log_info "Vérification de la suppression complète..."
    
    # Vérification des services
    if systemctl is-active --quiet "$APP_ID" 2>/dev/null; then
        log_error "Service encore actif"
        exit 1
    fi
    
    # Vérification des répertoires
    local app_dir="/var/www/$APP_ID"
    if [ -d "$app_dir" ]; then
        log_error "Répertoire de l'application encore présent"
        exit 1
    fi
    
    # Vérification des logs
    local log_dir="/var/log/$APP_ID"
    if [ -d "$log_dir" ]; then
        log_error "Répertoire de logs encore présent"
        exit 1
    fi
    
    # Vérification des configurations NGINX
    if [ -f "/etc/nginx/conf.d/$TEST_DOMAIN.d/$APP_ID.conf" ]; then
        log_error "Configuration NGINX encore présente"
        exit 1
    fi
    
    # Vérification des configurations systemd
    if [ -f "/etc/systemd/system/$APP_ID.service" ]; then
        log_error "Configuration systemd encore présente"
        exit 1
    fi
    
    # Vérification des configurations SSOwat
    if [ -f "/etc/ssowat/conf.d/$APP_ID.yml" ]; then
        log_error "Configuration SSOwat encore présente"
        exit 1
    fi
    
    log_success "Suppression complète vérifiée"
}

# Réinstallation de l'application
reinstall_app() {
    log_info "Réinstallation de l'application..."
    
    if ! ynh_app_install "$APP_ID" \
        --domain "$TEST_DOMAIN" \
        --path "$TEST_PATH" \
        --is_public "$TEST_IS_PUBLIC"; then
        log_error "Échec de la réinstallation de l'application"
        exit 1
    fi
    
    log_success "Application réinstallée avec succès"
}

# Restauration de la sauvegarde
restore_backup() {
    log_info "Restauration de la sauvegarde..."
    
    local backup_name=$(cat /tmp/backup_name.txt)
    
    if ! ynh_backup_restore "$APP_ID" "$backup_name"; then
        log_error "Échec de la restauration de la sauvegarde"
        exit 1
    fi
    
    log_success "Sauvegarde restaurée avec succès"
}

# Test de fonctionnement après restauration
test_after_restore() {
    log_info "Test de fonctionnement après restauration..."
    
    # Attendre que le service soit prêt
    sleep 10
    
    # Vérification que le service est actif
    if ! systemctl is-active --quiet "$APP_ID"; then
        log_error "Le service n'est pas actif après restauration"
        exit 1
    fi
    
    # Test de connectivité locale
    local port=$(ynh_app_setting_get "$APP_ID" "app_port")
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f "http://127.0.0.1:$port/health" > /dev/null 2>&1; then
            log_success "Service accessible localement après restauration"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "Service non accessible localement après restauration"
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
            log_success "URL publique accessible après restauration (HTTP 200 OK)"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "URL publique non accessible après restauration (HTTP $http_status)"
            exit 1
        else
            log_warning "Code HTTP $http_status (tentative $attempt/$max_attempts)"
            sleep 5
            attempt=$((attempt + 1))
        fi
    done
}

# Vérification des données restaurées
verify_restored_data() {
    log_info "Vérification des données restaurées..."
    
    local app_dir=$(ynh_app_setting_get "$APP_ID" "app_dir")
    
    # Vérification des fichiers de données
    if [ ! -f "$app_dir/data/test_file.txt" ]; then
        log_error "Fichier de test non restauré"
        exit 1
    fi
    
    if [ ! -f "$app_dir/config/test_config.txt" ]; then
        log_error "Fichier de configuration de test non restauré"
        exit 1
    fi
    
    # Vérification de la base de données
    local db_name=$(ynh_app_setting_get "$APP_ID" "db_name")
    if [ -n "$db_name" ]; then
        local test_count=$(sudo -u postgres psql -d "$db_name" -t -c "SELECT COUNT(*) FROM test_table;" 2>/dev/null | tr -d ' ')
        if [ "$test_count" -eq 0 ]; then
            log_error "Données de test de la base de données non restaurées"
            exit 1
        fi
        log_success "Données de la base de données restaurées ($test_count enregistrements)"
    fi
    
    # Vérification de Redis
    local redis_db=$(ynh_app_setting_get "$APP_ID" "redis_db")
    if [ -n "$redis_db" ]; then
        local redis_value=$(redis-cli -n "$redis_db" get "test_key" 2>/dev/null)
        if [ -z "$redis_value" ]; then
            log_error "Données Redis non restaurées"
            exit 1
        fi
        log_success "Données Redis restaurées"
    fi
    
    log_success "Toutes les données ont été restaurées correctement"
}

# Test de performance après restauration
test_performance_after_restore() {
    log_info "Test de performance après restauration..."
    
    local public_url="https://$TEST_DOMAIN$TEST_PATH"
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" "$public_url" || echo "0")
    
    if (( $(echo "$response_time > 10.0" | bc -l) )); then
        log_warning "Temps de réponse élevé après restauration: ${response_time}s"
    else
        log_success "Temps de réponse acceptable après restauration: ${response_time}s"
    fi
}

# Nettoyage des sauvegardes de test
cleanup_test_backups() {
    log_info "Nettoyage des sauvegardes de test..."
    
    local backup_name=$(cat /tmp/backup_name.txt)
    
    if ynh_backup_delete "$APP_ID" "$backup_name"; then
        log_success "Sauvegarde de test supprimée"
    else
        log_warning "Échec de la suppression de la sauvegarde de test"
    fi
    
    rm -f /tmp/backup_name.txt
}

# Fonction principale
main() {
    log_info "=== DÉMARRAGE DU TEST BACKUP/RESTORE AFFiNE ==="
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
    
    # Création de données de test
    create_test_data
    
    # Création de la sauvegarde
    create_backup
    
    # Vérification de la sauvegarde
    verify_backup
    
    # Désinstallation de l'application
    uninstall_app
    
    # Vérification de la suppression complète
    verify_complete_removal
    
    # Réinstallation de l'application
    reinstall_app
    
    # Restauration de la sauvegarde
    restore_backup
    
    # Test de fonctionnement après restauration
    test_after_restore
    
    # Vérification des données restaurées
    verify_restored_data
    
    # Test de performance après restauration
    test_performance_after_restore
    
    # Nettoyage des sauvegardes de test
    cleanup_test_backups
    
    # Résumé final
    echo ""
    log_success "=== TEST BACKUP/RESTORE RÉUSSI ==="
    log_success "Application: $APP_ID"
    log_success "URL: https://$TEST_DOMAIN$TEST_PATH"
    log_success "Port: $(ynh_app_setting_get "$APP_ID" "app_port")"
    log_success "Base de données: $(ynh_app_setting_get "$APP_ID" "db_name")"
    log_success "Redis: $(ynh_app_setting_get "$APP_ID" "redis_db")"
    log_success "Utilisateur: $(ynh_app_setting_get "$APP_ID" "app_user")"
    log_success "Cycle complet: Installation → Backup → Uninstall → Reinstall → Restore → 200 OK"
    echo ""
    
    # Code de sortie
    exit 0
}

# Exécution du script principal
main "$@"
