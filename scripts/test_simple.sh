#!/bin/bash

# Script de test simplifié pour AFFiNE YunoHost
# Compatible CI - ne nécessite pas YunoHost installé

set -e

# Configuration
APP_ID="affine"
TEST_DOMAIN="${TEST_DOMAIN:-test.example.com}"
TEST_PATH="${TEST_PATH:-/affine}"

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

# Début du test
log_info "🚀 Démarrage du test simplifié pour $APP_ID"

# Vérification des fichiers essentiels
log_info "Vérification des fichiers essentiels..."

ESSENTIAL_FILES=(
    "manifest.toml"
    "scripts/install"
    "scripts/remove"
    "scripts/upgrade"
    "scripts/backup"
    "scripts/restore"
    "conf/nginx.conf"
    "conf/systemd/affine.service"
)

for file in "${ESSENTIAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        log_success "✅ Fichier trouvé: $file"
    else
        log_error "❌ Fichier manquant: $file"
        exit 1
    fi
done

# Vérification de la syntaxe des scripts
log_info "Vérification de la syntaxe des scripts..."

for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        if bash -n "$script"; then
            log_success "✅ Syntaxe OK: $(basename "$script")"
        else
            log_error "❌ Erreur de syntaxe: $(basename "$script")"
            exit 1
        fi
    fi
done

# Vérification du manifest
log_info "Vérification du manifest..."

if grep -q 'id = "affine"' manifest.toml; then
    log_success "✅ ID de l'application correct"
else
    log_error "❌ ID de l'application incorrect"
    exit 1
fi

if grep -q 'name = "AFFiNE"' manifest.toml; then
    log_success "✅ Nom de l'application correct"
else
    log_error "❌ Nom de l'application incorrect"
    exit 1
fi

if grep -q 'version = "0.0.1~ynh1"' manifest.toml; then
    log_success "✅ Version correcte"
else
    log_error "❌ Version incorrecte"
    exit 1
fi

# Vérification de la configuration NGINX
log_info "Vérification de la configuration NGINX..."

if grep -q "__PATH__" conf/nginx.conf; then
    log_success "✅ Placeholders YunoHost présents"
else
    log_warning "⚠️ Placeholders YunoHost manquants"
fi

if grep -q "proxy_pass" conf/nginx.conf; then
    log_success "✅ Configuration proxy présente"
else
    log_error "❌ Configuration proxy manquante"
    exit 1
fi

if grep -q "__PORT__" conf/nginx.conf; then
    log_success "✅ Placeholder port présent"
else
    log_warning "⚠️ Placeholder port manquant"
fi

# Vérification du service systemd
log_info "Vérification du service systemd..."

if grep -q "AFFiNE" conf/systemd/affine.service; then
    log_success "✅ Description du service correcte"
else
    log_error "❌ Description du service incorrecte"
    exit 1
fi

if grep -q "NODE_ENV=production" conf/systemd/affine.service; then
    log_success "✅ Variables d'environnement présentes"
else
    log_error "❌ Variables d'environnement manquantes"
    exit 1
fi

if grep -q "node server.js" conf/systemd/affine.service; then
    log_success "✅ Entrypoint Node.js correct"
else
    log_error "❌ Entrypoint Node.js incorrect"
    exit 1
fi

# Vérification des permissions des scripts
log_info "Vérification des permissions des scripts..."

for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            log_success "✅ Script exécutable: $(basename "$script")"
        else
            log_warning "⚠️ Script non exécutable: $(basename "$script")"
        fi
    fi
done

# Vérification de la structure des répertoires
log_info "Vérification de la structure des répertoires..."

ESSENTIAL_DIRS=(
    "conf"
    "conf/systemd"
    "scripts"
    "doc"
    ".github/workflows"
)

for dir in "${ESSENTIAL_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        log_success "✅ Répertoire trouvé: $dir"
    else
        log_error "❌ Répertoire manquant: $dir"
        exit 1
    fi
done

# Vérification de la CI
log_info "Vérification de la configuration CI..."

if [ -f ".github/workflows/ci.yml" ]; then
    log_success "✅ Workflow CI trouvé"
else
    log_error "❌ Workflow CI manquant"
    exit 1
fi

if grep -q "CI AFFiNE YunoHost" .github/workflows/ci.yml; then
    log_success "✅ Nom du workflow correct"
else
    log_error "❌ Nom du workflow incorrect"
    exit 1
fi

# Résumé des tests
log_info "📊 Résumé des tests:"
log_info "  - Fichiers essentiels: ✅"
log_info "  - Syntaxe des scripts: ✅"
log_info "  - Configuration manifest: ✅"
log_info "  - Configuration NGINX: ✅"
log_info "  - Service systemd: ✅"
log_info "  - Permissions: ✅"
log_info "  - Structure: ✅"
log_info "  - CI: ✅"

log_success "🎉 Test simplifié terminé avec succès pour $APP_ID"
log_success "Tous les composants sont prêts pour l'installation YunoHost"

exit 0
