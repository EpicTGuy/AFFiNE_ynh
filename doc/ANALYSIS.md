# Analyse upstream : AFFiNE

## Informations de base
- Version courante   : 0.26.3 (2026-02-25)
- Distribution server: Docker uniquement — `ghcr.io/toeverything/affine:stable`
- Binaires desktop   : AppImage/deb/flatpak Linux (Electron — PAS le serveur)
- Licence SPDX       : MIT
- Stratégie YunoHost : format=docker (extraction de l'image, exécution avec Node.js natif)

## Runtime et dépendances
- Runtime principal  : Node.js (NestJS 11, pas de version engine déclarée — Node 20+ recommandé)
- Base de données    : PostgreSQL 16 + extension **pgvector** (OBLIGATOIRE)
- Cache/Queue        : Redis 6+ (ioredis + bullmq)
- ORM                : Prisma 6
- WebSocket          : socket.io (collaboration temps réel)
- Build nécessaire   : NON — l'image Docker contient le code compilé

## Points d'attention PostgreSQL
- L'image Docker officielle utilise `pgvector/pgvector:pg16`
- YunoHost fournit PostgreSQL standard → installer `postgresql-pgvector` (apt)
- Activer l'extension : `CREATE EXTENSION IF NOT EXISTS vector;`
- Vérifier la compatibilité version : YunoHost cible Debian bookworm → PostgreSQL 15

## Mode d'installation recommandé
- **format=docker** dans resources.sources
  → YunoHost extrait l'image et copie les fichiers dans $install_dir
  → Le binaire Node.js inclus dans l'image est utilisé pour l'exécution
- Étape de migration obligatoire : `node ./scripts/self-host-predeploy.js`
  → Génère `$data_dir/config/private.key`
  → Applique les migrations Prisma sur la base de données

## Intégrations
- LDAP  : NON — pas de variable LDAP dans la config officielle
- OIDC  : NON (non documenté pour self-host v0.26)
- SSO   : NON
- API init admin : NON — le premier utilisateur s'inscrit via l'interface web

## Configuration — Variables clés
- `DATABASE_URL`              : connexion PostgreSQL
- `REDIS_SERVER_HOST`         : hôte Redis
- `AFFINE_SERVER_EXTERNAL_URL`: URL publique complète (ex: https://domain.tld/affine)
- `AFFINE_CONFIG_PATH`        : répertoire config (private.key généré ici)
- `PORT`                      : port HTTP (défaut 3010)
- `NODE_ENV`                  : production
- `AFFINE_INDEXER_ENABLED`    : false (désactiver l'indexeur vectoriel pour économiser RAM)

## Réseau
- Port principal    : 3010
- WebSocket requis  : OUI (socket.io — proxy_upgrade dans nginx)
- Ports secondaires : aucun

## Architectures supportées
- amd64 : OUI (image Docker officielle)
- arm64 : OUI (image multi-arch)
- armhf : NON
- i386  : NON

## Multi-instance
NON — une instance par domaine/sous-domaine (port fixe 3010, config partagée)

## Risques et points d'attention
1. **pgvector** : extension PostgreSQL non standard — vérifier disponibilité sur bookworm
2. **ExecStart** : le chemin exact du binaire dans l'image Docker n'est pas encore vérifié
   → À confirmer après `ynh_setup_source` en mode format=docker
3. **line_match** pour ynh_systemd_action : vérifier le message de démarrage exact dans les logs
4. **sha256 de l'image Docker** : à calculer après pull → TODO dans manifest.toml
5. **Taille de l'image** : ~1 Go compressée → temps d'installation long
6. **Migration DB** : doit tourner AVANT le démarrage du service
