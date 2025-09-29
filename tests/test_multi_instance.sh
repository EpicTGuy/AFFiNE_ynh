#!/bin/bash

# Test multi-instance pour AFFiNE
# Vérifie que plusieurs instances peuvent coexister

set -e

# Chargement des helpers YunoHost
source /usr/share/yunohost/helpers

# Variables de test
APP_ID="affine"
TEST_DOMAIN="test.example.com"
TEST_PATH1="/affine1"
TEST_PATH2="/affine2"
TEST_IS_PUBLIC="false"

# Fonction de nettoyage
cleanup() {
    ynh_log_info "Nettoyage des tests multi-instance..."
    ynh_app_remove "${APP_ID}_1" 2>/dev/null || true
    ynh_app_remove "${APP_ID}_2" 2>/dev/null || true
    ynh_log_info "Nettoyage terminé"
}

# Gestion des erreurs
trap cleanup EXIT

# Test 1: Vérification du support multi-instance dans le manifest
ynh_log_info "Test 1: Vérification du support multi-instance dans le manifest"
if ! grep -q "multi_instance = true" "/etc/yunohost/apps/$APP_ID/manifest.toml"; then
    ynh_log_error "Le support multi-instance n'est pas activé dans le manifest"
    exit 1
fi
ynh_log_info "✅ Support multi-instance activé"

# Test 2: Installation de la première instance
ynh_log_info "Test 2: Installation de la première instance"
if ! ynh_app_install "${APP_ID}_1" --domain "$TEST_DOMAIN" --path "$TEST_PATH1" --is_public "$TEST_IS_PUBLIC"; then
    ynh_log_error "Échec de l'installation de la première instance"
    exit 1
fi
ynh_log_info "✅ Première instance installée"

# Test 3: Vérification de la première instance
ynh_log_info "Test 3: Vérification de la première instance"
if ! systemctl is-active --quiet "${APP_ID}_1"; then
    ynh_log_error "La première instance n'est pas active"
    exit 1
fi
ynh_log_info "✅ Première instance active"

# Test 4: Installation de la deuxième instance
ynh_log_info "Test 4: Installation de la deuxième instance"
if ! ynh_app_install "${APP_ID}_2" --domain "$TEST_DOMAIN" --path "$TEST_PATH2" --is_public "$TEST_IS_PUBLIC"; then
    ynh_log_error "Échec de l'installation de la deuxième instance"
    exit 1
fi
ynh_log_info "✅ Deuxième instance installée"

# Test 5: Vérification de la deuxième instance
ynh_log_info "Test 5: Vérification de la deuxième instance"
if ! systemctl is-active --quiet "${APP_ID}_2"; then
    ynh_log_error "La deuxième instance n'est pas active"
    exit 1
fi
ynh_log_info "✅ Deuxième instance active"

# Test 6: Vérification des ports différents
ynh_log_info "Test 6: Vérification des ports différents"
PORT1=$(ynh_app_setting_get "${APP_ID}_1" "app_port")
PORT2=$(ynh_app_setting_get "${APP_ID}_2" "app_port")
if [ -z "$PORT1" ] || [ -z "$PORT2" ]; then
    ynh_log_error "Les ports des instances ne sont pas définis"
    exit 1
fi
if [ "$PORT1" = "$PORT2" ]; then
    ynh_log_error "Les deux instances utilisent le même port ($PORT1)"
    exit 1
fi
ynh_log_info "✅ Ports différents : $PORT1 et $PORT2"

# Test 7: Vérification des bases de données différentes
ynh_log_info "Test 7: Vérification des bases de données différentes"
DB1=$(ynh_app_setting_get "${APP_ID}_1" "db_name")
DB2=$(ynh_app_setting_get "${APP_ID}_2" "db_name")
if [ -z "$DB1" ] || [ -z "$DB2" ]; then
    ynh_log_error "Les bases de données des instances ne sont pas définies"
    exit 1
fi
if [ "$DB1" = "$DB2" ]; then
    ynh_log_error "Les deux instances utilisent la même base de données ($DB1)"
    exit 1
fi
ynh_log_info "✅ Bases de données différentes : $DB1 et $DB2"

# Test 8: Vérification des utilisateurs différents
ynh_log_info "Test 8: Vérification des utilisateurs différents"
USER1=$(ynh_app_setting_get "${APP_ID}_1" "app_user")
USER2=$(ynh_app_setting_get "${APP_ID}_2" "app_user")
if [ -z "$USER1" ] || [ -z "$USER2" ]; then
    ynh_log_error "Les utilisateurs des instances ne sont pas définis"
    exit 1
