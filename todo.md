# TODO - Package YunoHost AFFiNE

## État du projet
- **Statut** : En développement
- **Version** : 0.1.0
- **Dernière mise à jour** : $(date)

## Phase 1 : Squelette et structure de base

### 1.1 Création de la structure
- [x] Création de l'arborescence stricte
- [x] Configuration des répertoires de base
- [x] Initialisation du projet Git
- [ ] Validation de la structure avec YunoHost

### 1.2 Manifeste et configuration
- [x] Création du manifest.toml v2
- [x] Configuration des métadonnées
- [x] Définition des ressources
- [x] Configuration des sources tarball
- [ ] Validation du manifeste avec yunohost

### 1.3 Configuration système
- [x] Configuration NGINX avec IPv6
- [x] Service systemd pour AFFiNE
- [x] Headers de sécurité
- [x] Configuration WebSocket
- [ ] Tests de configuration

## Phase 2 : Implémentation des scripts

### 2.1 Script d'installation
- [x] Structure de base du script
- [x] Vérification des prérequis
- [x] Installation Node.js LTS
- [x] Téléchargement des sources
- [ ] Build de production avec PNPM
- [ ] Configuration de la base de données
- [ ] Configuration du service
- [ ] Tests de validation
- [ ] Gestion d'erreurs complète

### 2.2 Script de suppression
- [x] Structure de base du script
- [x] Arrêt des services
- [x] Suppression des configurations
- [x] Nettoyage des données
- [ ] Suppression des utilisateurs
- [ ] Nettoyage des logs
- [ ] Tests de suppression

### 2.3 Script de mise à jour
- [ ] Sauvegarde de sécurité
- [ ] Téléchargement nouvelle version
- [ ] Build de la nouvelle version
- [ ] Migration des données
- [ ] Redémarrage des services
- [ ] Tests de mise à jour
- [ ] Rollback en cas d'échec

### 2.4 Scripts de sauvegarde
- [ ] Sauvegarde des fichiers
- [ ] Sauvegarde de la base de données
- [ ] Sauvegarde de la configuration
- [ ] Sauvegarde des services
- [ ] Vérification de l'intégrité
- [ ] Tests de sauvegarde

### 2.5 Scripts de restauration
- [ ] Restauration des fichiers
- [ ] Restauration de la base de données
- [ ] Restauration de la configuration
- [ ] Restauration des services
- [ ] Vérification du fonctionnement
- [ ] Tests de restauration

## Phase 3 : Tests et validation

### 3.1 Tests d'installation
- [ ] Test d'installation propre
- [ ] Test d'installation multi-instance
- [ ] Test de réinstallation
- [ ] Test de compatibilité multi-architecture
- [ ] Test de gestion d'erreurs

### 3.2 Tests de fonctionnalité
- [ ] Test HTTP (200 OK)
- [ ] Test WebSocket
- [ ] Test de performance
- [ ] Test de sécurité
- [ ] Test de multi-instance

### 3.3 Tests de maintenance
- [ ] Test de mise à jour
- [ ] Test de sauvegarde
- [ ] Test de restauration
- [ ] Test de suppression
- [ ] Test de rollback

### 3.4 Tests de conformité
- [ ] Validation manifest.toml
- [ ] Validation des scripts
- [ ] Validation des permissions
- [ ] Validation des helpers
- [ ] Validation des ressources

## Phase 4 : CI/CD et automatisation

### 4.1 Configuration GitHub Actions
- [x] Workflow de test de base
- [ ] Workflow de test multi-architecture
- [ ] Workflow de test de sécurité
- [ ] Workflow de test de performance
- [ ] Workflow de déploiement

### 4.2 Tests automatisés
- [ ] Tests d'installation automatisés
- [ ] Tests de fonctionnalité automatisés
- [ ] Tests de maintenance automatisés
- [ ] Tests de conformité automatisés
- [ ] Tests de performance automatisés

### 4.3 Validation continue
- [ ] Validation des pull requests
- [ ] Validation des releases
- [ ] Validation des branches
- [ ] Validation des tags
- [ ] Validation des déploiements

## Phase 5 : Documentation et publication

### 5.1 Documentation utilisateur
- [x] README.md de base
- [ ] Guide d'installation détaillé
- [ ] Guide d'administration
- [ ] Guide de dépannage
- [ ] FAQ utilisateur

### 5.2 Documentation technique
- [x] spec.md complet
- [x] architecture.md détaillé
- [x] implementation-plan.csv
- [x] prompt-plan.md
- [ ] API.md complet
- [ ] CHANGELOG.md détaillé

### 5.3 Publication
- [ ] Préparation du package
- [ ] Validation finale
- [ ] Soumission au catalogue YunoHost
- [ ] Publication sur GitHub
- [ ] Communication à la communauté

## Tâches prioritaires

### Urgentes (cette semaine)
1. Finaliser le script d'installation
2. Implémenter les tests de base
3. Configurer CI/CD de base
4. Valider la conformité YunoHost

### Importantes (ce mois)
1. Développer tous les scripts
2. Créer la suite de tests complète
3. Finaliser la documentation
4. Préparer la publication

### Moyennes (prochainement)
1. Optimiser les performances
2. Améliorer la sécurité
3. Ajouter des fonctionnalités avancées
4. Maintenir la compatibilité

## Notes et remarques

### Conformité YunoHost
- Respecter strictement la documentation officielle
- Utiliser les helpers v2.1 exclusivement
- Suivre les bonnes pratiques de sécurité
- Maintenir la compatibilité multi-architecture

### Exigences techniques
- 100% FOSS
- Respect de la vie privée
- Sobriété énergétique
- Support ARM64 et AMD64
- Multi-instance
- SSOwat configurable

### Prochaines étapes
1. Finaliser l'implémentation des scripts
2. Créer la suite de tests complète
3. Configurer l'environnement de test
4. Valider la conformité YunoHost

## Historique des modifications

### Version 0.1.0 (Initial)
- Création de la structure de base
- Documentation initiale
- Configuration des composants principaux
- Scripts de base

### Prochaines versions
- 0.2.0 : Scripts complets
- 0.3.0 : Tests et validation
- 0.4.0 : CI/CD et automatisation
- 1.0.0 : Version stable

## Contacts et ressources

### Documentation
- [Documentation YunoHost](https://yunohost.org/docs)
- [Helpers YunoHost](https://github.com/YunoHost/yunohost)
- [Standards de packaging](https://yunohost.org/packaging_apps)

### Support
- [Forum YunoHost](https://forum.yunohost.org)
- [GitHub Issues](https://github.com/YunoHost/yunohost/issues)
- [Documentation AFFiNE](https://affine.pro)

## Métriques du projet

### Progression
- **Phase 1** : 80% (4/5 tâches)
- **Phase 2** : 40% (2/5 tâches)
- **Phase 3** : 0% (0/4 tâches)
- **Phase 4** : 20% (1/5 tâches)
- **Phase 5** : 60% (3/5 tâches)

### Progression globale
- **Total** : 40% (10/25 tâches)
- **Temps estimé restant** : 30-40 heures
- **Date de livraison estimée** : 2-3 semaines

## Checklist de validation

### Avant chaque commit
- [ ] Code testé localement
- [ ] Tests automatisés passent
- [ ] Documentation mise à jour
- [ ] Conformité YunoHost vérifiée

### Avant chaque release
- [ ] Tous les tests passent
- [ ] Documentation complète
- [ ] Changelog à jour
- [ ] Validation finale effectuée

### Avant la publication
- [ ] Package validé par YunoHost
- [ ] Tests de régression passent
- [ ] Performance validée
- [ ] Sécurité vérifiée