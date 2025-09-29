# Guide de Publication - Package AFFiNE YunoHost

## Vue d'ensemble

Ce document décrit la procédure complète pour publier le package AFFiNE dans le catalogue officiel YunoHost, en respectant les critères de qualité et les niveaux requis.

## Prérequis

### Compte GitHub
- Compte GitHub actif
- Accès en écriture au dépôt YunoHost
- Permissions pour créer des Pull Requests

### Validation locale
- Tests locaux réussis
- Niveau ≥6 atteint
- Documentation complète
- Code conforme aux standards

## Procédure de Publication

### 1. Préparation du Dépôt

#### Structure du dépôt
```
affine_ynh/
├── .github/
│   └── workflows/
│       └── ci.yml
├── conf/
│   ├── nginx.conf
│   └── systemd/
│       └── affine.service
├── scripts/
│   ├── install
│   ├── remove
│   ├── upgrade
│   ├── backup
│   ├── restore
│   └── *.sh (tests)
├── manifest.toml
├── README.md
├── README_yunohost.md
├── README_yunohost_EN.md
├── README_CI.md
├── README_SCRIPTS.md
├── PUBLISHING.md
└── VERSIONING.md
```

#### Validation des fichiers
```bash
# Vérifier la structure
find . -type f -name "*.toml" -o -name "*.sh" -o -name "*.conf" | sort

# Vérifier les permissions
find scripts/ -name "*.sh" -exec ls -la {} \;

# Vérifier la syntaxe
shellcheck scripts/*.sh
```

### 2. Configuration de la Branche Testing

#### Création de la branche
```bash
# Créer la branche testing
git checkout -b testing

# Pousser la branche
git push origin testing
```

#### Configuration CI/CD
- La CI se déclenche automatiquement sur `testing`
- Tous les tests doivent passer
- Niveau ≥6 requis

### 3. Tests et Validation

#### Tests locaux
```bash
# Exécuter tous les tests
cd scripts
./run_all_tests.sh

# Vérifier les résultats
cat /tmp/affine_tests/test_report.txt
```

#### Tests CI
- Vérifier que tous les jobs passent
- Niveau calculé automatiquement
- Artifacts générés

### 4. Mise à jour du Catalogue

#### Fichier apps.toml
Ajouter l'entrée dans `apps.toml` :

```toml
[affine]
antifeatures = [ "not-ipv6-compatible" ]
category = "productivity_and_office"
maintained_by = "username"
state = "working"
url = "https://github.com/username/affine_ynh"
```

#### Métadonnées requises
- `antifeatures` : Fonctionnalités non supportées
- `category` : Catégorie de l'application
- `maintained_by` : Mainteneur du package
- `state` : État de l'application
- `url` : URL du dépôt

### 5. Pull Request

#### Création de la PR
```bash
# Créer une branche pour la PR
git checkout -b pr-add-affine

# Ajouter l'entrée dans apps.toml
# Commiter les changements
git add apps.toml
git commit -m "Add AFFiNE package to catalog"

# Pousser la branche
git push origin pr-add-affine
```

#### Description de la PR
```markdown
# Add AFFiNE Package to YunoHost Catalog

## Description
AFFiNE is an open-source self-hostable workspace that combines collaborative documentation, whiteboard, and project management.

## Features
- ✅ 100% FOSS
- 🔒 Privacy-focused
- ⚡ Resource-efficient
- 🏗️ Multi-architecture (ARM64/AMD64)
- 🔄 Multi-instance support
- 🔐 SSOwat integration
- 🌐 IPv6 compatible
- 🔄 Complete backup/restore

## CI Status
- [x] Lint Shell (shellcheck)
- [x] Test Install/Remove
- [x] Test Backup/Restore
- [x] Test Multi-instance
- [x] Test Upgrade
- [x] Test Complete

## Level
**Niveau YunoHost : 6+** ✅

## Testing
- Branch: `testing`
- All tests passing
- Level ≥6 achieved

## Documentation
- README_yunohost.md (FR/EN)
- README_CI.md
- README_SCRIPTS.md
- PUBLISHING.md
- VERSIONING.md
```

### 6. Validation par la Communauté

#### Critères de validation
- **Code quality** : Shellcheck, bonnes pratiques
- **Functionality** : Tous les tests passent
- **Documentation** : Complète et claire
- **Security** : Headers, permissions, isolation
- **Performance** : Optimisé, sobriété
- **Compatibility** : Multi-architecture, IPv6

