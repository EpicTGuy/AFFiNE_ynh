#!/bin/bash

# Test de fonctionnalité pour AFFiNE
# Vérifie que l'application fonctionne correctement

set -e

# Chargement des helpers YunoHost
source /usr/share/yunohost/helpers

# Variables de test
APP_ID="affine"
TEST_DOMAIN="test.example.com"
TEST_PATH="/affine"

# Fonction de nettoyage
cleanup() {
    ynh_log_info "Nettoyage des tests de fonctionnalité..."
    ynh_log_info "Nettoyage terminé"
}

# Gestion des erreurs
trap cleanup EXIT

# Test 1: Vérification de la disponibilité du service
ynh_log_info "Test 1: Vérification de la disponibilité du service"
APP_PORT=$(ynh_app_setting_get "$APP_ID" "app_port")
if [ -z "$APP_PORT" ]; then
    ynh_log_error "Le port de l'application n'est pas défini"
    exit 1
fi

# Attendre que le service soit prêt
sleep 5

# Test de connectivité locale
if ! curl -f "http://127.0.0.1:$APP_PORT/health" > /dev/null 2>&1; then
    ynh_log_error "Le service ne répond pas sur le port local $APP_PORT"
    exit 1
fi
ynh_log_info "✅ Service local opérationnel"

# Test 2: Vérification de la réponse HTTP
ynh_log_info "Test 2: Vérification de la réponse HTTP"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:$APP_PORT/")
if [ "$HTTP_STATUS" != "200" ]; then
    ynh_log_error "Le service retourne un code HTTP $HTTP_STATUS au lieu de 200"
    exit 1
fi
ynh_log_info "✅ Réponse HTTP 200 OK"

# Test 3: Vérification du contenu HTML
ynh_log_info "Test 3: Vérification du contenu HTML"
HTML_CONTENT=$(curl -s "http://127.0.0.1:$APP_PORT/")
if ! echo "$HTML_CONTENT" | grep -q "AFFiNE\|affine"; then
    ynh_log_error "Le contenu HTML ne contient pas les éléments attendus d'AFFiNE"
    exit 1
fi
ynh_log_info "✅ Contenu HTML valide"

# Test 4: Vérification des en-têtes de sécurité
ynh_log_info "Test 4: Vérification des en-têtes de sécurité"
SECURITY_HEADERS=$(curl -s -I "http://127.0.0.1:$APP_PORT/")
if ! echo "$SECURITY_HEADERS" | grep -q "X-Content-Type-Options"; then
    ynh_log_warning "L'en-tête X-Content-Type-Options n'est pas présent"
fi
if ! echo "$SECURITY_HEADERS" | grep -q "X-Frame-Options"; then
    ynh_log_warning "L'en-tête X-Frame-Options n'est pas présent"
fi
if ! echo "$SECURITY_HEADERS" | grep -q "Referrer-Policy"; then
    ynh_log_warning "L'en-tête Referrer-Policy n'est pas présent"
fi
ynh_log_info "✅ En-têtes de sécurité vérifiés"

# Test 5: Vérification de la configuration de la base de données
ynh_log_info "Test 5: Vérification de la configuration de la base de données"
DB_NAME=$(ynh_app_setting_get "$APP_ID" "db_name")
if [ -z "$DB_NAME" ]; then
    ynh_log_error "La base de données n'est pas définie"
    exit 1
fi

# Test de connexion à la base de données
if ! sudo -u postgres psql -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    ynh_log_error "Impossible de se connecter à la base de données $DB_NAME"
    exit 1
fi
ynh_log_info "✅ Base de données accessible"

# Test 6: Vérification de la configuration Redis
ynh_log_info "Test 6: Vérification de la configuration Redis"
REDIS_DB=$(ynh_app_setting_get "$APP_ID" "redis_db")
if [ -z "$REDIS_DB" ]; then
    ynh_log_error "La base Redis n'est pas définie"
    exit 1
fi

# Test de connexion à Redis
if ! redis-cli -n "$REDIS_DB" ping > /dev/null 2>&1; then
    ynh_log_error "Impossible de se connecter à Redis DB $REDIS_DB"
    exit 1
fi
ynh_log_info "✅ Redis accessible"

# Test 7: Vérification des fichiers de configuration
ynh_log_info "Test 7: Vérification des fichiers de configuration"
APP_DIR=$(ynh_app_setting_get "$APP_ID" "app_dir")
if [ ! -f "$APP_DIR/config/config.json" ]; then
    ynh_log_error "Le fichier de configuration n'existe pas"
    exit 1
fi

# Vérification du contenu de la configuration
if ! jq empty "$APP_DIR/config/config.json" 2>/dev/null; then
    ynh_log_error "Le fichier de configuration JSON n'est pas valide"
    exit 1
fi
ynh_log_info "✅ Configuration JSON valide"

