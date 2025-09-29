#!/bin/bash

# Script d'installation fraîche pour AFFiNE YunoHost
# Teste l'installation complète et vérifie l'accès HTTP 200 OK
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
    
    # Vérification de Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js n'est pas installé"
        exit 1
    fi
    
    # Vérification de NGINX
    if ! command -v nginx &> /dev/null; then
        log_error "NGINX n'est pas installé"
        exit 1
    fi
    
    # Vérification de PostgreSQL
    if ! command -v psql &> /dev/null; then
        log_error "PostgreSQL n'est pas installé"
        exit 1
    fi
    
    # Vérification de Redis
    if ! command -v redis-cli &> /dev/null; then
        log_error "Redis n'est pas installé"
        exit 1
    fi
    
    log_success "Tous les prérequis sont satisfaits"
}

# Installation de l'application
install_app() {
    log_info "Installation de l'application AFFiNE..."
    
    # Installation avec paramètres non-interactifs
    if ! ynh_app_install "$APP_ID" \
        --domain "$TEST_DOMAIN" \
        --path "$TEST_PATH" \
        --is_public "$TEST_IS_PUBLIC"; then
        log_error "Échec de l'installation de l'application"
        exit 1
    fi
    
    log_success "Application installée avec succès"
}

# Vérification du service
check_service() {
    log_info "Vérification du service..."
    
    # Vérification que le service est actif
    if ! systemctl is-active --quiet "$APP_ID"; then
        log_error "Le service $APP_ID n'est pas actif"
        exit 1
    fi
    
    # Récupération du port
    APP_PORT=$(ynh_app_setting_get "$APP_ID" "app_port")
    if [ -z "$APP_PORT" ]; then
        log_error "Le port de l'application n'est pas défini"
        exit 1
    fi
    
    log_success "Service actif sur le port $APP_PORT"
}

# Test de connectivité locale
test_local_connectivity() {
    log_info "Test de connectivité locale..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Tentative $attempt/$max_attempts..."
        
        if curl -f "http://127.0.0.1:$APP_PORT/health" > /dev/null 2>&1; then
            log_success "Service local accessible"
            return 0
        fi
        
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_error "Le service n'est pas accessible localement après $max_attempts tentatives"
    exit 1
}

# Test de l'URL publique
test_public_url() {
    log_info "Test de l'URL publique..."
    
    local public_url="https://$TEST_DOMAIN$TEST_PATH"
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Tentative $attempt/$max_attempts pour $public_url..."
        
        local http_status=$(curl -s -o /dev/null -w "%{http_code}" "$public_url" || echo "000")
        
        if [ "$http_status" = "200" ]; then
            log_success "URL publique accessible (HTTP 200 OK)"
            return 0
        elif [ "$http_status" = "000" ]; then
            log_warning "Connexion échouée (tentative $attempt/$max_attempts)"
        else
            log_warning "Code HTTP $http_status (tentative $attempt/$max_attempts)"
        fi
        
        sleep 5
        attempt=$((attempt + 1))
    done
    
    log_error "L'URL publique n'est pas accessible après $max_attempts tentatives"
    log_error "Dernier code HTTP: $http_status"
    exit 1
}

# Vérification des configurations
check_configurations() {
    log_info "Vérification des configurations..."
    
    # Vérification de la configuration NGINX
    if [ ! -f "/etc/nginx/conf.d/$TEST_DOMAIN.d/$APP_ID.conf" ]; then
        log_error "Configuration NGINX manquante"
        exit 1
    fi
    
    # Vérification de la configuration systemd
    if [ ! -f "/etc/systemd/system/$APP_ID.service" ]; then
        log_error "Configuration systemd manquante"
        exit 1
    fi
    
    # Vérification de la configuration SSOwat
    if [ ! -f "/etc/ssowat/conf.d/$APP_ID.yml" ]; then
        log_error "Configuration SSOwat manquante"
        exit 1
    fi
    
    log_success "Toutes les configurations sont présentes"
}

# Vérification de la base de données
check_database() {
    log_info "Vérification de la base de données..."
    
    local db_name=$(ynh_app_setting_get "$APP_ID" "db_name")
    if [ -z "$db_name" ]; then
        log_error "Nom de la base de données non défini"
        exit 1
    fi
    
    if ! sudo -u postgres psql -d "$db_name" -c "SELECT 1;" > /dev/null 2>&1; then
        log_error "Impossible de se connecter à la base de données $db_name"
        exit 1
    fi
    
    log_success "Base de données accessible"
}

# Vérification de Redis
check_redis() {
    log_info "Vérification de Redis..."
    
    local redis_db=$(ynh_app_setting_get "$APP_ID" "redis_db")
    if [ -z "$redis_db" ]; then
        log_error "Base Redis non définie"
        exit 1
    fi
    
    if ! redis-cli -n "$redis_db" ping > /dev/null 2>&1; then
        log_error "Impossible de se connecter à Redis DB $redis_db"
        exit 1
    fi
    
    log_success "Redis accessible"
}

# Test de performance
test_performance() {
    log_info "Test de performance..."
    
    local public_url="https://$TEST_DOMAIN$TEST_PATH"
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" "$public_url" || echo "0")
    
    if (( $(echo "$response_time > 5.0" | bc -l) )); then
        log_warning "Temps de réponse élevé: ${response_time}s"
    else
        log_success "Temps de réponse acceptable: ${response_time}s"
    fi
}

# Fonction principale
main() {
    log_info "=== DÉMARRAGE DU TEST D'INSTALLATION AFFiNE ==="
    log_info "Domaine: $TEST_DOMAIN"
    log_info "Chemin: $TEST_PATH"
    log_info "Public: $TEST_IS_PUBLIC"
    log_info "Timeout: ${TIMEOUT}s"
    echo ""
    
    # Vérification des prérequis
    check_prerequisites
    
    # Installation de l'application
    install_app
    
    # Vérification du service
    check_service
    
    # Test de connectivité locale
    test_local_connectivity
    
    # Test de l'URL publique
    test_public_url
    
    # Vérification des configurations
    check_configurations
    
    # Vérification de la base de données
    check_database
    
    # Vérification de Redis
    check_redis
    
    # Test de performance
    test_performance
    
    # Résumé final
    echo ""
    log_success "=== TEST D'INSTALLATION RÉUSSI ==="
    log_success "Application: $APP_ID"
    log_success "URL: https://$TEST_DOMAIN$TEST_PATH"
    log_success "Port: $APP_PORT"
    log_success "Base de données: $(ynh_app_setting_get "$APP_ID" "db_name")"
    log_success "Redis: $(ynh_app_setting_get "$APP_ID" "redis_db")"
    log_success "Utilisateur: $(ynh_app_setting_get "$APP_ID" "app_user")"
    echo ""
    
    # Code de sortie
    exit 0
}

# Exécution du script principal
main "$@"
