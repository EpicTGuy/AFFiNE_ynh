# Plan de prompts pour le développement d'affine_ynh

## Vue d'ensemble
Ce document décrit les prompts et instructions utilisés pour développer le package YunoHost affine_ynh de manière cohérente et efficace, organisés en lots de 3-5 fichiers avec critères d'acceptation.

## Lot 1 : Structure de base et manifeste

### Fichiers concernés
- `manifest.toml`
- `conf/nginx.conf`
- `conf/systemd/affine.service`
- `sources/affine-v0.10.0.tar.gz`

### Prompt principal
```
Crée la structure de base du package YunoHost AFFiNE :
1. manifest.toml v2 conforme avec métadonnées complètes
2. Configuration NGINX avec reverse proxy et support IPv6
3. Service systemd pour AFFiNE avec NODE_ENV=production
4. Tarball AFFiNE avec checksum SHA256

Exigences :
- Conformité stricte aux standards YunoHost v2
- Support multi-instance
- Headers de sécurité complets
- Configuration WebSocket
- Variables d'environnement appropriées
```

### Critères d'acceptation
- [ ] manifest.toml valide syntaxiquement
- [ ] Configuration NGINX fonctionnelle
- [ ] Service systemd démarre correctement
- [ ] Tarball téléchargeable et vérifiable
- [ ] Support IPv6 natif
- [ ] Headers de sécurité présents

## Lot 2 : Scripts d'installation et de base

### Fichiers concernés
- `scripts/install`
- `scripts/remove`
- `tests/test_install.sh`
- `tests/test_remove.sh`

### Prompt principal
```
Développe les scripts d'installation et de suppression pour AFFiNE :
1. Script install : installation complète avec build Node.js
2. Script remove : suppression propre sans résidus
3. Tests d'installation automatisés
4. Tests de suppression automatisés

Exigences :
- Utilisation des helpers YunoHost v2.1
- Gestion d'erreurs robuste
- Logging complet
- Tests idempotents
- Nettoyage en cas d'échec
```

### Critères d'acceptation
- [ ] Installation réussie en moins de 5 minutes
- [ ] Suppression complète sans résidus
- [ ] Tests d'installation passent
- [ ] Tests de suppression passent
- [ ] Gestion d'erreurs fonctionnelle
- [ ] Logging approprié

## Lot 3 : Scripts de maintenance et sauvegarde

### Fichiers concernés
- `scripts/upgrade`
- `scripts/backup`
- `scripts/restore`
- `tests/test_backup_restore.sh`

### Prompt principal
```
Implémente les scripts de maintenance pour AFFiNE :
1. Script upgrade : mise à jour avec migration des données
2. Script backup : sauvegarde complète (fichiers, DB, config)
3. Script restore : restauration complète
4. Tests de sauvegarde et restauration

Exigences :
- Migration des données sans perte
- Sauvegarde de tous les composants
- Restauration fonctionnelle
- Tests de validation
- Rollback en cas d'échec
```

### Critères d'acceptation
- [ ] Upgrade sans perte de données
- [ ] Sauvegarde complète fonctionnelle
- [ ] Restauration identique à l'original
- [ ] Tests de backup/restore passent
- [ ] Migration des données réussie
- [ ] Rollback fonctionnel

## Lot 4 : Tests et validation

### Fichiers concernés
- `tests/test_functionality.sh`
- `tests/test_multi_instance.sh`
- `CI/.github/workflows/test.yml`
- `CI/.github/workflows/security.yml`

### Prompt principal
```
Crée la suite de tests complète pour AFFiNE :
1. Tests de fonctionnalité HTTP/WebSocket
2. Tests de multi-instance
3. Configuration CI/CD GitHub Actions
4. Tests de sécurité automatisés

Exigences :
- Couverture de test complète
- Tests de performance
- Validation multi-architecture
- Scan de vulnérabilités
- Tests de charge
```

### Critères d'acceptation
- [ ] Tests de fonctionnalité passent
- [ ] Tests multi-instance passent
- [ ] CI/CD fonctionnel
- [ ] Tests de sécurité passent
- [ ] Validation multi-architecture
- [ ] Tests de performance réussis

## Lot 5 : Documentation et publication

