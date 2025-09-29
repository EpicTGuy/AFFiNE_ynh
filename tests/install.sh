#!/bin/bash
set -eu
DOMAIN="${DOMAIN:-test.local}"
PATH_URL="${PATH_URL:-/affine}"
BRANCH="${BRANCH:-feat/helpers-v2-fixes}"
set -o pipefail

yunohost app remove affine --force --purge || true
yunohost app install "https://github.com/EpicTGuy/AFFINE_ynh" \
  --branch "$BRANCH" \
  -a "domain=${DOMAIN}&path=${PATH_URL}&init_main_permission=visitors" \
  --debug

curl -kI "https://${DOMAIN}${PATH_URL}/" | (grep -E "HTTP/.* 200|HTTP/.* 302" && echo "OK install") || (echo "FAIL install" && exit 1)
