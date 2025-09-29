# CI/CD AFFiNE YunoHost

## 🚀 Vue d'ensemble

Ce document explique comment utiliser et comprendre le système CI/CD pour le package AFFiNE YunoHost, conçu pour atteindre un **niveau ≥6** selon les critères YunoHost.

## 📊 Badges de Statut

### Badges GitHub Actions

[![CI](https://github.com/username/affine_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg)](https://github.com/username/affine_ynh/actions)
[![Lint Shell](https://github.com/username/affine_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg?label=shellcheck)](https://github.com/username/affine_ynh/actions)
[![Test Install](https://github.com/username/affine_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg?label=install)](https://github.com/username/affine_ynh/actions)
[![Test Multi-instance](https://github.com/username/affine_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg?label=multi-instance)](https://github.com/username/affine_ynh/actions)
[![Test Backup/Restore](https://github.com/username/affine_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg?label=backup-restore)](https://github.com/username/affine_ynh/actions)
[![Test Upgrade](https://github.com/username/affine_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg?label=upgrade)](https://github.com/username/affine_ynh/actions)

### Badge de Niveau YunoHost

[![Niveau YunoHost](https://img.shields.io/badge/YunoHost-Niveau%20$LEVEL-green)](https://github.com/username/affine_ynh/actions)

## 🔄 Déclenchement de la CI

### Branches

La CI se déclenche automatiquement sur :
- **Push** vers la branche `testing`
- **Pull Request** vers la branche `testing`

### Déclenchement manuel

Pour relancer la CI manuellement :

1. **Via GitHub Web Interface** :
   - Aller sur l'onglet "Actions"
   - Cliquer sur "CI AFFiNE YunoHost"
   - Cliquer sur "Run workflow"
   - Sélectionner la branche `testing`
   - Cliquer sur "Run workflow"

2. **Via GitHub CLI** :
   ```bash
   gh workflow run "CI AFFiNE YunoHost" --ref testing
   ```

3. **Via API GitHub** :
   ```bash
   curl -X POST \
     -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/username/affine_ynh/actions/workflows/ci.yml/dispatches \
     -d '{"ref":"testing"}'
   ```

## 🧪 Jobs de la CI

### 1. 🔍 Lint Shell (shellcheck)
**Objectif** : Vérifier la qualité du code shell
**Niveau** : 1
**Critères** :
- ✅ Tous les scripts passent shellcheck
- ✅ Permissions d'exécution correctes
- ✅ Syntaxe shell valide

### 2. 🚀 Test Install/Remove
**Objectif** : Tester l'installation et la désinstallation
**Niveau** : 2
**Critères** :
- ✅ Installation réussie
- ✅ Service actif et accessible
- ✅ URL publique répondant 200 OK
- ✅ Désinstallation propre sans résidus

### 3. 💾 Test Backup/Restore
**Objectif** : Tester le cycle complet de sauvegarde/restauration
**Niveau** : 3
**Critères** :
- ✅ Sauvegarde créée et vérifiée
- ✅ Désinstallation complète
- ✅ Restauration réussie
- ✅ Données restaurées correctement

### 4. 🔄 Test Multi-instance
**Objectif** : Tester le support multi-instance
**Niveau** : 4
**Critères** :
- ✅ 2 instances installées et fonctionnelles
- ✅ Ports différents automatiques
- ✅ Données isolées
- ✅ URLs publiques répondant 200 OK

### 5. ⬆️ Test Upgrade
**Objectif** : Tester l'upgrade vers un tag supérieur
**Niveau** : 5
**Critères** :
- ✅ Upgrade simulé avec succès
- ✅ Service fonctionnel après upgrade
- ✅ Données préservées
- ✅ Performance acceptable

### 6. 🎯 Test Complet
**Objectif** : Exécuter tous les tests en séquence
**Niveau** : 6
**Critères** :
- ✅ Tous les tests précédents réussis
- ✅ Rapport complet généré
- ✅ Artifacts de test uploadés

## 📊 Calcul du Niveau YunoHost

### Système de Points

| Test | Niveau | Points | Description |
|------|--------|--------|-------------|
| Lint Shell | 1 | +1 | Qualité du code shell |
| Install/Remove | 2 | +1 | Installation et désinstallation |
| Backup/Restore | 3 | +1 | Sauvegarde et restauration |
| Multi-instance | 4 | +1 | Support multi-instance |
| Upgrade | 5 | +1 | Mise à jour |
| Test Complet | 6 | +1 | Tous les tests |

### Niveau Final

- **Niveau 6+** : ✅ **REQUIS** pour la publication
- **Niveau 5** : ⚠️ Fonctionnel mais incomplet
- **Niveau <5** : ❌ Non conforme

## 🔧 Configuration de la CI

### Variables d'environnement

```yaml
env:
  TEST_DOMAIN: test.example.com
  TEST_PATH: /affine
  TEST_IS_PUBLIC: false
  TIMEOUT: 600
```

### Matrice de test

La CI teste sur :
- **OS** : Ubuntu Latest
- **YunoHost** : Version stable
- **Node.js** : LTS
- **PostgreSQL** : Version stable
- **Redis** : Version stable

## 📈 Monitoring et Rapports

### Artifacts

Chaque exécution génère :
- **Rapport principal** : `test_report.txt`
- **Logs détaillés** : Un log par test
- **Métriques** : Temps d'exécution, taux de réussite

### Notifications

- **Email** : En cas d'échec
- **Slack** : Optionnel (à configurer)
- **GitHub** : Commentaires sur les PR

## 🚨 Résolution des Problèmes

### Échecs Courants

1. **Lint Shell échoue** :
   ```bash
   # Vérifier localement
   shellcheck scripts/*.sh
   ```

2. **Test d'installation échoue** :
   - Vérifier les prérequis
   - Vérifier les permissions
   - Vérifier les services

3. **Test multi-instance échoue** :
   - Vérifier le support multi-instance
   - Vérifier les ports disponibles
   - Vérifier l'isolation des données

4. **Test backup/restore échoue** :
   - Vérifier les permissions de sauvegarde
   - Vérifier l'espace disque
   - Vérifier l'intégrité des données

### Debug Local

```bash
# Exécuter les tests localement
cd scripts
./run_all_tests.sh

# Vérifier les logs
tail -f /tmp/affine_tests/logs/*.log

# Vérifier les services
systemctl status nginx postgresql redis-server
```

## 📚 Documentation Associée

- **Scripts de test** : `scripts/README_SCRIPTS.md`
- **Spécifications** : `spec.md`
- **Architecture** : `architecture.md`
- **Manifest** : `manifest.toml`

## 🤝 Contribution

### Ajout de Tests

1. Créer le script dans `scripts/`
2. Ajouter le job dans `.github/workflows/ci.yml`
3. Mettre à jour la documentation
4. Tester localement

### Modification de la CI

1. Modifier `.github/workflows/ci.yml`
2. Tester sur une branche de test
3. Créer une PR vers `testing`
4. Vérifier que tous les tests passent

## 🎯 Objectifs

- **Niveau ≥6** : Atteindre le niveau requis pour la publication
- **Stabilité** : Tests fiables et reproductibles
- **Performance** : Exécution rapide des tests
- **Maintenabilité** : Code CI clair et documenté

## 📞 Support

- **Issues** : [GitHub Issues](https://github.com/username/affine_ynh/issues)
- **Discussions** : [GitHub Discussions](https://github.com/username/affine_ynh/discussions)
- **Documentation** : [Wiki](https://github.com/username/affine_ynh/wiki)

---

**Note** : Cette CI est conçue pour fonctionner dans un environnement de test isolé. Ne pas utiliser sur un serveur de production.
