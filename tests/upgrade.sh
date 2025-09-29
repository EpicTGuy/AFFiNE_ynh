#!/bin/bash
set -eu
set -o pipefail

# Simuler une modif (bump ynh revision)
sed -i 's/~ynh\([0-9]\+\)"/~ynh\1a"/' manifest.toml || true
git add manifest.toml || true
git commit -m "chore: dummy bump for upgrade test" || true
git push || true

yunohost app upgrade affine -u "https://github.com/EpicTGuy/AFFINE_ynh" --branch feat/helpers-v2-fixes --debug

DOMAIN=$(yunohost app setting affine domain)
PATH_URL=$(yunohost app setting affine path)
curl -kI "https://${DOMAIN}${PATH_URL}/" | (grep -E "HTTP/.* (200|302)" && echo "OK upgrade") || (echo "FAIL upgrade" && exit 1)
