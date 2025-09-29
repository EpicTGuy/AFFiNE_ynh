#!/bin/bash

# Script principal de test pour AFFiNE
# Exécute tous les tests et génère un rapport

set -e

# Chargement des helpers YunoHost
source /usr/share/yunohost/helpers

# Variables de test
APP_ID="affine"
TEST_DOMAIN="test.example.com"
TEST_PATH="/affine"
TEST_IS_PUBLIC="false"

# Répertoire de test
TEST_DIR="/tmp/affine_tests"
REPORT_FILE="$TEST_DIR/test_report.txt"

# Fonction de nettoyage
cleanup() {
    ynh_log_info "Nettoyage des tests..."
    ynh_app_remove "$APP_ID" 2>/dev/null || true
    ynh_app_remove "${APP_ID}_1" 2>/dev/null || true
    ynh_app_remove "${APP_ID}_2" 2>/dev/null || true
    rm -rf "$TEST_DIR" 2>/dev/null || true
    ynh_log_info "Nettoyage terminé"
}

# Gestion des erreurs
trap cleanup EXIT

# Création du répertoire de test
mkdir -p "$TEST_DIR"

# Initialisation du rapport
echo "=== RAPPORT DE TEST AFFiNE ===" > "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "Domaine de test: $TEST_DOMAIN" >> "$REPORT_FILE"
echo "Chemin de test: $TEST_PATH" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Fonction pour exécuter un test
run_test() {
    local test_name="$1"
    local test_script="$2"
    local start_time=$(date +%s)
    
    echo "🧪 Exécution du test: $test_name"
    echo "Test: $test_name" >> "$REPORT_FILE"
    echo "Début: $(date)" >> "$REPORT_FILE"
    
    if bash "$test_script" >> "$REPORT_FILE" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        echo "✅ $test_name: RÉUSSI (${duration}s)"
        echo "Résultat: RÉUSSI (${duration}s)" >> "$REPORT_FILE"
        echo "Status: SUCCESS" >> "$REPORT_FILE"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        echo "❌ $test_name: ÉCHEC (${duration}s)"
        echo "Résultat: ÉCHEC (${duration}s)" >> "$REPORT_FILE"
        echo "Status: FAILED" >> "$REPORT_FILE"
        return 1
    fi
    
    echo "" >> "$REPORT_FILE"
}

# Fonction pour vérifier les prérequis
check_prerequisites() {
    echo "🔍 Vérification des prérequis..."
    
    # Vérification de YunoHost
    if ! command -v yunohost &> /dev/null; then
        echo "❌ YunoHost n'est pas installé"
        return 1
    fi
    
    # Vérification de Node.js
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js n'est pas installé"
        return 1
    fi
    
    # Vérification de NGINX
    if ! command -v nginx &> /dev/null; then
        echo "❌ NGINX n'est pas installé"
        return 1
    fi
    
    # Vérification de PostgreSQL
    if ! command -v psql &> /dev/null; then
        echo "❌ PostgreSQL n'est pas installé"
        return 1
    fi
    
    # Vérification de Redis
    if ! command -v redis-cli &> /dev/null; then
        echo "❌ Redis n'est pas installé"
        return 1
    fi
    
    echo "✅ Tous les prérequis sont satisfaits"
    return 0
}

# Fonction pour afficher le résumé
show_summary() {
    local total_tests="$1"
    local passed_tests="$2"
    local failed_tests="$3"
    
    echo ""
    echo "📊 RÉSUMÉ DES TESTS"
    echo "=================="
    echo "Total des tests: $total_tests"
    echo "Tests réussis: $passed_tests"
    echo "Tests échoués: $failed_tests"
    echo "Taux de réussite: $((passed_tests * 100 / total_tests))%"
    echo ""
    
    if [ "$failed_tests" -eq 0 ]; then
        echo "🎉 Tous les tests ont réussi !"
        echo "✅ Le package AFFiNE est prêt pour la production"
    else
        echo "⚠️  $failed_tests test(s) ont échoué"
        echo "❌ Le package AFFiNE nécessite des corrections"
    fi
}

# Fonction principale
main() {
    echo "🚀 DÉMARRAGE DES TESTS AFFiNE"
    echo "============================="
    echo ""
    
    # Vérification des prérequis
    if ! check_prerequisites; then
        echo "❌ Les prérequis ne sont pas satisfaits"
        exit 1
    fi
    
    # Compteurs de tests
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    
    # Liste des tests à exécuter
    local tests=(
        "Installation" "test_install.sh"
        "Fonctionnalité" "test_functionality.sh"
        "Sauvegarde/Restauration" "test_backup_restore.sh"
        "Multi-instance" "test_multi_instance.sh"
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
        
        echo ""
    done
    
    # Affichage du résumé
    show_summary "$total_tests" "$passed_tests" "$failed_tests"
    
    # Affichage du rapport
    echo ""
    echo "📄 Rapport détaillé disponible dans: $REPORT_FILE"
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