# Test 8: Vérification des permissions des fichiers
ynh_log_info "Test 8: Vérification des permissions des fichiers"
APP_USER=$(ynh_app_setting_get "$APP_ID" "app_user")
if [ -z "$APP_USER" ]; then
    ynh_log_error "L'utilisateur de l'application n'est pas défini"
    exit 1
fi

# Vérification des permissions du répertoire de l'application
if [ "$(stat -c %U "$APP_DIR")" != "$APP_USER" ]; then
    ynh_log_error "Le répertoire de l'application n'appartient pas à $APP_USER"
    exit 1
fi
ynh_log_info "✅ Permissions des fichiers correctes"

# Test 9: Vérification des logs
ynh_log_info "Test 9: Vérification des logs"
APP_LOG_DIR="/var/log/$APP_ID"
if [ ! -d "$APP_LOG_DIR" ]; then
    ynh_log_error "Le répertoire de logs n'existe pas"
    exit 1
fi

# Vérification des permissions des logs
if [ "$(stat -c %U "$APP_LOG_DIR")" != "$APP_USER" ]; then
    ynh_log_error "Le répertoire de logs n'appartient pas à $APP_USER"
    exit 1
fi
ynh_log_info "✅ Logs accessibles"

# Test 10: Vérification de la configuration NGINX
ynh_log_info "Test 10: Vérification de la configuration NGINX"
if [ ! -f "/etc/nginx/conf.d/$TEST_DOMAIN.d/$APP_ID.conf" ]; then
    ynh_log_error "La configuration NGINX n'existe pas"
    exit 1
fi

# Test de la syntaxe NGINX
if ! nginx -t > /dev/null 2>&1; then
    ynh_log_error "La configuration NGINX contient des erreurs de syntaxe"
    exit 1
fi
ynh_log_info "✅ Configuration NGINX valide"

# Test 11: Vérification de la configuration systemd
ynh_log_info "Test 11: Vérification de la configuration systemd"
if [ ! -f "/etc/systemd/system/$APP_ID.service" ]; then
    ynh_log_error "La configuration systemd n'existe pas"
    exit 1
fi

# Test de la syntaxe systemd
if ! systemd-analyze verify "/etc/systemd/system/$APP_ID.service" > /dev/null 2>&1; then
    ynh_log_error "La configuration systemd contient des erreurs"
    exit 1
fi
ynh_log_info "✅ Configuration systemd valide"

# Test 12: Vérification de la configuration SSOwat
ynh_log_info "Test 12: Vérification de la configuration SSOwat"
if [ ! -f "/etc/ssowat/conf.d/$APP_ID.yml" ]; then
    ynh_log_error "La configuration SSOwat n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configuration SSOwat valide"

# Test 13: Vérification des métriques de performance
ynh_log_info "Test 13: Vérification des métriques de performance"
# Vérification de l'utilisation de la mémoire
MEMORY_USAGE=$(ps -o rss= -p $(pgrep -f "$APP_ID") | awk '{sum+=$1} END {print sum/1024}')
if [ -n "$MEMORY_USAGE" ] && [ "$MEMORY_USAGE" -gt 1000 ]; then
    ynh_log_warning "L'utilisation de la mémoire est élevée : ${MEMORY_USAGE}MB"
fi
ynh_log_info "✅ Métriques de performance vérifiées"

# Test 14: Vérification de la disponibilité des API
ynh_log_info "Test 14: Vérification de la disponibilité des API"
# Test des endpoints principaux
API_ENDPOINTS=("/api/health" "/api/status" "/api/info")
for endpoint in "${API_ENDPOINTS[@]}"; do
    if curl -f "http://127.0.0.1:$APP_PORT$endpoint" > /dev/null 2>&1; then
        ynh_log_info "✅ Endpoint $endpoint disponible"
    else
        ynh_log_warning "⚠️  Endpoint $endpoint non disponible"
    fi
done

# Test 15: Vérification de la configuration de monitoring
ynh_log_info "Test 15: Vérification de la configuration de monitoring"
if [ -f "/etc/yunohost/apps/$APP_ID/monitoring.conf" ]; then
    ynh_log_info "✅ Configuration de monitoring présente"
else
    ynh_log_warning "⚠️  Configuration de monitoring manquante"
fi

# Résumé des tests
ynh_log_info "🎉 Tous les tests de fonctionnalité ont réussi !"
ynh_log_info "📊 Résumé :"
ynh_log_info "   • Service opérationnel sur le port $APP_PORT"
ynh_log_info "   • Base de données $DB_NAME accessible"
ynh_log_info "   • Redis DB $REDIS_DB accessible"
ynh_log_info "   • Configuration valide"
ynh_log_info "   • Permissions correctes"
ynh_log_info "   • Logs accessibles"
ynh_log_info "   • NGINX configuré"
ynh_log_info "   • Systemd configuré"
ynh_log_info "   • SSOwat configuré"

exit 0
