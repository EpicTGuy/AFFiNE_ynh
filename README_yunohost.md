# AFFiNE - Package YunoHost

## Description

AFFiNE est un workspace open-source auto-hébergeable qui combine documentation collaborative, whiteboard et gestion de projet. Ce package YunoHost permet d'installer facilement AFFiNE sur votre serveur YunoHost avec une configuration automatique complète.

## Fonctionnalités

### 🎯 Fonctionnalités principales
- **Documentation collaborative** : Éditeur de documents riche avec support Markdown
- **Whiteboard** : Tableau blanc interactif pour la collaboration visuelle
- **Gestion de projet** : Outils de planification et d'organisation
- **Base de connaissances** : Système de stockage structuré pour les connaissances

### 🔧 Fonctionnalités techniques
- ✅ **100% FOSS** : Aucune dépendance propriétaire
- 🔒 **Vie privée** : Pas de tracking, données locales
- ⚡ **Sobriété** : Optimisé pour les serveurs à faible consommation
- 🏗️ **Multi-architecture** : Support ARM64 et AMD64
- 🔄 **Multi-instance** : Plusieurs instances sur le même serveur
- 🔐 **SSOwat** : Intégration avec l'authentification YunoHost
- 🌐 **IPv6** : Support natif IPv6
- 🔄 **Backup/Restore** : Sauvegarde complète des données
- 🚀 **Performance** : Reverse proxy NGINX optimisé

## Prérequis

### Système
- **YunoHost** : 4.3.0 ou plus récent
- **Architecture** : ARM64 ou AMD64
- **RAM** : 512MB minimum (1GB recommandé)
- **Stockage** : 2GB minimum

### Services
- **PostgreSQL** : 13.0 ou plus récent
- **NGINX** : 1.18.0 ou plus récent
- **Redis** : 6.0.0 ou plus récent
- **Node.js** : 18.0.0 ou plus récent (LTS)

## Installation

### Via l'interface YunoHost

1. Connectez-vous à l'interface d'administration YunoHost
2. Allez dans "Applications" > "Installer"
3. Recherchez "AFFiNE" ou "affine"
4. Cliquez sur "Installer"
5. Configurez les paramètres :
   - **Domaine** : Sélectionnez votre domaine
   - **Chemin** : `/affine` (par défaut)
   - **Accès public** : `false` (recommandé)
6. Cliquez sur "Installer"

### Via la ligne de commande

```bash
# Installation depuis le catalogue YunoHost
yunohost app install affine

# Installation avec paramètres personnalisés
yunohost app install affine \
  --domain example.com \
  --path /affine \
  --is_public false
```

### Installation multi-instance

```bash
# Installation d'une deuxième instance
yunohost app install affine \
  --domain example.com \
  --path /affine2 \
  --is_public false

# Chaque instance aura son propre port et sa propre base de données
```

## Configuration

### Configuration automatique

L'application se configure automatiquement lors de l'installation :
- Base de données PostgreSQL créée
- Utilisateur système dédié
- Configuration NGINX avec SSL
- Service systemd configuré
- Intégration SSOwat

### Configuration manuelle

La configuration se trouve dans `/var/www/affine_<instance>/config/config.json` :

```json
{
  "database": {
    "url": "postgresql://affine_<instance>:password@localhost:5432/affine_<instance>"
  },
  "redis": {
    "url": "redis://localhost:6379/<instance_id>"
  },
  "server": {
    "port": 3000,
    "host": "127.0.0.1"
  },
  "security": {
    "secret": "your-secret-key"
  },
  "storage": {
    "path": "/var/www/affine_<instance>/data"
  }
}
```

### Configuration NGINX

Le package configure automatiquement NGINX avec :
- Reverse proxy vers l'application
- Support IPv6
- Headers de sécurité
- WebSocket support
- Compression gzip

### Configuration SSOwat

L'intégration SSOwat est automatique :
- Authentification via YunoHost
- Gestion des permissions
- Session unique

## Utilisation

### Accès à l'application

1. Ouvrez votre navigateur
2. Allez sur `https://votre-domaine.com/affine`
3. Connectez-vous avec votre compte YunoHost
4. Commencez à utiliser AFFiNE !

### Gestion des utilisateurs

Les utilisateurs sont gérés via l'interface YunoHost :
- Chaque utilisateur YunoHost peut accéder à l'application
- Permissions gérées via SSOwat
- Pas de gestion d'utilisateurs séparée

### Fonctionnalités AFFiNE

- **Création de documents** : Éditeur riche avec Markdown
- **Whiteboard** : Dessin et collaboration visuelle
- **Gestion de projet** : Kanban, calendrier, tâches
- **Base de connaissances** : Organisation des informations
- **Collaboration** : Partage et travail en équipe

## Upgrade

### Mise à jour automatique

```bash
# Mise à jour via l'interface YunoHost
# Ou via la ligne de commande
yunohost app upgrade affine
```

