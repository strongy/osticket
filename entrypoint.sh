#!/bin/bash
set -e

# If the bind-mounted include dir is empty (fresh volume), seed it from the image's original copy
if [ -z "$(ls -A /var/www/html/include 2>/dev/null)" ]; then
    echo "include/ is empty — seeding from image defaults..."
    cp -a /var/www/html/include-orig/. /var/www/html/include/
fi

exec "$@"
