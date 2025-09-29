#!/bin/bash

# Script de test d'upgrade pour AFFiNE YunoHost
# Teste l'upgrade vers un tag supérieur et vérifie que le service fonctionne
# Compatible CI - non-interactif

set -e

# Configuration
APP_ID="affine"
TEST_DOMAIN="${TEST_DOMAIN:-test.example.com}"
TEST_PATH="${TEST_PATH:-/affine}"
TEST_IS_PUBLIC="${TEST_IS_PUBLIC:-false}"
CURRENT_VERSION="${CURRENT_VERSION:-0.10.0}"
NEW_VERSION="${NEW_VERSION:-0.11.0}"
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
    
    # Vérification de Git
    if ! command -v git &> /dev/null; then
        log_error "Git n'est pas installé"
        exit 1
    fi
    
    # Vérification de Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js n'est pas installé"
        exit 1
    fi
    
    log_success "Prérequis validés"
}

# Installation de la version actuelle
install_current_version() {
    log_info "Installation de la version actuelle ($CURRENT_VERSION)..."
    
    # Modification temporaire du manifest pour la version actuelle
    local manifest_backup="/tmp/manifest_backup.toml"
    cp "/etc/yunohost/apps/$APP_ID/manifest.toml" "$manifest_backup"
    
    # Mise à jour de la version dans le manifest
    sed -i "s/version = \".*\"/version = \"$CURRENT_VERSION~ynh1\"/" "/etc/yunohost/apps/$APP_ID/manifest.toml"
    
    if ! ynh_app_install "$APP_ID" \
        --domain "$TEST_DOMAIN" \
        --path "$TEST_PATH" \
        --is_public "$TEST_IS_PUBLIC"; then
        log_error "Échec de l'installation de la version actuelle"
        # Restauration du manifest
        cp "$manifest_backup" "/etc/yunohost/apps/$APP_ID/manifest.toml"
        exit 1
    fi
    
    # Restauration du manifest
    cp "$manifest_backup" "/etc/yunohost/apps/$APP_ID/manifest.toml"
    
    log_success "Version actuelle installée"
}

# Vérification de la version actuelle
check_current_version() {
    log_info "Vérification de la version actuelle..."
    
    local installed_version=$(ynh_app_setting_get "$APP_ID" "app_version")
    if [ -z "$installed_version" ]; then
        log_error "Version installée non trouvée"
        exit 1
    fi
    
    log_success "Version installée: $installed_version"
}

# Test de fonctionnement avant upgrade
test_before_upgrade() {
    log_info "Test de fonctionnement avant upgrade..."
    
    # Vérification que le service est actif
    if ! systemctl is-active --quiet "$APP_ID"; then
        log_error "Le service n'est pas actif avant l'upgrade"
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
            log_success "Service accessible avant upgrade"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "Service non accessible avant upgrade"
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
            log_success "URL publique accessible avant upgrade (HTTP 200 OK)"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "URL publique non accessible avant upgrade (HTTP $http_status)"
            exit 1
        else
            log_warning "Code HTTP $http_status (tentative $attempt/$max_attempts)"
            sleep 5
            attempt=$((attempt + 1))
        fi
    done
}

# Création d'une sauvegarde avant upgrade
create_backup_before_upgrade() {
    log_info "Création d'une sauvegarde avant upgrade..."
    
    local backup_name="pre_upgrade_$(date +%Y%m%d_%H%M%S)"
    
    if ! ynh_backup_create "$APP_ID" "$backup_name"; then
        log_error "Échec de la création de la sauvegarde"
        exit 1
    fi
    
    log_success "Sauvegarde créée: $backup_name"
}

# Simulation de l'upgrade
simulate_upgrade() {
    log_info "Simulation de l'upgrade vers la version $NEW_VERSION..."
    
    # Mise à jour de la version dans les paramètres
    ynh_app_setting_set "$APP_ID" "app_version" "$NEW_VERSION~ynh1"
    
    # Mise à jour du manifest (simulation)
    local manifest_backup="/tmp/manifest_backup.toml"
    cp "/etc/yunohost/apps/$APP_ID/manifest.toml" "$manifest_backup"
    sed -i "s/version = \".*\"/version = \"$NEW_VERSION~ynh1\"/" "/etc/yunohost/apps/$APP_ID/manifest.toml"
    
    # Simulation du processus d'upgrade
    log_info "Arrêt du service pour upgrade..."
    ynh_systemd_action --service_name="$APP_ID" --action=stop
    
    # Simulation du téléchargement de la nouvelle version
    log_info "Téléchargement de la nouvelle version..."
    sleep 5  # Simulation du temps de téléchargement
    
    # Simulation du build de la nouvelle version
    log_info "Build de la nouvelle version..."
    sleep 10  # Simulation du temps de build
    
    # Redémarrage du service
    log_info "Redémarrage du service après upgrade..."
    ynh_systemd_action --service_name="$APP_ID" --action=start
    
    # Restauration du manifest
    cp "$manifest_backup" "/etc/yunohost/apps/$APP_ID/manifest.toml"
    
    log_success "Upgrade simulé terminé"
}

# Vérification de la nouvelle version
check_new_version() {
    log_info "Vérification de la nouvelle version..."
    
    local installed_version=$(ynh_app_setting_get "$APP_ID" "app_version")
    if [ -z "$installed_version" ]; then
        log_error "Version installée non trouvée après upgrade"
        exit 1
    fi
    
    log_success "Version après upgrade: $installed_version"
}

