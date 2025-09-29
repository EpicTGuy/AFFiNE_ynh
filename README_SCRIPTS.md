# Scripts de Test AFFiNE YunoHost

## 📋 Vue d'ensemble

Ce répertoire contient tous les scripts de test et de validation pour le package AFFiNE YunoHost. Ces scripts sont conçus pour être **non-interactifs** et **compatibles CI**.

## 🚀 Scripts Disponibles

### 1. `install.sh` - Test d'installation fraîche
**Objectif** : Tester l'installation complète d'AFFiNE et vérifier l'accès HTTP 200 OK

**Fonctionnalités** :
- Installation automatique avec paramètres non-interactifs
- Vérification des prérequis (YunoHost, Node.js, NGINX, PostgreSQL, Redis)
- Test de connectivité locale et publique
- Vérification des configurations (NGINX, systemd, SSOwat)
- Test de performance
- Nettoyage automatique en cas d'erreur

**Utilisation** :
```bash
./install.sh
# ou avec variables d'environnement
TEST_DOMAIN=example.com TEST_PATH=/affine ./install.sh
```

### 2. `multi_instance.sh` - Test multi-instance
**Objectif** : Tester l'installation de 2 instances sur des chemins différents avec ports automatiques

**Fonctionnalités** :
- Installation de 2 instances (sur `/affine` et `/affine2`)
- Vérification des ports différents automatiques
- Vérification des bases de données séparées
- Vérification des utilisateurs différents
- Test d'isolation des données
- Test de gestion des erreurs
- Test des URLs publiques (200 OK)

**Utilisation** :
```bash
./multi_instance.sh
# ou avec variables d'environnement
TEST_DOMAIN=example.com TEST_PATH1=/affine TEST_PATH2=/affine2 ./multi_instance.sh
```

### 3. `upgrade.sh` - Test d'upgrade
**Objectif** : Tester l'upgrade vers un tag supérieur et vérifier que le service fonctionne

**Fonctionnalités** :
- Installation de la version actuelle
- Création de sauvegarde de sécurité
- Simulation d'upgrade vers version supérieure
- Vérification de la nouvelle version
- Test de fonctionnement après upgrade
- Vérification de l'intégrité des données
- Test de performance
- Test de rollback (optionnel)

**Utilisation** :
```bash
./upgrade.sh
# ou avec variables d'environnement
CURRENT_VERSION=0.10.0 NEW_VERSION=0.11.0 ./upgrade.sh
```

### 4. `backup_restore.sh` - Test backup/restore complet
**Objectif** : Tester le cycle complet : backup → uninstall → restore → 200 OK

**Fonctionnalités** :
- Installation de l'application
- Création de données de test
- Création de sauvegarde complète
- Vérification de la sauvegarde
- Désinstallation complète
- Réinstallation
- Restauration de la sauvegarde
- Vérification des données restaurées
- Test de performance après restauration

**Utilisation** :
```bash
./backup_restore.sh
# ou avec variables d'environnement
TEST_DOMAIN=example.com TEST_PATH=/affine ./backup_restore.sh
```

### 5. `remove.sh` - Test de désinstallation propre
**Objectif** : Tester la désinstallation complète sans résidus (vhost/unit)

**Fonctionnalités** :
- Installation de l'application
- Enregistrement de l'état avant désinstallation
- Désinstallation complète
- Vérification de la suppression des services
- Vérification de la suppression des répertoires
- Vérification de la suppression des configurations (NGINX, systemd, SSOwat)
- Vérification de la suppression des bases de données
- Vérification de la suppression des ports
- Vérification de la suppression des logs
- Test de réinstallation après désinstallation

**Utilisation** :
```bash
./remove.sh
# ou avec variables d'environnement
TEST_DOMAIN=example.com TEST_PATH=/affine ./remove.sh
```

### 6. `run_all_tests.sh` - Script principal
**Objectif** : Exécuter tous les tests et générer un rapport complet

**Fonctionnalités** :
- Exécution de tous les scripts de test
- Génération de rapport détaillé
- Logs séparés pour chaque test
- Résumé des résultats
- Informations système
- Gestion des erreurs

**Utilisation** :
```bash
./run_all_tests.sh
# ou avec variables d'environnement
TEST_DOMAIN=example.com TEST_PATH=/affine ./run_all_tests.sh
```

## ⚙️ Configuration

### Variables d'environnement

Tous les scripts acceptent les variables d'environnement suivantes :

| Variable | Défaut | Description |
|----------|--------|-------------|
| `TEST_DOMAIN` | `test.example.com` | Domaine de test |
| `TEST_PATH` | `/affine` | Chemin de l'application |
| `TEST_PATH1` | `/affine` | Chemin de la première instance |
| `TEST_PATH2` | `/affine2` | Chemin de la deuxième instance |
| `TEST_IS_PUBLIC` | `false` | Application publique ou privée |
| `TIMEOUT` | `300` | Timeout en secondes |
| `CURRENT_VERSION` | `0.10.0` | Version actuelle (upgrade) |
| `NEW_VERSION` | `0.11.0` | Nouvelle version (upgrade) |

