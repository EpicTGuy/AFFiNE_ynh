# Gestion des Versions - Package AFFiNE YunoHost

## Vue d'ensemble

Ce document décrit la stratégie de versioning pour le package AFFiNE YunoHost, incluant le mapping des versions upstream vers les versions YunoHost et les procédures de mise à jour.

## Stratégie de Versioning

### Format des versions

#### Version Upstream (AFFiNE)
```
Format: X.Y.Z
Exemple: 0.10.0

Où:
- X = Version majeure (breaking changes)
- Y = Version mineure (nouvelles fonctionnalités)
- Z = Version patch (corrections de bugs)
```

#### Version YunoHost
```
Format: X.Y.Z~ynhN
Exemple: 0.10.0~ynh1

Où:
- X.Y.Z = Version upstream
- ~ynhN = Version du package YunoHost (N = 1, 2, 3, ...)
```

### Mapping des versions

| Upstream | YunoHost | Description |
|----------|----------|-------------|
| 0.10.0 | 0.10.0~ynh1 | Version initiale |
| 0.10.1 | 0.10.1~ynh1 | Correction de bugs |
| 0.10.2 | 0.10.2~ynh1 | Correction de bugs |
| 0.11.0 | 0.11.0~ynh1 | Nouvelles fonctionnalités |
| 0.11.0 | 0.11.0~ynh2 | Correction package YunoHost |
| 0.12.0 | 0.12.0~ynh1 | Version majeure |

## Procédure de Mise à Jour

### 1. Détection d'une nouvelle version upstream

