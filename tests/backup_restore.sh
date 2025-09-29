#!/bin/bash
set -eu
set -o pipefail

yunohost backup create --apps affine --debug
ARCHIVE=$(yunohost backup list --output-as json | jq -r '.archives[-1].name')

yunohost app remove affine --force --purge
yunohost backup restore "$ARCHIVE" --apps affine --debug

DOMAIN=$(yunohost app setting affine domain)
PATH_URL=$(yunohost app setting affine path)
curl -kI "https://${DOMAIN}${PATH_URL}/" | (grep -E "HTTP/.* (200|302)" && echo "OK backup/restore") || (echo "FAIL backup/restore" && exit 1)
