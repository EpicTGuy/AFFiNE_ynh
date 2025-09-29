# Affine YunoHost Package

[![CI](https://github.com/username/affine_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg)](https://github.com/username/affine_ynh/actions)
[![Niveau YunoHost](https://img.shields.io/badge/YunoHost-Niveau%20$LEVEL-green)](https://github.com/username/affine_ynh/actions)
[![Shellcheck](https://github.com/username/affine_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg?label=shellcheck)](https://github.com/username/affine_ynh/actions)

## Vue d'ensemble

Ce package YunoHost permet d'installer facilement [Affine](https://affine.pro), une application de collaboration et de gestion de projet open source, sur votre serveur YunoHost.

## CI/CD

Ce package inclut une CI/CD complète avec tests automatisés pour atteindre un **niveau ≥6** selon les critères YunoHost.

### Tests Inclus

- 🔍 **Lint Shell** : Vérification de la qualité du code
- 🚀 **Install/Remove** : Test d'installation et désinstallation
- 💾 **Backup/Restore** : Test de sauvegarde et restauration
- 🔄 **Multi-instance** : Test du support multi-instance
- ⬆️ **Upgrade** : Test de mise à jour
- 🎯 **Test Complet** : Exécution de tous les tests

### Relancer la CI

La CI se déclenche automatiquement sur la branche `testing`. Pour la relancer manuellement :

1. **Via GitHub Web** : Actions → CI AFFiNE YunoHost → Run workflow
2. **Via CLI** : `gh workflow run "CI AFFiNE YunoHost" --ref testing`

Voir [README_CI.md](README_CI.md) pour plus de détails.

## Fonctionnalités

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

- YunoHost 4.3.0 ou plus récent
- PostgreSQL 13.0 ou plus récent
- NGINX 1.18.0 ou plus récent
- Redis 6.0.0 ou plus récent
- Node.js 18.0.0 ou plus récent

## Installation

### Via l'interface YunoHost

1. Connectez-vous à l'interface d'administration YunoHost
2. Allez dans "Applications" > "Installer"
3. Recherchez "Affine" ou "affine_ynh"
4. Cliquez sur "Installer"
5. Suivez les instructions d'installation

### Via la ligne de commande

```bash
# Installation depuis le dépôt YunoHost
yunohost app install affine_ynh

# Ou installation depuis un fichier local
yunohost app install /path/to/affine_ynh
```

## Configuration

### Configuration de base

L'application se configure automatiquement lors de l'installation. Vous pouvez accéder à l'interface d'administration via :

- **Application** : `https://votre-domaine.com`
- **Administration** : `https://votre-domaine.com/admin`

### Configuration avancée

La configuration se trouve dans `/opt/yunohost/apps/affine_ynh/config/config.json` :

```json
{
  "database": {
    "url": "postgresql://user:password@localhost:5432/database"
  },
  "redis": {
    "url": "redis://localhost:6379/0"
  },
  "server": {
    "port": 3000,
    "host": "127.0.0.1"
  },
  "security": {
    "secret": "your-secret-key"
  }
}
```

## Utilisation

### Accès à l'application

1. Ouvrez votre navigateur
2. Allez sur `https://votre-domaine.com`
3. Connectez-vous avec votre compte YunoHost
4. Commencez à utiliser Affine !

### Gestion des utilisateurs

Les utilisateurs sont gérés via l'interface YunoHost. Chaque utilisateur YunoHost peut accéder à l'application avec ses identifiants.

### Sauvegarde

Les sauvegardes sont automatiques et incluent :
- Base de données PostgreSQL
- Fichiers de données
- Configuration
- Logs

### Mise à jour

```bash
# Mise à jour via l'interface YunoHost
# Ou via la ligne de commande
yunohost app upgrade affine_ynh
```

## Support multi-instance

Ce package supporte plusieurs instances sur le même serveur :

```bash
# Installation d'une nouvelle instance
yunohost app install affine_ynh --label "Affine Instance 2"

# Chaque instance aura son propre port et sa propre base de données
```

## Dépannage

### Logs

Les logs se trouvent dans `/var/log/affine_ynh/` :

```bash
# Logs de l'application
tail -f /var/log/affine_ynh/app.log

# Logs du service
journalctl -u affine_ynh -f
```

### Vérification du statut

```bash
# Statut du service
systemctl status affine_ynh

# Test de connectivité
curl -I https://votre-domaine.com/health
```

### Redémarrage

```bash
# Redémarrage du service
systemctl restart affine_ynh

# Redémarrage via YunoHost
yunohost app restart affine_ynh
```

## Développement

### Structure du projet

```
affine_ynh/
├── scripts/           # Scripts YunoHost
│   ├── install
│   ├── remove
│   ├── upgrade
│   ├── backup
│   └── restore
├── conf/              # Configurations
│   ├── nginx.conf
│   └── systemd.service
├── manifest.toml      # Manifeste YunoHost
├── README.md          # Documentation
└── CI/                # Configuration CI/CD
    └── .github/
        └── workflows/
            └── test.yml
```

### Tests

```bash
# Tests locaux
./scripts/test.sh

# Tests CI/CD
# Les tests s'exécutent automatiquement sur GitHub Actions
```

## Contribution

Les contributions sont les bienvenues ! Veuillez :

1. Fork le projet
2. Créer une branche feature
3. Faire vos modifications
4. Tester localement
5. Soumettre une pull request

## Licence

Ce package est distribué sous licence AGPL-3.0.

## Support

- **Documentation** : [affine.pro/docs](https://affine.pro/docs)
- **Forum YunoHost** : [forum.yunohost.org](https://forum.yunohost.org)
- **Issues GitHub** : [github.com/affinepro/affine/issues](https://github.com/affinepro/affine/issues)

## Changelog

### Version 0.1.0 (Initial)
- Installation de base
- Configuration automatique
- Support multi-instance
- Backup/restore
- Intégration SSOwat
- Support IPv6
- CI/CD complet

---

**Développé avec ❤️ pour la communauté YunoHost**
