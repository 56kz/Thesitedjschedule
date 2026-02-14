#!/usr/bin/env bash
# Restaurar dump MySQL en el contenedor db.
# Uso en el VPS (dentro del directorio de la app):
#   BACKUP_FILE=/ruta/a/backup.sql ./scripts/restore-db.sh
# O: cat backup.sql | ./scripts/restore-db.sh
# Con nerdctl (Colima, Rancher): COMPOSE_CMD="nerdctl compose" BACKUP_FILE=... ./scripts/restore-db.sh
# Asegúrate de que las variables MYSQL_* estén en .env o exportadas.

set -e

BACKUP_FILE="${BACKUP_FILE:-}"
# Comando compose: "docker compose" o "nerdctl compose" si usas Colima/nerdctl
COMPOSE_CMD="${COMPOSE_CMD:-docker compose}"

# Cargar .env si existe
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

MYSQL_USER="${MYSQL_USER:-rails}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-railssecret}"
MYSQL_DATABASE="${MYSQL_DATABASE:-db_thesitedj}"

if [ -n "${BACKUP_FILE}" ]; then
  if [ ! -f "${BACKUP_FILE}" ]; then
    echo "Error: no existe el archivo ${BACKUP_FILE}"
    exit 1
  fi
  echo "==> Restaurando desde ${BACKUP_FILE}"
  "${COMPOSE_CMD}" exec -T db mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < "${BACKUP_FILE}"
else
  echo "==> Restaurando desde stdin (ej: cat backup.sql | $0)"
  "${COMPOSE_CMD}" exec -T db mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}"
fi

echo "==> Restauración completada."