fi
if [ "$USER1" = "$USER2" ]; then
    ynh_log_error "Les deux instances utilisent le même utilisateur ($USER1)"
    exit 1
fi
ynh_log_info "✅ Utilisateurs différents : $USER1 et $USER2"

# Test 9: Vérification des répertoires différents
ynh_log_info "Test 9: Vérification des répertoires différents"
DIR1=$(ynh_app_setting_get "${APP_ID}_1" "app_dir")
DIR2=$(ynh_app_setting_get "${APP_ID}_2" "app_dir")
if [ -z "$DIR1" ] || [ -z "$DIR2" ]; then
    ynh_log_error "Les répertoires des instances ne sont pas définis"
    exit 1
fi
if [ "$DIR1" = "$DIR2" ]; then
    ynh_log_error "Les deux instances utilisent le même répertoire ($DIR1)"
    exit 1
fi
ynh_log_info "✅ Répertoires différents : $DIR1 et $DIR2"

# Test 10: Vérification des configurations NGINX différentes
ynh_log_info "Test 10: Vérification des configurations NGINX différentes"
if [ ! -f "/etc/nginx/conf.d/$TEST_DOMAIN.d/${APP_ID}_1.conf" ]; then
    ynh_log_error "La configuration NGINX de la première instance n'existe pas"
    exit 1
fi
if [ ! -f "/etc/nginx/conf.d/$TEST_DOMAIN.d/${APP_ID}_2.conf" ]; then
    ynh_log_error "La configuration NGINX de la deuxième instance n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configurations NGINX différentes"

# Test 11: Vérification des configurations systemd différentes
ynh_log_info "Test 11: Vérification des configurations systemd différentes"
if [ ! -f "/etc/systemd/system/${APP_ID}_1.service" ]; then
    ynh_log_error "La configuration systemd de la première instance n'existe pas"
    exit 1
fi
if [ ! -f "/etc/systemd/system/${APP_ID}_2.service" ]; then
    ynh_log_error "La configuration systemd de la deuxième instance n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configurations systemd différentes"

# Test 12: Vérification des configurations SSOwat différentes
ynh_log_info "Test 12: Vérification des configurations SSOwat différentes"
if [ ! -f "/etc/ssowat/conf.d/${APP_ID}_1.yml" ]; then
    ynh_log_error "La configuration SSOwat de la première instance n'existe pas"
    exit 1
fi
if [ ! -f "/etc/ssowat/conf.d/${APP_ID}_2.yml" ]; then
    ynh_log_error "La configuration SSOwat de la deuxième instance n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configurations SSOwat différentes"

# Test 13: Vérification de la connectivité des instances
ynh_log_info "Test 13: Vérification de la connectivité des instances"
if ! curl -f "http://127.0.0.1:$PORT1/health" > /dev/null 2>&1; then
    ynh_log_error "La première instance ne répond pas sur le port $PORT1"
    exit 1
fi
if ! curl -f "http://127.0.0.1:$PORT2/health" > /dev/null 2>&1; then
    ynh_log_error "La deuxième instance ne répond pas sur le port $PORT2"
    exit 1
fi
ynh_log_info "✅ Les deux instances sont accessibles"

# Test 14: Vérification de l'isolation des données
ynh_log_info "Test 14: Vérification de l'isolation des données"
# Création d'un fichier de test dans la première instance
echo "test_data_1" > "$DIR1/data/test.txt"
# Vérification que le fichier n'existe pas dans la deuxième instance
if [ -f "$DIR2/data/test.txt" ]; then
    ynh_log_error "Les données des instances ne sont pas isolées"
    exit 1
fi
ynh_log_info "✅ Données isolées"

# Test 15: Vérification de l'isolation des bases de données
ynh_log_info "Test 15: Vérification de l'isolation des bases de données"
# Création d'une table de test dans la première instance
sudo -u postgres psql -d "$DB1" -c "CREATE TABLE test_table (id SERIAL PRIMARY KEY, data TEXT);"
sudo -u postgres psql -d "$DB1" -c "INSERT INTO test_table (data) VALUES ('test_data_1');"
# Vérification que la table n'existe pas dans la deuxième instance
if sudo -u postgres psql -d "$DB2" -c "SELECT * FROM test_table;" > /dev/null 2>&1; then
    ynh_log_error "Les bases de données des instances ne sont pas isolées"
    exit 1