#### Sources de monitoring
- **GitHub Releases** : [github.com/toeverything/AFFiNE/releases](https://github.com/toeverything/AFFiNE/releases)
- **RSS Feed** : [github.com/toeverything/AFFiNE/releases.atom](https://github.com/toeverything/AFFiNE/releases.atom)
- **API GitHub** : [api.github.com/repos/toeverything/AFFiNE/releases](https://api.github.com/repos/toeverything/AFFiNE/releases)

#### Vérification automatique
```bash
# Script de vérification des versions
#!/bin/bash
CURRENT_VERSION=$(grep 'version = ' manifest.toml | cut -d'"' -f2 | cut -d'~' -f1)
LATEST_VERSION=$(curl -s https://api.github.com/repos/toeverything/AFFiNE/releases/latest | jq -r '.tag_name' | sed 's/v//')

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Nouvelle version disponible: $LATEST_VERSION"
    echo "Version actuelle: $CURRENT_VERSION"
fi
```

### 2. Mise à jour du package

#### Étapes de mise à jour
1. **Récupération des sources** : Téléchargement de la nouvelle version
2. **Vérification des checksums** : Validation de l'intégrité
3. **Mise à jour du manifest** : Version et métadonnées
4. **Tests** : Validation complète
5. **Release** : Publication de la nouvelle version

#### Mise à jour du manifest.toml
```toml
# Avant
version = "0.10.0~ynh1"
url = "https://github.com/toeverything/AFFiNE/releases/download/v0.10.0/affine-v0.10.0-linux-x64.tar.gz"
sha256 = "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"

# Après
version = "0.11.0~ynh1"
url = "https://github.com/toeverything/AFFiNE/releases/download/v0.11.0/affine-v0.11.0-linux-x64.tar.gz"
sha256 = "b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef1234567"
```

### 3. Tests et validation

#### Tests automatiques
```bash
# Exécution des tests
cd scripts
./run_all_tests.sh

# Vérification du niveau
# Niveau ≥6 requis pour la publication
```

#### Tests manuels
- Installation sur environnement de test
- Vérification des fonctionnalités
- Test de migration des données
- Validation des performances

### 4. Publication

#### Création du tag
```bash
# Créer un tag pour la nouvelle version
git tag -a v0.11.0~ynh1 -m "Release 0.11.0~ynh1"

# Pousser le tag
git push origin v0.11.0~ynh1
```

#### Mise à jour du catalogue
- Mise à jour de l'entrée dans `apps.toml`
- Pull Request vers le dépôt YunoHost
- Validation par la communauté

## Types de Mises à Jour

### Mise à jour mineure (patch)
**Exemple** : 0.10.0 → 0.10.1

#### Changements
- Correction de bugs
- Améliorations de sécurité
- Optimisations mineures

#### Procédure
1. Mise à jour du manifest
2. Tests de régression
3. Publication directe

### Mise à jour mineure (feature)
**Exemple** : 0.10.0 → 0.11.0

#### Changements
- Nouvelles fonctionnalités
- Améliorations significatives
- Changements d'API mineurs

#### Procédure
1. Mise à jour du manifest
2. Tests complets
3. Validation des nouvelles fonctionnalités
4. Publication avec documentation

### Mise à jour majeure (breaking)
**Exemple** : 0.10.0 → 1.0.0

#### Changements
- Changements d'API majeurs
- Refactoring important
- Nouvelles dépendances

#### Procédure
1. Mise à jour du manifest
2. Tests exhaustifs
3. Migration des données
4. Documentation complète
5. Communication aux utilisateurs

### Mise à jour du package YunoHost
**Exemple** : 0.10.0~ynh1 → 0.10.0~ynh2

#### Changements
- Correction de bugs du package
- Amélioration de l'installation
- Mise à jour de la configuration

#### Procédure
1. Correction du problème
2. Tests de régression
3. Publication de la correction

## Gestion des Versions

### Branches

#### Branche principale
- **main** : Version stable
- **testing** : Version en test
- **develop** : Développement

#### Workflow
```
develop → testing → main
```

### Tags

#### Format des tags
```
vX.Y.Z~ynhN
Exemple: v0.10.0~ynh1
```

#### Création des tags
```bash
# Tag pour version upstream
git tag -a v0.10.0~ynh1 -m "Release 0.10.0~ynh1"

# Tag pour correction package
git tag -a v0.10.0~ynh2 -m "Fix package issue in 0.10.0~ynh2"
```

## Automatisation

### GitHub Actions

#### Workflow de mise à jour
```yaml
name: Check for updates
on:
  schedule:
    - cron: '0 0 * * 1'  # Chaque lundi à minuit
  workflow_dispatch:

jobs:
  check-updates:
    runs-on: ubuntu-latest
    steps:
      - name: Check upstream version
        run: |
          CURRENT=$(grep 'version = ' manifest.toml | cut -d'"' -f2 | cut -d'~' -f1)
          LATEST=$(curl -s https://api.github.com/repos/toeverything/AFFiNE/releases/latest | jq -r '.tag_name' | sed 's/v//')
          
          if [ "$CURRENT" != "$LATEST" ]; then
            echo "New version available: $LATEST"
            echo "::set-output name=update_needed::true"
            echo "::set-output name=new_version::$LATEST"
          fi
```

### Scripts de mise à jour

#### Script de mise à jour automatique
```bash
#!/bin/bash
# update_package.sh

set -e

# Récupération de la version actuelle
CURRENT_VERSION=$(grep 'version = ' manifest.toml | cut -d'"' -f2 | cut -d'~' -f1)
echo "Version actuelle: $CURRENT_VERSION"

# Récupération de la dernière version
LATEST_VERSION=$(curl -s https://api.github.com/repos/toeverything/AFFiNE/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo "Dernière version: $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Aucune mise à jour nécessaire"
    exit 0
fi

# Mise à jour du manifest
echo "Mise à jour du manifest..."
sed -i "s/version = \".*\"/version = \"$LATEST_VERSION~ynh1\"/" manifest.toml

# Récupération de l'URL et du checksum
RELEASE_URL="https://github.com/toeverything/AFFiNE/releases/download/v$LATEST_VERSION/affine-v$LATEST_VERSION-linux-x64.tar.gz"
CHECKSUM=$(curl -sL "$RELEASE_URL" | sha256sum | cut -d' ' -f1)

# Mise à jour de l'URL et du checksum
sed -i "s|url = \".*\"|url = \"$RELEASE_URL\"|" manifest.toml
sed -i "s/sha256 = \".*\"/sha256 = \"$CHECKSUM\"/" manifest.toml

echo "Mise à jour terminée: $LATEST_VERSION~ynh1"
```

## Historique des Versions

### Version 0.10.0~ynh1
- **Date** : 2024-01-01
- **Upstream** : 0.10.0
- **Changements** :
  - Version initiale
  - Installation de base
  - Configuration automatique
  - Support multi-instance
  - Backup/restore complet

### Version 0.10.1~ynh1
- **Date** : 2024-01-15
- **Upstream** : 0.10.1
- **Changements** :
  - Correction de bugs
  - Amélioration des performances
  - Mise à jour des dépendances

### Version 0.11.0~ynh1
- **Date** : 2024-02-01
- **Upstream** : 0.11.0
- **Changements** :
  - Nouvelles fonctionnalités
  - Amélioration de l'interface
  - Optimisations

## Dépannage

### Problèmes courants

#### Version non trouvée
```bash
# Vérifier la disponibilité de la version
curl -s https://api.github.com/repos/toeverything/AFFiNE/releases | jq '.[] | .tag_name'

# Vérifier l'URL de téléchargement
curl -I "https://github.com/toeverything/AFFiNE/releases/download/v0.10.0/affine-v0.10.0-linux-x64.tar.gz"
```

#### Checksum incorrect
```bash
# Recalculer le checksum
curl -sL "URL" | sha256sum

# Vérifier le checksum
echo "CHECKSUM" | sha256sum -c
```

#### Tests échoués
```bash
# Exécuter les tests localement
cd scripts
./run_all_tests.sh

# Vérifier les logs
tail -f /tmp/affine_tests/logs/*.log
```

## Ressources

### Documentation
- **Semantic Versioning** : [semver.org](https://semver.org)
- **GitHub Releases** : [docs.github.com/releases](https://docs.github.com/releases)
- **YunoHost Packaging** : [yunohost.org/packaging_apps](https://yunohost.org/packaging_apps)

### Outils
- **jq** : Traitement JSON
- **curl** : Téléchargement et API
- **git** : Gestion des versions
- **GitHub Actions** : Automatisation

---

**Note** : Ce document est destiné aux mainteneurs du package AFFiNE YunoHost. Pour toute question, consultez la documentation officielle YunoHost.