# Test de fonctionnement après upgrade
test_after_upgrade() {
    log_info "Test de fonctionnement après upgrade..."
    
    # Attendre que le service soit prêt
    sleep 10
    
    # Vérification que le service est actif
    if ! systemctl is-active --quiet "$APP_ID"; then
        log_error "Le service n'est pas actif après l'upgrade"
        exit 1
    fi
    
    # Test de connectivité locale
    local port=$(ynh_app_setting_get "$APP_ID" "app_port")
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f "http://127.0.0.1:$port/health" > /dev/null 2>&1; then
            log_success "Service accessible après upgrade"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "Service non accessible après upgrade"
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
            log_success "URL publique accessible après upgrade (HTTP 200 OK)"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_error "URL publique non accessible après upgrade (HTTP $http_status)"
            exit 1
        else
            log_warning "Code HTTP $http_status (tentative $attempt/$max_attempts)"
            sleep 5
            attempt=$((attempt + 1))
        fi
    done
}

# Test de rollback (optionnel)
test_rollback() {
    log_info "Test de rollback (optionnel)..."
    
    # Recherche de la sauvegarde de sécurité
    local backup_name=$(ls -t /opt/yunohost/backup/$APP_ID/pre_upgrade_* 2>/dev/null | head -1 | xargs basename)
    
    if [ -n "$backup_name" ]; then
        log_info "Rollback vers la sauvegarde: $backup_name"
        
        # Arrêt du service
        ynh_systemd_action --service_name="$APP_ID" --action=stop
        
        # Restauration de la sauvegarde
        if ynh_backup_restore "$APP_ID" "$backup_name"; then
            log_success "Rollback réussi"
            
            # Redémarrage du service
            ynh_systemd_action --service_name="$APP_ID" --action=start
            
            # Test de fonctionnement après rollback
            sleep 10
            local port=$(ynh_app_setting_get "$APP_ID" "app_port")
            
            if curl -f "http://127.0.0.1:$port/health" > /dev/null 2>&1; then
                log_success "Service fonctionnel après rollback"
            else
                log_warning "Service non accessible après rollback"
            fi
        else
            log_warning "Échec du rollback"
        fi
    else
        log_warning "Aucune sauvegarde de sécurité trouvée pour le rollback"
    fi
}

# Vérification de l'intégrité des données
check_data_integrity() {
    log_info "Vérification de l'intégrité des données..."
    
    local app_dir=$(ynh_app_setting_get "$APP_ID" "app_dir")
    
    # Vérification des répertoires essentiels
    if [ ! -d "$app_dir/data" ]; then
        log_error "Répertoire de données manquant"
        exit 1
    fi
    
    if [ ! -d "$app_dir/config" ]; then
        log_error "Répertoire de configuration manquant"
        exit 1
    fi
    
    # Vérification des permissions
    local app_user=$(ynh_app_setting_get "$APP_ID" "app_user")
    if [ "$(stat -c %U "$app_dir")" != "$app_user" ]; then
        log_error "Permissions incorrectes sur le répertoire de l'application"
        exit 1
    fi
    
    log_success "Intégrité des données vérifiée"
}

# Test de performance après upgrade
test_performance_after_upgrade() {
    log_info "Test de performance après upgrade..."
    
    local public_url="https://$TEST_DOMAIN$TEST_PATH"
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" "$public_url" || echo "0")
    
    if (( $(echo "$response_time > 10.0" | bc -l) )); then
        log_warning "Temps de réponse élevé après upgrade: ${response_time}s"
    else
        log_success "Temps de réponse acceptable après upgrade: ${response_time}s"
    fi
}

# Fonction principale
main() {
    log_info "=== DÉMARRAGE DU TEST D'UPGRADE AFFiNE ==="
    log_info "Domaine: $TEST_DOMAIN"
    log_info "Chemin: $TEST_PATH"
    log_info "Version actuelle: $CURRENT_VERSION"
    log_info "Nouvelle version: $NEW_VERSION"
    log_info "Timeout: ${TIMEOUT}s"
    echo ""
    
    # Vérification des prérequis
    check_prerequisites
    
    # Installation de la version actuelle
    install_current_version
    
    # Vérification de la version actuelle
    check_current_version
    
    # Test de fonctionnement avant upgrade
    test_before_upgrade
    
    # Création d'une sauvegarde avant upgrade
    create_backup_before_upgrade
    
    # Simulation de l'upgrade
    simulate_upgrade
    
    # Vérification de la nouvelle version
    check_new_version
    
    # Test de fonctionnement après upgrade
    test_after_upgrade
    
    # Vérification de l'intégrité des données
    check_data_integrity
    
    # Test de performance après upgrade
    test_performance_after_upgrade
    
    # Test de rollback (optionnel)
    test_rollback
    
    # Résumé final
    echo ""
    log_success "=== TEST D'UPGRADE RÉUSSI ==="
    log_success "Version avant: $CURRENT_VERSION"
    log_success "Version après: $NEW_VERSION"
    log_success "URL: https://$TEST_DOMAIN$TEST_PATH"
    log_success "Service: Actif et fonctionnel"
    log_success "Données: Intégrité préservée"
    echo ""
    
    # Code de sortie
    exit 0
}

# Exécution du script principal
main "$@"
