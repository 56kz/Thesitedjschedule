#!/usr/bin/env bash
# Despliegue en VPS vía SSH + rsync.
# Uso: DEPLOY_TARGET=usuario@tu-vps.com ./deploy.sh
# Opcional: DEPLOY_PATH=/var/www/thesitedj (default: ~/thesitedj)

set -e

DEPLOY_TARGET="${DEPLOY_TARGET:?Configura DEPLOY_TARGET (ej: usuario@ip-o-dominio)}"
DEPLOY_PATH="${DEPLOY_PATH:-thesitedj}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Excluir lo que no debe subirse al servidor
RSYNC_EXCLUDE=(
  --exclude='.git'
  --exclude='log/*'
  --exclude='tmp/*'
  --exclude='storage/*'
  --exclude='node_modules'
  --exclude='.env'
  --exclude='.env.*'
  --exclude='*.sql'
  --exclude='.cursor'
  --exclude='.byebug_history'
  --exclude='nano.save'
)

echo "==> Sincronizando código a ${DEPLOY_TARGET}:${DEPLOY_PATH}"
rsync -avz --delete "${RSYNC_EXCLUDE[@]}" \
  "${SCRIPT_DIR}/" \
  "${DEPLOY_TARGET}:${DEPLOY_PATH}/"

echo "==> Ejecutando docker compose en el VPS (con override de producción)"
ssh "${DEPLOY_TARGET}" "cd ${DEPLOY_PATH} && docker compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache && docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d"

echo "==> Despliegue terminado. Comprueba: ssh ${DEPLOY_TARGET} 'cd ${DEPLOY_PATH} && docker compose -f docker-compose.yml -f docker-compose.prod.yml ps'"
