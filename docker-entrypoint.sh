#!/bin/sh
set -e
# Ejecutar migraciones en producción al arrancar (idempotente)
if [ "${RAILS_ENV}" = "production" ]; then
  bundle exec rails db:migrate 2>/dev/null || true
fi
exec "$@"
