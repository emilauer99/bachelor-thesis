#!/bin/bash

# DB ("database" is service name from docker-compose.yml)
while ! nc -z database 3306; do
  echo 'Waiting for database startup…'
  sleep 1
done

set -e

# Preparation
if [ ! -f /api/.env ]; then
  cp /api/.env.example /api/.env
fi

cd /api

composer install
php artisan migrate
php artisan optimize:clear

# Run
exec supervisord -c /etc/supervisor/supervisord.conf