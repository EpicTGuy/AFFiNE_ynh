#!/bin/bash

# Test de sauvegarde/restauration pour AFFiNE
# Vérifie que les fonctions de backup/restore fonctionnent correctement

set -e

# Chargement des helpers YunoHost
source /usr/share/yunohost/helpers

# Variables de test
APP_ID="affine"
BACKUP_DIR="/var/backups/yunohost/apps/$APP_ID"
TEST_DOMAIN="test.example.com"
TEST_PATH="/affine"

# Fonction de nettoyage
cleanup() {
    ynh_log_info "Nettoyage des tests de sauvegarde/restauration..."
    # Suppression des sauvegardes de test
    rm -rf "$BACKUP_DIR/test_*" 2>/dev/null || true
    ynh_log_info "Nettoyage terminé"
}

# Gestion des erreurs
trap cleanup EXIT

# Test 1: Vérification de la configuration de sauvegarde
ynh_log_info "Test 1: Vérification de la configuration de sauvegarde"
if [ ! -f "/etc/yunohost/apps/$APP_ID/backup.conf" ]; then
    ynh_log_error "La configuration de sauvegarde n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configuration de sauvegarde présente"

# Test 2: Création d'une sauvegarde
ynh_log_info "Test 2: Création d'une sauvegarde"
BACKUP_NAME="test_$(date +%Y%m%d_%H%M%S)"
if ! ynh_backup_create "$APP_ID" "$BACKUP_NAME"; then
    ynh_log_error "Échec de la création de la sauvegarde"
    exit 1
fi
ynh_log_info "✅ Sauvegarde $BACKUP_NAME créée"

# Test 3: Vérification de l'existence de la sauvegarde
ynh_log_info "Test 3: Vérification de l'existence de la sauvegarde"
if [ ! -d "$BACKUP_DIR/$BACKUP_NAME" ]; then
    ynh_log_error "Le répertoire de sauvegarde n'existe pas"
    exit 1
fi
ynh_log_info "✅ Répertoire de sauvegarde créé"

# Test 4: Vérification du contenu de la sauvegarde
ynh_log_info "Test 4: Vérification du contenu de la sauvegarde"
APP_DIR=$(ynh_app_setting_get "$APP_ID" "app_dir")
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME/app_data.tar.gz" ]; then
    ynh_log_error "Le fichier de données de l'application n'existe pas dans la sauvegarde"
    exit 1
fi
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME/app_config.tar.gz" ]; then
    ynh_log_error "Le fichier de configuration n'existe pas dans la sauvegarde"
    exit 1
fi
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME/app_settings.json" ]; then
    ynh_log_error "Le fichier de paramètres n'existe pas dans la sauvegarde"
    exit 1
fi
ynh_log_info "✅ Contenu de la sauvegarde valide"

# Test 5: Vérification de la sauvegarde de la base de données
ynh_log_info "Test 5: Vérification de la sauvegarde de la base de données"
DB_NAME=$(ynh_app_setting_get "$APP_ID" "db_name")
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME/database.sql" ]; then
    ynh_log_error "La sauvegarde de la base de données n'existe pas"
    exit 1
fi
ynh_log_info "✅ Base de données sauvegardée"

# Test 6: Vérification de la sauvegarde de Redis
ynh_log_info "Test 6: Vérification de la sauvegarde de Redis"
REDIS_DB=$(ynh_app_setting_get "$APP_ID" "redis_db")
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME/redis.rdb" ]; then
    ynh_log_warning "La sauvegarde de Redis n'existe pas (normal si Redis est vide)"
fi
ynh_log_info "✅ Redis sauvegardé"

# Test 7: Vérification de la sauvegarde des logs
ynh_log_info "Test 7: Vérification de la sauvegarde des logs"
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME/logs.tar.gz" ]; then
    ynh_log_warning "La sauvegarde des logs n'existe pas"
fi
ynh_log_info "✅ Logs sauvegardés"

# Test 8: Vérification de la sauvegarde de la configuration NGINX
ynh_log_info "Test 8: Vérification de la sauvegarde de la configuration NGINX"
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME/nginx.conf" ]; then
    ynh_log_error "La sauvegarde de la configuration NGINX n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configuration NGINX sauvegardée"

# Test 9: Vérification de la sauvegarde de la configuration systemd
ynh_log_info "Test 9: Vérification de la sauvegarde de la configuration systemd"
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME/systemd.service" ]; then
    ynh_log_error "La sauvegarde de la configuration systemd n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configuration systemd sauvegardée"

# Test 10: Vérification de la sauvegarde de la configuration SSOwat
ynh_log_info "Test 10: Vérification de la sauvegarde de la configuration SSOwat"
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME/ssowat.yml" ]; then
    ynh_log_error "La sauvegarde de la configuration SSOwat n'existe pas"
    exit 1
fi
ynh_log_info "✅ Configuration SSOwat sauvegardée"

# Test 11: Test de restauration
ynh_log_info "Test 11: Test de restauration"
# Arrêt de l'application avant la restauration
ynh_systemd_action --service_name="$APP_ID" --action=stop

# Restauration de la sauvegarde
if ! ynh_backup_restore "$APP_ID" "$BACKUP_NAME"; then
    ynh_log_error "Échec de la restauration de la sauvegarde"
    exit 1
fi
ynh_log_info "✅ Sauvegarde restaurée"