### Mise à jour manuelle

1. Arrêtez l'application : `yunohost app stop affine`
2. Sauvegardez les données : `yunohost app backup affine`
3. Mettez à jour : `yunohost app upgrade affine`
4. Redémarrez : `yunohost app start affine`

### Vérification après mise à jour

```bash
# Vérifier le statut
systemctl status affine

# Tester l'accès
curl -I https://votre-domaine.com/affine/health
```

## Backup/Restore

### Sauvegarde automatique

Les sauvegardes sont automatiques et incluent :
- Base de données PostgreSQL
- Fichiers de données
- Configuration
- Logs

### Sauvegarde manuelle

```bash
# Créer une sauvegarde
yunohost app backup affine

# Lister les sauvegardes
yunohost app backup list affine

# Restaurer une sauvegarde
yunohost app restore affine backup_name
```

### Restauration

1. Arrêtez l'application : `yunohost app stop affine`
2. Restaurez : `yunohost app restore affine backup_name`
3. Redémarrez : `yunohost app start affine`

## Remove

### Désinstallation

```bash
# Désinstallation via l'interface YunoHost
# Ou via la ligne de commande
yunohost app remove affine
```

### Vérification de la désinstallation

La désinstallation supprime :
- Application et données
- Base de données PostgreSQL
- Utilisateur système
- Configuration NGINX
- Service systemd
- Configuration SSOwat

## Limites

### Limites techniques
- **RAM** : 512MB minimum (1GB recommandé)
- **Stockage** : 2GB minimum
- **Concurrent users** : Dépend de la RAM disponible
- **File size** : Limité par l'espace disque

### Limites fonctionnelles
- **Multi-instance** : Maximum 10 instances par serveur
- **Backup** : Sauvegardes limitées par l'espace disque
- **Performance** : Dépend de la configuration du serveur

## Dépannage

### Problèmes courants

#### Service ne démarre pas
```bash
# Vérifier les logs
journalctl -u affine -f

# Vérifier la configuration
systemctl status affine

# Redémarrer
systemctl restart affine
```

#### Erreur de base de données
```bash
# Vérifier PostgreSQL
systemctl status postgresql

# Vérifier la connexion
sudo -u postgres psql -l | grep affine
```

#### Erreur NGINX
```bash
# Vérifier la configuration
nginx -t

# Vérifier les logs
tail -f /var/log/nginx/error.log

# Redémarrer NGINX
systemctl restart nginx
```

#### Problème de WebSocket
- Vérifier la configuration NGINX
- Vérifier les headers de sécurité
- Vérifier la configuration de l'application

#### Problème d'headers de sécurité
- Vérifier la configuration NGINX
- Vérifier les paramètres de l'application
- Vérifier les permissions

### Logs

```bash
# Logs de l'application
tail -f /var/log/affine/app.log

# Logs du service
journalctl -u affine -f

# Logs NGINX
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### Vérification du statut

```bash
# Statut du service
systemctl status affine

# Test de connectivité
curl -I https://votre-domaine.com/affine/health

# Vérifier les ports
netstat -tlnp | grep :3000
```

## Multi-instance

### Installation de plusieurs instances

```bash
# Instance 1 (par défaut)
yunohost app install affine --domain example.com --path /affine

# Instance 2
yunohost app install affine --domain example.com --path /affine2

# Instance 3
yunohost app install affine --domain example.com --path /affine3
```

### Gestion des instances

Chaque instance est indépendante :
- Port différent automatique
- Base de données séparée
- Utilisateur système différent
- Configuration isolée

### Limites multi-instance

- Maximum 10 instances par serveur
- Chaque instance consomme ~512MB RAM
- Ports automatiques (3000, 3001, 3002, ...)

## Sécurité

### Sécurité de l'application
- Authentification via YunoHost/SSOwat
- Chiffrement des données en transit (HTTPS)
- Headers de sécurité HTTP
- Isolation des utilisateurs

### Sécurité du système
- Utilisateur système dédié
- Permissions restrictives
- Pas de privilèges root
- Logs de sécurité

### Headers de sécurité
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: SAMEORIGIN`
- `Referrer-Policy: strict-origin-when-cross-origin`
- Content Security Policy (CSP)

## Support

### Documentation
- **AFFiNE** : [docs.affine.pro](https://docs.affine.pro)
- **YunoHost** : [yunohost.org](https://yunohost.org)

### Communauté
- **Forum YunoHost** : [forum.yunohost.org](https://forum.yunohost.org)
- **GitHub** : [github.com/toeverything/AFFiNE](https://github.com/toeverything/AFFiNE)

### Issues
- **Package** : [github.com/username/affine_ynh/issues](https://github.com/username/affine_ynh/issues)
- **AFFiNE** : [github.com/toeverything/AFFiNE/issues](https://github.com/toeverything/AFFiNE/issues)

---

**Développé avec ❤️ pour la communauté YunoHost**