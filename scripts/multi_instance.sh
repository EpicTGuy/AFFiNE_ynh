#!/bin/bash

# Script de test multi-instance pour AFFiNE YunoHost
# Installe une 2e instance sur /affine2 avec ports automatiques
# Teste l'accès HTTP 200 OK pour les deux instances
# Compatible CI - non-interactif

set -e

# Configuration
APP_ID="affine"
TEST_DOMAIN="${TEST_DOMAIN:-test.example.com}"
TEST_PATH1="${TEST_PATH1:-/affine}"
TEST_PATH2="${TEST_PATH2:-/affine2}"
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
    ynh_app_remove "${APP_ID}_1" 2>/dev/null || true
    ynh_app_remove "${APP_ID}_2" 2>/dev/null || true
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
    
    # Vérification du support multi-instance dans le manifest
    if ! grep -q "multi_instance = true" "/etc/yunohost/apps/$APP_ID/manifest.toml"; then
        log_error "Le support multi-instance n'est pas activé"
        exit 1
    fi
    
    log_success "Prérequis validés"
}

# Installation de la première instance
install_first_instance() {
    log_info "Installation de la première instance sur $TEST_PATH1..."
    
    if ! ynh_app_install "${APP_ID}_1" \
        --domain "$TEST_DOMAIN" \
        --path "$TEST_PATH1" \
        --is_public "$TEST_IS_PUBLIC"; then
        log_error "Échec de l'installation de la première instance"
        exit 1
    fi
    
    log_success "Première instance installée"
}

# Installation de la deuxième instance
install_second_instance() {
    log_info "Installation de la deuxième instance sur $TEST_PATH2..."
    
    if ! ynh_app_install "${APP_ID}_2" \
        --domain "$TEST_DOMAIN" \
        --path "$TEST_PATH2" \
        --is_public "$TEST_IS_PUBLIC"; then
        log_error "Échec de l'installation de la deuxième instance"
        exit 1
    fi
    
    log_success "Deuxième instance installée"
}

# Vérification des services
check_services() {
    log_info "Vérification des services..."
    
    # Vérification de la première instance
    if ! systemctl is-active --quiet "${APP_ID}_1"; then
        log_error "La première instance n'est pas active"
        exit 1
    fi
    
    # Vérification de la deuxième instance
    if ! systemctl is-active --quiet "${APP_ID}_2"; then
        log_error "La deuxième instance n'est pas active"
        exit 1
    fi
    
    log_success "Les deux services sont actifs"
}

# Vérification des ports différents
check_different_ports() {
    log_info "Vérification des ports différents..."
    
    local port1=$(ynh_app_setting_get "${APP_ID}_1" "app_port")
    local port2=$(ynh_app_setting_get "${APP_ID}_2" "app_port")
    
    if [ -z "$port1" ] || [ -z "$port2" ]; then
        log_error "Les ports des instances ne sont pas définis"
        exit 1
    fi
    
    if [ "$port1" = "$port2" ]; then
        log_error "Les deux instances utilisent le même port ($port1)"
        exit 1
    fi
    
    log_success "Ports différents: $port1 et $port2"
}

# Vérification des bases de données différentes
check_different_databases() {
    log_info "Vérification des bases de données différentes..."
    
    local db1=$(ynh_app_setting_get "${APP_ID}_1" "db_name")
    local db2=$(ynh_app_setting_get "${APP_ID}_2" "db_name")
    
    if [ -z "$db1" ] || [ -z "$db2" ]; then
        log_error "Les bases de données des instances ne sont pas définies"
        exit 1
    fi
    
    if [ "$db1" = "$db2" ]; then
        log_error "Les deux instances utilisent la même base de données ($db1)"
        exit 1
    fi
    
    log_success "Bases de données différentes: $db1 et $db2"
}

# Vérification des utilisateurs différents
check_different_users() {
    log_info "Vérification des utilisateurs différents..."
    
    local user1=$(ynh_app_setting_get "${APP_ID}_1" "app_user")
    local user2=$(ynh_app_setting_get "${APP_ID}_2" "app_user")
    
    if [ -z "$user1" ] || [ -z "$user2" ]; then
        log_error "Les utilisateurs des instances ne sont pas définis"
        exit 1
    fi
    
    if [ "$user1" = "$user2" ]; then
        log_error "Les deux instances utilisent le même utilisateur ($user1)"
        exit 1
    fi
    
    log_success "Utilisateurs différents: $user1 et $user2"
}

# Test de connectivité des instances
test_instance_connectivity() {
    local instance_id="$1"
    local port="$2"
    local path="$3"
    
    log_info "Test de connectivité de l'instance $instance_id..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Tentative $attempt/$max_attempts pour l'instance $instance_id..."
        
        if curl -f "http://127.0.0.1:$port/health" > /dev/null 2>&1; then
            log_success "Instance $instance_id accessible localement"
            return 0
        fi
        
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_error "L'instance $instance_id n'est pas accessible localement"
    return 1
}