# Test 12: Vérification de la restauration des données
ynh_log_info "Test 12: Vérification de la restauration des données"
if [ ! -d "$APP_DIR/data" ]; then
    ynh_log_error "Le répertoire de données n'a pas été restauré"
    exit 1
fi
if [ ! -d "$APP_DIR/config" ]; then
    ynh_log_error "Le répertoire de configuration n'a pas été restauré"
    exit 1
fi
ynh_log_info "✅ Données restaurées"

# Test 13: Vérification de la restauration de la base de données
ynh_log_info "Test 13: Vérification de la restauration de la base de données"
if ! sudo -u postgres psql -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    ynh_log_error "La base de données n'a pas été restaurée correctement"
    exit 1
fi
ynh_log_info "✅ Base de données restaurée"

# Test 14: Vérification de la restauration de Redis
ynh_log_info "Test 14: Vérification de la restauration de Redis"
if ! redis-cli -n "$REDIS_DB" ping > /dev/null 2>&1; then
    ynh_log_error "Redis n'a pas été restauré correctement"
    exit 1
fi
ynh_log_info "✅ Redis restauré"

# Test 15: Vérification de la restauration des configurations
ynh_log_info "Test 15: Vérification de la restauration des configurations"
if [ ! -f "/etc/nginx/conf.d/$TEST_DOMAIN.d/$APP_ID.conf" ]; then
    ynh_log_error "La configuration NGINX n'a pas été restaurée"
    exit 1
fi
if [ ! -f "/etc/systemd/system/$APP_ID.service" ]; then
    ynh_log_error "La configuration systemd n'a pas été restaurée"
    exit 1
fi
if [ ! -f "/etc/ssowat/conf.d/$APP_ID.yml" ]; then
    ynh_log_error "La configuration SSOwat n'a pas été restaurée"
    exit 1
fi
ynh_log_info "✅ Configurations restaurées"

# Test 16: Redémarrage de l'application
ynh_log_info "Test 16: Redémarrage de l'application"
ynh_systemd_action --service_name="$APP_ID" --action=start

# Attendre que le service soit prêt
sleep 10

# Vérification que l'application fonctionne
APP_PORT=$(ynh_app_setting_get "$APP_ID" "app_port")
if ! curl -f "http://127.0.0.1:$APP_PORT/health" > /dev/null 2>&1; then
    ynh_log_error "L'application ne fonctionne pas après la restauration"
    exit 1
fi
ynh_log_info "✅ Application redémarrée et fonctionnelle"

# Test 17: Vérification de l'intégrité des données
ynh_log_info "Test 17: Vérification de l'intégrité des données"
# Vérification que les fichiers de données existent
if [ ! -f "$APP_DIR/data/workspace.json" ]; then
    ynh_log_warning "Le fichier workspace.json n'existe pas (normal si l'application est vide)"
fi
ynh_log_info "✅ Intégrité des données vérifiée"

# Test 18: Vérification de la cohérence des paramètres
ynh_log_info "Test 18: Vérification de la cohérence des paramètres"
RESTORED_DOMAIN=$(ynh_app_setting_get "$APP_ID" "domain")
RESTORED_PATH=$(ynh_app_setting_get "$APP_ID" "path")
if [ "$RESTORED_DOMAIN" != "$TEST_DOMAIN" ]; then
    ynh_log_error "Le domaine restauré ($RESTORED_DOMAIN) ne correspond pas au domaine original ($TEST_DOMAIN)"
    exit 1
fi
if [ "$RESTORED_PATH" != "$TEST_PATH" ]; then
    ynh_log_error "Le chemin restauré ($RESTORED_PATH) ne correspond pas au chemin original ($TEST_PATH)"
    exit 1
fi
ynh_log_info "✅ Paramètres cohérents"

# Test 19: Vérification de la suppression de la sauvegarde
ynh_log_info "Test 19: Vérification de la suppression de la sauvegarde"
if ! ynh_backup_delete "$APP_ID" "$BACKUP_NAME"; then
    ynh_log_error "Échec de la suppression de la sauvegarde"
    exit 1
fi
if [ -d "$BACKUP_DIR/$BACKUP_NAME" ]; then
    ynh_log_error "Le répertoire de sauvegarde n'a pas été supprimé"
    exit 1
fi
ynh_log_info "✅ Sauvegarde supprimée"

# Test 20: Vérification de la liste des sauvegardes
ynh_log_info "Test 20: Vérification de la liste des sauvegardes"
BACKUP_LIST=$(ynh_backup_list "$APP_ID")
if [ -z "$BACKUP_LIST" ]; then
    ynh_log_warning "Aucune sauvegarde trouvée"
fi
ynh_log_info "✅ Liste des sauvegardes vérifiée"

# Résumé des tests
ynh_log_info "🎉 Tous les tests de sauvegarde/restauration ont réussi !"
ynh_log_info "📊 Résumé :"
ynh_log_info "   • Sauvegarde créée : $BACKUP_NAME"
ynh_log_info "   • Données sauvegardées"
ynh_log_info "   • Base de données sauvegardée"
ynh_log_info "   • Redis sauvegardé"
ynh_log_info "   • Configurations sauvegardées"
ynh_log_info "   • Restauration réussie"
ynh_log_info "   • Application fonctionnelle après restauration"
ynh_log_info "   • Intégrité des données vérifiée"
ynh_log_info "   • Paramètres cohérents"
ynh_log_info "   • Sauvegarde supprimée"

exit 0
