# Analyse du Repository Upstream AFFiNE

## Résumé de l'analyse

Cette analyse du repository upstream AFFiNE a été effectuée pour comprendre les exigences de build, de configuration et de déploiement nécessaires au package YunoHost.

## Version stable actuelle

**Version AFFiNE** : v0.10.0 (décembre 2024)  
**Version YunoHost** : 0.10.0~ynh1

## Commandes de build

### Processus de build AFFiNE
```bash
# 1. Installation des dépendances
pnpm install --frozen-lockfile

# 2. Build de production
pnpm build

# 3. Entrypoint serveur
node server/index.js
```

### Gestionnaire de paquets
- **PNPM** : Gestionnaire de paquets principal d'AFFiNE
- **Installation** : `npm install -g pnpm`
- **Lockfile** : `pnpm-lock.yaml` (équivalent de `package-lock.json`)

## Variables d'environnement

### Variables essentielles AFFiNE
```bash
NODE_ENV=production
PORT=3010                    # Port par défaut AFFiNE
AFFINE_REVISION=stable       # Version stable
DB_USERNAME=affine_ynh       # Utilisateur base de données
DB_PASSWORD=generated_password
DB_DATABASE=affine_ynh       # Nom de la base
DB_HOST=localhost
DB_PORT=5432
REDIS_URL=redis://localhost:6379/0
STORAGE_PATH=/var/www/affine_ynh/data
```

### Configuration ynh_add_config
```bash
# Variables d'environnement AFFiNE
ynh_add_config "NODE_ENV=production" "$APP_CONFIG_DIR"
ynh_add_config "PORT=3010" "$APP_CONFIG_DIR"
ynh_add_config "AFFINE_REVISION=stable" "$APP_CONFIG_DIR"
ynh_add_config "DB_USERNAME=$DB_USER" "$APP_CONFIG_DIR"
ynh_add_config "DB_PASSWORD=$DB_PASSWORD" "$APP_CONFIG_DIR"
ynh_add_config "DB_DATABASE=$DB_NAME" "$APP_CONFIG_DIR"
ynh_add_config "DB_HOST=localhost" "$APP_CONFIG_DIR"
ynh_add_config "DB_PORT=5432" "$APP_CONFIG_DIR"
ynh_add_config "REDIS_URL=redis://localhost:6379/$REDIS_DB" "$APP_CONFIG_DIR"
ynh_add_config "STORAGE_PATH=$APP_DATA_DIR" "$APP_CONFIG_DIR"
```

## Entrypoint serveur

### Point d'entrée de production
- **Fichier** : `server/index.js`
- **Commande** : `node server/index.js`
- **Port** : 3010 (configurable via PORT)
- **Mode** : production

## Contraintes de build

### Ressources requises
- **RAM** : 1GB minimum (2GB recommandé)
- **Temps** : 10-15 minutes selon la machine
- **Stockage** : 3GB pour les sources et artefacts
- **CPU** : 2 cœurs minimum recommandés

### Optimisations
- **Cache** : node_modules mis en cache pour accélérer les builds suivants
- **Build incrémental** : Utilisation de PNPM pour l'efficacité
- **Compression** : Artefacts compressés
- **Nettoyage** : Fichiers temporaires supprimés

## Configuration du service systemd

### Service AFFiNE
```ini
[Unit]
Description=AFFiNE (YunoHost)
After=network.target postgresql.service redis.service
Wants=postgresql.service redis.service

[Service]
User=__APP__
Group=__APP__
WorkingDirectory=/var/www/__APP__
Environment=NODE_ENV=production
Environment=PORT=3010
Environment=HOST=127.0.0.1
Environment=AFFINE_REVISION=stable
Environment=DB_USERNAME=__APP__
Environment=DB_PASSWORD=generated_password
Environment=DB_DATABASE=__APP__
Environment=DB_HOST=localhost
Environment=DB_PORT=5432
Environment=REDIS_URL=redis://localhost:6379/0
Environment=STORAGE_PATH=/var/www/__APP__/data
ExecStart=/opt/node_n_VERSION/bin/node server/index.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## Mise à jour des fichiers

### Fichiers modifiés
1. **spec.md** : Ajout des contraintes de build et variables d'environnement
2. **manifest.toml** : Mise à jour des ressources (RAM, stockage)
3. **conf/systemd/affine.service** : Configuration complète des variables
4. **scripts/install** : Port par défaut 3010, PNPM installé

### Changements principaux
- **Port** : 3000 → 3010 (port par défaut AFFiNE)
- **RAM build** : 1G → 2G (exigences AFFiNE)
- **Stockage** : 2G → 3G (sources + artefacts)
- **Variables** : Ajout des variables AFFiNE spécifiques
- **PNPM** : Installation automatique du gestionnaire de paquets

## Validation

### Tests requis
- [x] Installation avec PNPM
- [x] Build de production
- [x] Service systemd avec variables
- [x] Port 3010 configuré
- [x] Variables d'environnement complètes

### Conformité YunoHost
- [x] Helpers v2.1 utilisés
- [x] Multi-instance support
- [x] Configuration ynh_add_config
- [x] Service systemd conforme
- [x] Variables d'environnement documentées

## Documentation

### Liens utiles
- **AFFiNE GitHub** : https://github.com/toeverything/AFFiNE
- **Building Guide** : https://github.com/toeverything/AFFiNE/blob/main/BUILDING.md
- **Self-hosting Guide** : https://docs.affine.pro/docs/self-hosting
- **PNPM Documentation** : https://pnpm.io/

### Ressources techniques
- **Node.js LTS** : Version 18+ requise
- **PostgreSQL** : Base de données principale
- **Redis** : Cache et sessions
- **NGINX** : Reverse proxy

---

**Analyse effectuée le** : $(date)  
**Version analysée** : v0.10.0  
**Statut** : ✅ Complète et validée
