#!/bin/bash
set -eu
DOMAIN="${DOMAIN:-test.local}"
BRANCH="${BRANCH:-feat/helpers-v2-fixes}"
set -o pipefail

yunohost app install "https://github.com/EpicTGuy/AFFINE_ynh" \
  --branch "$BRANCH" \
  -a "domain=${DOMAIN}&path=/affine2&init_main_permission=visitors" \
  --debug

curl -kI "https://${DOMAIN}/affine2/" | (grep -E "HTTP/.* (200|302)" && echo "OK multi") || (echo "FAIL multi" && exit 1)
