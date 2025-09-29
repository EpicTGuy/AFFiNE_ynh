# Spécifications techniques - Package YunoHost AFFiNE

## 1. Vue d'ensemble

### 1.1 Description de l'application
**AFFiNE** est un workspace open-source auto-hébergeable combinant :
- **Documentation collaborative** : Éditeur de documents riche avec support Markdown
- **Whiteboard** : Tableau blanc interactif pour la collaboration visuelle
- **Gestion de projet** : Outils de planification et d'organisation
- **Base de données** : Système de stockage structuré pour les connaissances

### 1.2 Public cible
- **Individus** : Utilisateurs souhaitant un workspace personnel auto-hébergé
- **Petites équipes** : Groupes de 2-20 personnes sur infrastructure YunoHost
- **Organisations** : Entités privilégiant la souveraineté des données

### 1.3 Valeur ajoutée YunoHost
- Installation simplifiée en un clic
- Intégration native avec l'écosystème YunoHost
- Gestion centralisée des utilisateurs via SSOwat
- Sauvegarde et maintenance automatisées
- Support multi-instance pour l'isolation des projets

## 2. Contraintes techniques YunoHost

### 2.1 Packaging v2
- **Structure** : Conforme à [YunoHost Packaging v2](https://yunohost.org/packaging_apps)
- **Manifest** : `manifest.toml` v2 avec métadonnées complètes
- **Scripts** : `install`, `remove`, `upgrade`, `backup`, `restore`
- **Helpers** : Utilisation exclusive des helpers v2.1

### 2.2 Multi-instance
- **Support** : Jusqu'à 10 instances par serveur
- **Isolation** : Ports, bases de données et configurations séparés
- **Gestion** : Scripts adaptatifs selon l'instance

### 2.3 Infrastructure
- **NGINX** : Reverse proxy avec configuration automatique
- **SSOwat** : Intégration optionnelle pour l'authentification
- **IPv6** : Support natif IPv6
- **Architectures** : ARM64 et AMD64

### 2.4 Ressources d'application v2
- **CPU** : Limitation configurable (défaut : 50%)
- **RAM** : Limite de 1GB (configurable)
- **Stockage** : Quota utilisateur respecté
- **Réseau** : Bandwidth limiting disponible

## 3. Architecture d'installation

### 3.1 Mode d'installation : NATIF
**Principe** : Installation native sans conteneurisation Docker
- **Avantages** : Performance optimale, intégration système native
- **Inconvénients** : Gestion des dépendances plus complexe
- **Justification** : Meilleure intégration avec l'écosystème YunoHost

### 3.2 Sources et versioning
```toml
[resources.sources]
main = "https://github.com/toeverything/AFFiNE/releases/download/v0.10.0/affine-v0.10.0-linux-x64.tar.gz"
checksum = "sha256:abc123def456..."
architecture = ["amd64", "arm64"]
```

**Version stable actuelle** : v0.10.0 (décembre 2024)
**Version YunoHost** : 0.10.0~ynh1

**Stratégie de versioning** :
- **Pin sur tag** : Version spécifique (ex: v0.10.0)
- **Checksum** : Vérification d'intégrité SHA256
- **Architecture** : Binaires pré-compilés pour ARM64/AMD64

### 3.3 Processus de build
```bash
# 1. Installation Node.js LTS
ynh_nodejs_install 18

# 2. Installation PNPM (gestionnaire de paquets)
npm install -g pnpm

# 3. Téléchargement des sources
ynh_setup_source "$APP_SOURCE_DIR" "$SOURCE_URL" "$SOURCE_CHECKSUM"

# 4. Build de production AFFiNE
cd "$APP_SOURCE_DIR"
pnpm install --frozen-lockfile
pnpm build

# 5. Installation des artefacts dans /var/www/__APP__
ynh_exec_as "$APP_USER" cp -r dist/* "$APP_WWW_DIR"
```

**Commandes de build AFFiNE** :
- `pnpm install --frozen-lockfile` : Installation des dépendances
- `pnpm build` : Build de production
- **Entrypoint** : `server/index.js` (serveur Node.js)
- **Port par défaut** : 3010 (configurable via PORT)

### 3.4 Structure des répertoires
```
/var/www/affine_ynh/
├── app/                    # Application compilée
├── data/                   # Données persistantes
│   ├── workspaces/         # Espaces de travail
│   ├── uploads/            # Fichiers uploadés
│   └── cache/              # Cache applicatif
├── config/                 # Configuration
│   ├── config.json         # Configuration principale
│   └── env.production      # Variables d'environnement
└── logs/                   # Logs applicatifs

## 4. Configuration du service

### 4.1 Service systemd
```ini
[Unit]
Description=AFFiNE Workspace
After=network.target postgresql.service redis.service
Wants=postgresql.service redis.service

[Service]
Type=simple
User=affine_ynh
Group=affine_ynh
WorkingDirectory=/var/www/affine_ynh/app
ExecStart=/usr/bin/node server/index.js
Environment=NODE_ENV=production
Environment=PORT=3010
Environment=HOST=127.0.0.1
Environment=AFFINE_REVISION=stable
Environment=DB_USERNAME=affine_ynh
Environment=DB_PASSWORD=generated_password
Environment=DB_DATABASE=affine_ynh
Environment=DB_HOST=localhost
Environment=DB_PORT=5432
Environment=REDIS_URL=redis://localhost:6379/0
Environment=STORAGE_PATH=/var/www/affine_ynh/data
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 4.2 Variables d'environnement
```bash
NODE_ENV=production
PORT=3010
HOST=127.0.0.1
AFFINE_REVISION=stable
DB_USERNAME=affine_ynh
DB_PASSWORD=generated_password
DB_DATABASE=affine_ynh
DB_HOST=localhost
DB_PORT=5432
REDIS_URL=redis://localhost:6379/0
STORAGE_PATH=/var/www/affine_ynh/data
LOG_LEVEL=info
```

**Variables d'environnement AFFiNE** :
- `NODE_ENV=production` : Mode production
- `PORT=3010` : Port du serveur (par défaut AFFiNE)
- `AFFINE_REVISION=stable` : Version stable
- `DB_*` : Configuration base de données PostgreSQL
- `REDIS_URL` : URL Redis pour le cache
- `STORAGE_PATH` : Répertoire de stockage des données

## 5. Configuration NGINX

### 5.1 Configuration de base
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name __DOMAIN__;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name __DOMAIN__;
    
    # Configuration SSL
    ssl_certificate /etc/yunohost/certs/__DOMAIN__/crt.pem;
    ssl_certificate_key /etc/yunohost/certs/__DOMAIN__/key.pem;
    
    # Headers de sécurité
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Configuration WebSocket
    location /ws {
        proxy_pass http://127.0.0.1:__PORT__;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Configuration de l'application
    location / {
        proxy_pass http://127.0.0.1:__PORT__;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 5.2 Compatibilité sous-chemin et racine
- **Racine** : `https://domain.com/` (mode par défaut)
- **Sous-chemin** : `https://domain.com/affine/` (mode optionnel)
- **Configuration** : Adaptative selon le paramètre `path`

## 6. Gestion des données persistantes

### 6.1 Répertoires de données
```toml
[resources]
data = "/var/www/affine_ynh/data"
config = "/var/www/affine_ynh/config"
logs = "/var/log/affine_ynh"
```

### 6.2 Types de données
- **Workspaces** : Espaces de travail utilisateur
- **Documents** : Contenu des documents
- **Uploads** : Fichiers uploadés
- **Cache** : Cache applicatif
- **Configuration** : Paramètres utilisateur

### 6.3 Permissions
```bash
# Utilisateur système
chown -R affine_ynh:affine_ynh /var/www/affine_ynh
chmod -R 750 /var/www/affine_ynh/data
chmod -R 750 /var/www/affine_ynh/config
```

## 7. Contraintes de build et performance

### 7.1 Contraintes de build
- **RAM** : 1GB minimum pour le build (2GB recommandé)
- **Temps** : 10-15 minutes selon la machine
- **Stockage** : 3GB pour les sources et artefacts
- **CPU** : 2 cœurs minimum recommandés
- **Cache** : node_modules mis en cache pour accélérer les builds suivants

**Optimisations** :
- Cache des dépendances Node.js
- Build en mode production uniquement
- Compression des artefacts
- Nettoyage des fichiers temporaires

### 7.2 Configuration ynh_add_config
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

## 8. Backup et Restore

### 8.1 Stratégie de sauvegarde
```bash
# Fichiers de données
tar -czf backup_data.tar.gz /var/www/affine_ynh/data

# Configuration
tar -czf backup_config.tar.gz /var/www/affine_ynh/config

# Base de données
pg_dump affine_ynh > backup_database.sql

# Service systemd
cp /etc/systemd/system/affine_ynh.service backup_service.service

# Configuration NGINX
cp /etc/nginx/sites-available/affine_ynh backup_nginx.conf
```

### 8.2 Restauration
```bash
# Restauration des fichiers
tar -xzf backup_data.tar.gz -C /
tar -xzf backup_config.tar.gz -C /

# Restauration de la base de données
psql affine_ynh < backup_database.sql

# Restauration des services
systemctl enable affine_ynh
systemctl start affine_ynh
```

## 9. Gestion des mises à jour

### 9.1 Stratégie d'upgrade
```bash
# 1. Sauvegarde de sécurité
ynh_backup_create "$APP_ID" "pre_upgrade_$OLD_VERSION"

# 2. Téléchargement de la nouvelle version
ynh_setup_source "$APP_SOURCE_DIR" "$NEW_SOURCE_URL" "$NEW_CHECKSUM"

# 3. Build de la nouvelle version
cd "$APP_SOURCE_DIR"
pnpm install --frozen-lockfile
pnpm build

# 4. Migration des données
pnpm run migrate

# 5. Redémarrage du service
systemctl restart affine_ynh
```

### 9.2 Rollback
```bash
# En cas d'échec, restauration de la sauvegarde
ynh_backup_restore "$APP_ID" "pre_upgrade_$OLD_VERSION"
```

## 10. Critères de succès

### 10.1 Installation/Suppression idempotentes
- **Installation** : Peut être exécutée plusieurs fois sans erreur
- **Suppression** : Nettoyage complet sans résidus
- **Tests** : Scripts de validation automatisés

### 10.2 Fonctionnalité HTTP
- **Code de retour** : 200 OK sur toutes les routes principales
- **Performance** : Temps de réponse < 2s
- **WebSocket** : Connexion stable pour la collaboration temps réel

### 10.3 Backup/Restore
- **Intégrité** : Vérification des checksums
- **Complétude** : Toutes les données sauvegardées
- **Restauration** : Fonctionnement identique après restauration

### 10.4 CI/CD niveau ≥6
- **Tests automatisés** : Installation, configuration, fonctionnalité
- **Multi-architecture** : Validation ARM64 et AMD64
- **Sécurité** : Scan de vulnérabilités
- **Performance** : Tests de charge

## 11. Risques et mitigations

### 11.1 Changements upstream
**Risque** : Modifications de l'API ou de l'architecture d'AFFiNE
**Mitigation** :
- Pin strict sur les versions stables
- Tests automatisés sur chaque release
- Monitoring des changements upstream
- Documentation des breaking changes

### 11.2 Coût de build
**Risque** : Temps de build élevé, consommation CPU/RAM
**Mitigation** :
- Cache des dépendances Node.js
- Build incrémental
- Utilisation de binaires pré-compilés
- Limitation des ressources système

### 11.3 Consommation RAM
**Risque** : Utilisation mémoire excessive
**Mitigation** :
- Limitation systemd (MemoryLimit=1G)
- Monitoring des ressources
- Configuration optimisée de Node.js
- Documentation des exigences minimales

### 11.4 Dépendances
**Risque** : Conflits de versions ou dépendances obsolètes
**Mitigation** :
- Utilisation de lockfiles (package-lock.json)
- Tests de compatibilité
- Mise à jour progressive des dépendances
- Isolation des environnements

## 12. Documentation et ressources

### 12.1 Documentation YunoHost
- [Packaging Apps v2](https://yunohost.org/packaging_apps)
- [Manifest v2](https://yunohost.org/packaging_apps_manifest)
- [Helpers v2.1](https://github.com/YunoHost/yunohost)
- [Multi-instance](https://yunohost.org/packaging_apps_multi_instance)
- [NGINX Configuration](https://yunohost.org/packaging_apps_nginx)
- [SSOwat Integration](https://yunohost.org/packaging_apps_sso)

### 12.2 Documentation AFFiNE
- [AFFiNE GitHub](https://github.com/toeverything/AFFiNE)
- [Building Guide](https://github.com/toeverything/AFFiNE/blob/main/BUILDING.md)
- [Self-hosting Guide](https://affine.pro/docs/self-hosting)
- [API Documentation](https://affine.pro/docs/api)

### 12.3 Ressources techniques
- [Node.js LTS](https://nodejs.org/en/download/)
- [PNPM Documentation](https://pnpm.io/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/docs/)

## 13. Validation et tests

### 13.1 Tests d'installation
```bash
# Test d'installation propre
yunohost app install affine_ynh

# Test d'installation multi-instance
yunohost app install affine_ynh --label "Instance 2"

# Test de suppression
yunohost app remove affine_ynh
```

### 13.2 Tests de fonctionnalité
```bash
# Test HTTP
curl -I https://domain.com/

# Test WebSocket
wscat -c wss://domain.com/ws

# Test de performance
ab -n 1000 -c 10 https://domain.com/
```

### 12.3 Tests de sauvegarde
```bash
# Test de sauvegarde
yunohost app backup affine_ynh

# Test de restauration
yunohost app restore affine_ynh backup_id
```

---

**Version** : 1.0  
**Date** : $(date)  
**Auteur** : YunoForge  
**Statut** : En développement
```