fi
ynh_log_info "✅ Bases de données isolées"

# Test 16: Vérification de l'isolation de Redis
ynh_log_info "Test 16: Vérification de l'isolation de Redis"
REDIS1=$(ynh_app_setting_get "${APP_ID}_1" "redis_db")
REDIS2=$(ynh_app_setting_get "${APP_ID}_2" "redis_db")
if [ "$REDIS1" = "$REDIS2" ]; then
    ynh_log_error "Les deux instances utilisent la même base Redis ($REDIS1)"
    exit 1
fi
ynh_log_info "✅ Bases Redis isolées : $REDIS1 et $REDIS2"

# Test 17: Vérification de l'isolation des logs
ynh_log_info "Test 17: Vérification de l'isolation des logs"
LOG1="/var/log/${APP_ID}_1"
LOG2="/var/log/${APP_ID}_2"
if [ ! -d "$LOG1" ] || [ ! -d "$LOG2" ]; then
    ynh_log_error "Les répertoires de logs des instances n'existent pas"
    exit 1
fi
if [ "$LOG1" = "$LOG2" ]; then
    ynh_log_error "Les deux instances utilisent le même répertoire de logs"
    exit 1
fi
ynh_log_info "✅ Logs isolés"

# Test 18: Vérification de la gestion des erreurs
ynh_log_info "Test 18: Vérification de la gestion des erreurs"
# Arrêt de la première instance
ynh_systemd_action --service_name="${APP_ID}_1" --action=stop
# Vérification que la deuxième instance continue de fonctionner
if ! curl -f "http://127.0.0.1:$PORT2/health" > /dev/null 2>&1; then
    ynh_log_error "La deuxième instance s'est arrêtée quand la première a été arrêtée"
    exit 1
fi
ynh_log_info "✅ Gestion des erreurs correcte"

# Test 19: Vérification de la récupération
ynh_log_info "Test 19: Vérification de la récupération"
# Redémarrage de la première instance
ynh_systemd_action --service_name="${APP_ID}_1" --action=start
sleep 5
# Vérification que les deux instances fonctionnent
if ! curl -f "http://127.0.0.1:$PORT1/health" > /dev/null 2>&1; then
    ynh_log_error "La première instance ne s'est pas redémarrée correctement"
    exit 1
fi
if ! curl -f "http://127.0.0.1:$PORT2/health" > /dev/null 2>&1; then
    ynh_log_error "La deuxième instance ne fonctionne plus après le redémarrage de la première"
    exit 1
fi
ynh_log_info "✅ Récupération correcte"

# Test 20: Vérification de la suppression d'une instance
ynh_log_info "Test 20: Vérification de la suppression d'une instance"
# Suppression de la première instance
if ! ynh_app_remove "${APP_ID}_1"; then
    ynh_log_error "Échec de la suppression de la première instance"
    exit 1
fi
# Vérification que la deuxième instance continue de fonctionner
if ! curl -f "http://127.0.0.1:$PORT2/health" > /dev/null 2>&1; then
    ynh_log_error "La deuxième instance s'est arrêtée lors de la suppression de la première"
    exit 1
fi
ynh_log_info "✅ Suppression d'instance correcte"

# Résumé des tests
ynh_log_info "🎉 Tous les tests multi-instance ont réussi !"
ynh_log_info "📊 Résumé :"
ynh_log_info "   • Support multi-instance activé"
ynh_log_info "   • Deux instances installées et fonctionnelles"
ynh_log_info "   • Ports différents : $PORT1 et $PORT2"
ynh_log_info "   • Bases de données différentes : $DB1 et $DB2"
ynh_log_info "   • Utilisateurs différents : $USER1 et $USER2"
ynh_log_info "   • Répertoires différents : $DIR1 et $DIR2"
ynh_log_info "   • Configurations isolées"
ynh_log_info "   • Données isolées"
ynh_log_info "   • Bases de données isolées"
ynh_log_info "   • Bases Redis isolées"
ynh_log_info "   • Logs isolés"
ynh_log_info "   • Gestion des erreurs correcte"
ynh_log_info "   • Récupération correcte"
ynh_log_info "   • Suppression d'instance correcte"

exit 0