#### Processus de review
1. **Review automatique** : CI/CD, niveau
2. **Review communautaire** : Mainteneurs, utilisateurs
3. **Tests supplémentaires** : Environnements variés
4. **Validation finale** : Approbation des mainteneurs

## Critères de Niveau

### Niveau 1 : Lint Shell
- ✅ Tous les scripts passent shellcheck
- ✅ Permissions d'exécution correctes
- ✅ Syntaxe shell valide
- ✅ Bonnes pratiques respectées

### Niveau 2 : Install/Remove
- ✅ Installation réussie
- ✅ Service actif et accessible
- ✅ URL publique répondant 200 OK
- ✅ Désinstallation propre sans résidus

### Niveau 3 : Backup/Restore
- ✅ Sauvegarde créée et vérifiée
- ✅ Désinstallation complète
- ✅ Restauration réussie
- ✅ Données restaurées correctement

### Niveau 4 : Multi-instance
- ✅ 2 instances installées et fonctionnelles
- ✅ Ports différents automatiques
- ✅ Données isolées
- ✅ URLs publiques répondant 200 OK

### Niveau 5 : Upgrade
- ✅ Upgrade simulé avec succès
- ✅ Service fonctionnel après upgrade
- ✅ Données préservées
- ✅ Performance acceptable

### Niveau 6 : Test Complet
- ✅ Tous les tests précédents réussis
- ✅ Rapport complet généré
- ✅ Artifacts de test uploadés
- ✅ Documentation complète

## Gestion des Versions

### Mapping des versions
```
Upstream: X.Y.Z
YunoHost: X.Y.Z~ynhN

Exemples:
- 0.10.0 → 0.10.0~ynh1
- 0.10.1 → 0.10.1~ynh1
- 0.11.0 → 0.11.0~ynh1
```

### Mise à jour des versions
1. **Upstream release** : Nouvelle version AFFiNE
2. **Update manifest** : Version dans `manifest.toml`
3. **Update sources** : URL et checksum
4. **Test** : Validation complète
5. **Release** : Nouvelle version YunoHost

## Maintenance

### Responsabilités du mainteneur
- **Mise à jour** : Suivi des releases upstream
- **Sécurité** : Correction des vulnérabilités
- **Support** : Réponse aux issues
- **Documentation** : Mise à jour régulière

### Processus de maintenance
1. **Monitoring** : Surveillance des releases upstream
2. **Testing** : Validation des nouvelles versions
3. **Update** : Mise à jour du package
4. **Release** : Publication de la nouvelle version

## Dépannage

### Problèmes courants

#### CI échoue
- Vérifier les logs de la CI
- Tester localement
- Corriger les erreurs
- Relancer la CI

#### Review négative
- Analyser les commentaires
- Corriger les problèmes
- Mettre à jour la PR
- Répondre aux questions

#### Niveau insuffisant
- Identifier les tests échoués
- Corriger les problèmes
- Améliorer la qualité
- Relancer les tests

### Support
- **GitHub Issues** : [github.com/username/affine_ynh/issues](https://github.com/username/affine_ynh/issues)
- **Forum YunoHost** : [forum.yunohost.org](https://forum.yunohost.org)
- **Documentation** : README_*.md

## Checklist de Publication

### Avant la PR
- [ ] Code testé localement
- [ ] CI/CD configurée
- [ ] Documentation complète
- [ ] Niveau ≥6 atteint
- [ ] Branche `testing` créée

### Pendant la PR
- [ ] Description claire
- [ ] Tests passants
- [ ] Réponses aux commentaires
- [ ] Mise à jour si nécessaire

### Après la PR
- [ ] PR approuvée
- [ ] Merge dans le catalogue
- [ ] Publication annoncée
- [ ] Support utilisateurs

## Ressources

### Documentation
- **YunoHost Packaging** : [yunohost.org/packaging_apps](https://yunohost.org/packaging_apps)
- **GitHub Actions** : [docs.github.com/actions](https://docs.github.com/actions)
- **Shellcheck** : [github.com/koalaman/shellcheck](https://github.com/koalaman/shellcheck)

### Outils
- **CI/CD** : GitHub Actions
- **Linting** : Shellcheck
- **Testing** : Scripts personnalisés
- **Documentation** : Markdown

---

**Note** : Ce guide est destiné aux mainteneurs du package AFFiNE YunoHost. Pour toute question, consultez la documentation officielle YunoHost.
