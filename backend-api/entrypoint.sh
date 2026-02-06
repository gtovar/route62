#!/bin/bash
set -e

# Elimina un archivo server.pid preexistente potencialmente problemático.
rm -f /app/tmp/pids/server.pid

# Ejecuta el comando principal del contenedor (lo que se pase en CMD o en docker-compose)
exec "$@"