### Fichiers concernés
- `doc/README.md`
- `doc/CHANGELOG.md`
- `doc/API.md`
- `CI/.github/workflows/deploy.yml`

### Prompt principal
```
Rédige la documentation complète et configure la publication :
1. README utilisateur avec guide d'installation
2. CHANGELOG avec historique des versions
3. Documentation API complète
4. Workflow de déploiement automatique

Exigences :
- Documentation claire et complète
- Guide d'installation détaillé
- API documentée
- Déploiement automatisé
- Changelog à jour
```

### Critères d'acceptation
- [ ] Documentation utilisateur complète
- [ ] Changelog à jour
- [ ] API documentée
- [ ] Déploiement automatisé
- [ ] Guide d'installation clair
- [ ] Documentation technique détaillée

## Prompts spécialisés par composant

### Prompt pour manifest.toml
```
Crée un manifest.toml v2 pour AFFiNE avec :
- Métadonnées complètes (nom, version, description)
- Configuration des ressources (data, config, logs)
- Sources tarball avec checksum
- Support multi-instance
- Dépendances (Node.js, PostgreSQL, Redis)
- Configuration des services
- Permissions et sécurité
```

### Prompt pour scripts d'installation
```
Développe le script d'installation AFFiNE :
- Vérification des prérequis
- Installation Node.js LTS via ynh_nodejs_install
- Téléchargement et vérification du tarball
- Build de production avec PNPM
- Configuration de la base de données
- Configuration du service systemd
- Configuration NGINX
- Tests de validation
- Gestion d'erreurs complète
```

### Prompt pour configuration NGINX
```
Configure NGINX pour AFFiNE :
- Support IPv6 natif
- Headers de sécurité complets
- Configuration WebSocket
- Reverse proxy optimisé
- Support SSL/TLS
- Compression Gzip/Brotli
- Cache des assets statiques
- Configuration multi-instance
```

### Prompt pour tests automatisés
```
Crée les tests automatisés pour AFFiNE :
- Tests d'installation idempotents
- Tests de fonctionnalité HTTP
- Tests WebSocket
- Tests de performance
- Tests de sécurité
- Tests multi-instance
- Tests de sauvegarde/restauration
- Validation de la conformité YunoHost
```

## Workflow de développement

### Phase 1 : Structure de base
1. Créer la structure de répertoires
2. Développer le manifest.toml
3. Configurer NGINX et systemd
4. Télécharger et vérifier les sources

### Phase 2 : Scripts principaux
1. Développer le script d'installation
2. Développer le script de suppression
3. Créer les tests de base
4. Valider le fonctionnement

### Phase 3 : Scripts avancés
1. Développer les scripts de maintenance
2. Implémenter la sauvegarde/restauration
3. Créer les tests avancés
4. Valider la robustesse

### Phase 4 : Tests et CI/CD
1. Créer la suite de tests complète
2. Configurer CI/CD
3. Implémenter les tests de sécurité
4. Valider la qualité

### Phase 5 : Documentation et publication
1. Rédiger la documentation
2. Configurer le déploiement
3. Finaliser la publication
4. Valider la livraison

## Critères de qualité

### Conformité YunoHost
- Respect strict des standards v2
- Utilisation des helpers officiels
- Configuration appropriée des ressources
- Gestion des erreurs robuste

### Qualité du code
- Code lisible et documenté
- Gestion d'erreurs complète
- Tests de validation
- Logging approprié

### Performance
- Installation rapide (< 5 min)
- Démarrage rapide (< 30s)
- Utilisation mémoire optimisée
- Cache efficace

### Sécurité
- Isolation des processus
- Permissions restrictives
- Headers de sécurité
- Validation des entrées

## Validation finale

### Tests de régression
- Installation propre
- Installation multi-instance
- Mise à jour sans perte
- Sauvegarde/restauration
- Suppression complète

### Tests de performance
- Temps d'installation
- Utilisation mémoire
- Temps de réponse
- Charge utilisateur

### Tests de sécurité
- Scan de vulnérabilités
- Validation des permissions
- Test des headers de sécurité
- Isolation des processus

---

**Version** : 1.0  
**Date** : $(date)  
**Auteur** : YunoForge  
**Statut** : En développement