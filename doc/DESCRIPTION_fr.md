AFFiNE est une base de connaissances nouvelle génération qui réunit notes, documents et tableaux blancs dans un espace de travail unifié. Elle est conçue avec la confidentialité et le principe « local-first » au cœur.

**Fonctionnalités clés :**

- **Canvas sans bords** : tableau blanc infini pour la pensée libre, les cartes mentales et l'organisation visuelle
- **Documents structurés** : éditeur de texte enrichi avec titres, tableaux, blocs de code et intégrations
- **Collaboration temps réel** : plusieurs utilisateurs peuvent éditer le même espace simultanément
- **Offline-first** : vos données sont toujours disponibles, même sans internet ; la synchronisation se fait à la reconnexion
- **Auto-hébergeable** : contrôle total sur vos données avec le serveur officiel self-hosted
- **Open source** : développement piloté par la communauté (MPL-2.0)

AFFiNE remplace une combinaison d'outils comme Notion (documents), Miro (tableaux blancs) et Obsidian (notes locales) par une expérience intégrée unique. Elle stocke les données dans un format binaire structuré (basé sur les CRDT), permettant la fusion efficace des modifications concurrentes.

La version auto-hébergée nécessite PostgreSQL (avec l'extension pgvector pour les fonctionnalités IA) et Redis pour le cache et les files de tâches.