# Test des URLs publiques
test_public_urls() {
    log_info "Test des URLs publiques..."
    
    local url1="https://$TEST_DOMAIN$TEST_PATH1"
    local url2="https://$TEST_DOMAIN$TEST_PATH2"
    
    # Test de la première instance
    log_info "Test de l'URL de la première instance: $url1"
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        local http_status1=$(curl -s -o /dev/null -w "%{http_code}" "$url1" || echo "000")
        
        if [ "$http_status1" = "200" ]; then
            log_success "Première instance accessible (HTTP 200 OK)"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "La première instance n'est pas accessible (HTTP $http_status1)"
            exit 1
        else
            log_warning "Code HTTP $http_status1 pour la première instance (tentative $attempt/$max_attempts)"
            sleep 5
        fi
        
        attempt=$((attempt + 1))
    done
    
    # Test de la deuxième instance
    log_info "Test de l'URL de la deuxième instance: $url2"
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        local http_status2=$(curl -s -o /dev/null -w "%{http_code}" "$url2" || echo "000")
        
        if [ "$http_status2" = "200" ]; then
            log_success "Deuxième instance accessible (HTTP 200 OK)"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "La deuxième instance n'est pas accessible (HTTP $http_status2)"
            exit 1
        else
            log_warning "Code HTTP $http_status2 pour la deuxième instance (tentative $attempt/$max_attempts)"
            sleep 5
        fi
        
        attempt=$((attempt + 1))
    done
}

# Test d'isolation des données
test_data_isolation() {
    log_info "Test d'isolation des données..."
    
    local dir1=$(ynh_app_setting_get "${APP_ID}_1" "app_dir")
    local dir2=$(ynh_app_setting_get "${APP_ID}_2" "app_dir")
    
    # Création d'un fichier de test dans la première instance
    echo "test_data_instance_1" > "$dir1/data/test_isolation.txt"
    
    # Vérification que le fichier n'existe pas dans la deuxième instance
    if [ -f "$dir2/data/test_isolation.txt" ]; then
        log_error "Les données des instances ne sont pas isolées"
        exit 1
    fi
    
    # Test inverse
    echo "test_data_instance_2" > "$dir2/data/test_isolation.txt"
    
    if [ -f "$dir1/data/test_isolation.txt" ] && [ -f "$dir2/data/test_isolation.txt" ]; then
        if [ "$(cat "$dir1/data/test_isolation.txt")" = "$(cat "$dir2/data/test_isolation.txt")" ]; then
            log_error "Les données des instances ne sont pas isolées"
            exit 1
        fi
    fi
    
    log_success "Données isolées correctement"
}

# Test de gestion des erreurs
test_error_handling() {
    log_info "Test de gestion des erreurs..."
    
    # Arrêt de la première instance
    log_info "Arrêt de la première instance..."
    ynh_systemd_action --service_name="${APP_ID}_1" --action=stop
    
    # Vérification que la deuxième instance continue de fonctionner
    local port2=$(ynh_app_setting_get "${APP_ID}_2" "app_port")
    if ! curl -f "http://127.0.0.1:$port2/health" > /dev/null 2>&1; then
        log_error "La deuxième instance s'est arrêtée quand la première a été arrêtée"
        exit 1
    fi
    
    log_success "La deuxième instance continue de fonctionner"
    
    # Redémarrage de la première instance
    log_info "Redémarrage de la première instance..."
    ynh_systemd_action --service_name="${APP_ID}_1" --action=start
    
    sleep 5
    
    # Vérification que les deux instances fonctionnent
    local port1=$(ynh_app_setting_get "${APP_ID}_1" "app_port")
    if ! curl -f "http://127.0.0.1:$port1/health" > /dev/null 2>&1; then
        log_error "La première instance ne s'est pas redémarrée correctement"
        exit 1
    fi
    
    if ! curl -f "http://127.0.0.1:$port2/health" > /dev/null 2>&1; then
        log_error "La deuxième instance ne fonctionne plus après le redémarrage de la première"
        exit 1
    fi
    
    log_success "Gestion des erreurs correcte"
}

# Fonction principale
main() {
    log_info "=== DÉMARRAGE DU TEST MULTI-INSTANCE AFFiNE ==="
    log_info "Domaine: $TEST_DOMAIN"
    log_info "Chemin 1: $TEST_PATH1"
    log_info "Chemin 2: $TEST_PATH2"
    log_info "Public: $TEST_IS_PUBLIC"
    log_info "Timeout: ${TIMEOUT}s"
    echo ""
    
    # Vérification des prérequis
    check_prerequisites
    
    # Installation de la première instance
    install_first_instance
    
    # Installation de la deuxième instance
    install_second_instance
    
    # Vérification des services
    check_services
    
    # Vérification des ports différents
    check_different_ports
    
    # Vérification des bases de données différentes
    check_different_databases
    
    # Vérification des utilisateurs différents
    check_different_users
    
    # Test de connectivité des instances
    local port1=$(ynh_app_setting_get "${APP_ID}_1" "app_port")
    local port2=$(ynh_app_setting_get "${APP_ID}_2" "app_port")
    
    test_instance_connectivity "1" "$port1" "$TEST_PATH1"
    test_instance_connectivity "2" "$port2" "$TEST_PATH2"
    
    # Test des URLs publiques
    test_public_urls
    
    # Test d'isolation des données
    test_data_isolation
    
    # Test de gestion des erreurs
    test_error_handling
    
    # Résumé final
    echo ""
    log_success "=== TEST MULTI-INSTANCE RÉUSSI ==="
    log_success "Instance 1: https://$TEST_DOMAIN$TEST_PATH1 (port $port1)"
    log_success "Instance 2: https://$TEST_DOMAIN$TEST_PATH2 (port $port2)"
    log_success "Base de données 1: $(ynh_app_setting_get "${APP_ID}_1" "db_name")"
    log_success "Base de données 2: $(ynh_app_setting_get "${APP_ID}_2" "db_name")"
    log_success "Utilisateur 1: $(ynh_app_setting_get "${APP_ID}_1" "app_user")"
    log_success "Utilisateur 2: $(ynh_app_setting_get "${APP_ID}_2" "app_user")"
    echo ""
    
    # Code de sortie
    exit 0
}

# Exécution du script principal
main "$@"
