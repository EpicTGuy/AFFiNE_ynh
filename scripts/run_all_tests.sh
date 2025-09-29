#!/bin/bash

# Script principal pour exécuter tous les tests AFFiNE YunoHost
# Exécute tous les scripts de test et génère un rapport complet
# Compatible CI - non-interactif

set -e

# Configuration
TEST_DOMAIN="${TEST_DOMAIN:-test.example.com}"
TEST_PATH="${TEST_PATH:-/affine}"
TEST_IS_PUBLIC="${TEST_IS_PUBLIC:-false}"
TIMEOUT="${TIMEOUT:-300}"

# Répertoire de test
TEST_DIR="/tmp/affine_tests"
REPORT_FILE="$TEST_DIR/test_report.txt"
LOG_DIR="$TEST_DIR/logs"

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
    rm -rf "$TEST_DIR" 2>/dev/null || true
    log_info "Nettoyage terminé"
}

# Gestion des erreurs
trap cleanup EXIT

# Création du répertoire de test
create_test_directory() {
    log_info "Création du répertoire de test..."
    mkdir -p "$TEST_DIR"
    mkdir -p "$LOG_DIR"
    log_success "Répertoire de test créé: $TEST_DIR"
}

# Initialisation du rapport
init_report() {
    log_info "Initialisation du rapport de test..."
    
    cat > "$REPORT_FILE" << EOF
=== RAPPORT DE TEST AFFiNE YUNOHOST ===
Date: $(date)
Domaine de test: $TEST_DOMAIN
Chemin de test: $TEST_PATH
Public: $TEST_IS_PUBLIC
Timeout: ${TIMEOUT}s

=== RÉSULTATS DES TESTS ===

EOF
    
    log_success "Rapport initialisé: $REPORT_FILE"
}

# Fonction pour exécuter un test
run_test() {
    local test_name="$1"
    local test_script="$2"
    local start_time=$(date +%s)
    
    echo ""
    log_info "🧪 Exécution du test: $test_name"
    echo "Test: $test_name" >> "$REPORT_FILE"
    echo "Début: $(date)" >> "$REPORT_FILE"
    echo "Script: $test_script" >> "$REPORT_FILE"
    
    # Exécution du test avec redirection des logs
    local log_file="$LOG_DIR/${test_name,,}.log"
    if bash "$test_script" > "$log_file" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_success "✅ $test_name: RÉUSSI (${duration}s)"
        echo "Résultat: RÉUSSI (${duration}s)" >> "$REPORT_FILE"
        echo "Status: SUCCESS" >> "$REPORT_FILE"
        echo "Log: $log_file" >> "$REPORT_FILE"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_error "❌ $test_name: ÉCHEC (${duration}s)"
        echo "Résultat: ÉCHEC (${duration}s)" >> "$REPORT_FILE"
        echo "Status: FAILED" >> "$REPORT_FILE"
        echo "Log: $log_file" >> "$REPORT_FILE"
        return 1
    fi
    
    echo "" >> "$REPORT_FILE"
}

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
    
    # Vérification de jq
    if ! command -v jq &> /dev/null; then
        log_error "jq n'est pas installé"
        exit 1
    fi
    
    # Vérification de bc
    if ! command -v bc &> /dev/null; then
        log_error "bc n'est pas installé"
        exit 1
    fi
    
    log_success "Tous les prérequis sont satisfaits"
}

# Fonction pour afficher le résumé
show_summary() {
    local total_tests="$1"
    local passed_tests="$2"
    local failed_tests="$3"
    
    echo ""
    log_info "📊 RÉSUMÉ DES TESTS"
    log_info "=================="
    log_info "Total des tests: $total_tests"
    log_info "Tests réussis: $passed_tests"
    log_info "Tests échoués: $failed_tests"
    log_info "Taux de réussite: $((passed_tests * 100 / total_tests))%"
    echo ""
    
    if [ "$failed_tests" -eq 0 ]; then
        log_success "🎉 Tous les tests ont réussi !"
        log_success "✅ Le package AFFiNE est prêt pour la production"
    else
        log_error "⚠️  $failed_tests test(s) ont échoué"
        log_error "❌ Le package AFFiNE nécessite des corrections"
    fi
}

# Fonction pour générer le rapport final
generate_final_report() {
    local total_tests="$1"
    local passed_tests="$2"
    local failed_tests="$3"
    
    cat >> "$REPORT_FILE" << EOF

=== RÉSUMÉ FINAL ===
Total des tests: $total_tests
Tests réussis: $passed_tests
Tests échoués: $failed_tests
Taux de réussite: $((passed_tests * 100 / total_tests))%

=== FICHIERS DE LOG ===
EOF
    
    # Ajout des fichiers de log
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            echo "Log: $(basename "$log_file")" >> "$REPORT_FILE"
        fi
    done
    
    cat >> "$REPORT_FILE" << EOF

=== INFORMATIONS SYSTÈME ===
OS: $(uname -a)
YunoHost: $(yunohost --version 2>/dev/null || echo "Non disponible")
Node.js: $(node --version 2>/dev/null || echo "Non disponible")
NGINX: $(nginx -v 2>&1 | head -1 || echo "Non disponible")
PostgreSQL: $(psql --version 2>/dev/null || echo "Non disponible")
Redis: $(redis-cli --version 2>/dev/null || echo "Non disponible")

=== FIN DU RAPPORT ===
EOF
}

# Fonction principale
main() {
    log_info "🚀 DÉMARRAGE DE TOUS LES TESTS AFFiNE YUNOHOST"
    log_info "=============================================="
    log_info "Domaine: $TEST_DOMAIN"
    log_info "Chemin: $TEST_PATH"
    log_info "Public: $TEST_IS_PUBLIC"
    log_info "Timeout: ${TIMEOUT}s"
    echo ""
    
    # Création du répertoire de test
    create_test_directory
    
    # Initialisation du rapport
    init_report
    
    # Vérification des prérequis
    check_prerequisites
    
    # Compteurs de tests
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    
    # Liste des tests à exécuter
    local tests=(
        "Installation" "install.sh"
        "Multi-instance" "multi_instance.sh"
        "Upgrade" "upgrade.sh"
        "Backup/Restore" "backup_restore.sh"
        "Désinstallation" "remove.sh"
    )
    
    # Exécution des tests
    for ((i=0; i<${#tests[@]}; i+=2)); do
        local test_name="${tests[i]}"
        local test_script="${tests[i+1]}"
        
        total_tests=$((total_tests + 1))
        
        if run_test "$test_name" "$test_script"; then
            passed_tests=$((passed_tests + 1))
        else
            failed_tests=$((failed_tests + 1))
        fi
    done
    
    # Génération du rapport final
    generate_final_report "$total_tests" "$passed_tests" "$failed_tests"
    
    # Affichage du résumé
    show_summary "$total_tests" "$passed_tests" "$failed_tests"
    
    # Affichage des fichiers de rapport
    echo ""
    log_info "📄 Fichiers de rapport disponibles:"
    log_info "   • Rapport principal: $REPORT_FILE"
    log_info "   • Logs détaillés: $LOG_DIR/"
    echo ""
    
    # Code de sortie
    if [ "$failed_tests" -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Exécution du script principal
main "$@"