### Exemple d'utilisation avec variables

```bash
export TEST_DOMAIN=example.com
export TEST_PATH=/affine
export TEST_IS_PUBLIC=false
export TIMEOUT=600

./run_all_tests.sh
```

## 🔧 Prérequis

Les scripts nécessitent les composants suivants :

- **YunoHost** : Système de base
- **Node.js** : Runtime pour AFFiNE
- **NGINX** : Serveur web
- **PostgreSQL** : Base de données
- **Redis** : Cache et sessions
- **jq** : Traitement JSON
- **bc** : Calculs mathématiques
- **curl** : Tests HTTP
- **systemctl** : Gestion des services

## 📊 Rapports et Logs

### Structure des rapports

```
/tmp/affine_tests/
├── test_report.txt          # Rapport principal
└── logs/
    ├── installation.log     # Log du test d'installation
    ├── multi_instance.log   # Log du test multi-instance
    ├── upgrade.log          # Log du test d'upgrade
    ├── backup_restore.log   # Log du test backup/restore
    └── remove.log           # Log du test de désinstallation
```

### Format du rapport

Le rapport principal contient :
- Informations de test (domaine, chemin, timeout)
- Résultats de chaque test (succès/échec, durée)
- Fichiers de log associés
- Informations système
- Résumé final

## 🚨 Gestion des erreurs

### Nettoyage automatique

Tous les scripts incluent un mécanisme de nettoyage automatique :
- Suppression des applications installées
- Suppression des sauvegardes de test
- Suppression des fichiers temporaires
- Nettoyage en cas d'erreur ou d'interruption

### Codes de sortie

- **0** : Succès
- **1** : Échec
- **2** : Erreur de prérequis
- **3** : Erreur de configuration

## 🔄 Intégration CI

### GitHub Actions

```yaml
name: Test AFFiNE YunoHost
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y yunohost nodejs nginx postgresql redis-server jq bc curl
      - name: Run tests
        run: |
          cd scripts
          ./run_all_tests.sh
        env:
          TEST_DOMAIN: test.example.com
          TEST_PATH: /affine
```

### GitLab CI

```yaml
test:
  script:
    - apt-get update
    - apt-get install -y yunohost nodejs nginx postgresql redis-server jq bc curl
    - cd scripts
    - ./run_all_tests.sh
  variables:
    TEST_DOMAIN: test.example.com
    TEST_PATH: /affine
```

## 📝 Exemples d'utilisation

### Test rapide d'installation

```bash
./install.sh
```

### Test complet avec domaine personnalisé

```bash
TEST_DOMAIN=mon-domaine.com TEST_PATH=/affine ./run_all_tests.sh
```

### Test multi-instance uniquement

```bash
TEST_DOMAIN=example.com TEST_PATH1=/affine TEST_PATH2=/affine2 ./multi_instance.sh
```

### Test d'upgrade avec versions spécifiques

```bash
CURRENT_VERSION=0.10.0 NEW_VERSION=0.11.0 ./upgrade.sh
```

## 🎯 Résultats attendus

### Test d'installation
- ✅ Application installée et fonctionnelle
- ✅ Service actif et accessible
- ✅ URL publique répondant 200 OK
- ✅ Configurations créées correctement

### Test multi-instance
- ✅ 2 instances installées et fonctionnelles
- ✅ Ports différents automatiques
- ✅ Données isolées
- ✅ URLs publiques répondant 200 OK

### Test d'upgrade
- ✅ Upgrade simulé avec succès
- ✅ Service fonctionnel après upgrade
- ✅ Données préservées
- ✅ Performance acceptable

### Test backup/restore
- ✅ Sauvegarde créée et vérifiée
- ✅ Désinstallation complète
- ✅ Restauration réussie
- ✅ Données restaurées correctement

### Test de désinstallation
- ✅ Désinstallation complète et propre
- ✅ Aucun résidu (vhost/unit)
- ✅ Réinstallation possible

## 🔧 Dépannage

### Problèmes courants

1. **Service non accessible** : Vérifier que tous les prérequis sont installés
2. **Port déjà utilisé** : Vérifier qu'aucune autre instance n'utilise le port
3. **Base de données inaccessible** : Vérifier que PostgreSQL est démarré
4. **Redis inaccessible** : Vérifier que Redis est démarré
5. **Permissions insuffisantes** : Exécuter avec les bonnes permissions

### Logs de débogage

Les logs détaillés sont disponibles dans `/tmp/affine_tests/logs/` pour chaque test.

## 📚 Documentation

- **Spécifications** : `../spec.md`
- **Architecture** : `../architecture.md`
- **Manifest** : `../manifest.toml`
- **Scripts YunoHost** : `../scripts/install`, `../scripts/remove`, etc.

## 🤝 Contribution

Pour contribuer aux scripts de test :
1. Respecter le format non-interactif
2. Inclure la gestion d'erreurs
3. Ajouter des logs détaillés
4. Tester sur différents environnements
5. Documenter les nouvelles fonctionnalités

---

**Note** : Ces scripts sont conçus pour être exécutés dans un environnement de test isolé. Ne pas utiliser sur un serveur de production.
