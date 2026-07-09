#!/bin/bash
set -e

# Seed include/ from baked-in defaults if the bind-mounted volume is empty
if [ -z "$(ls -A /var/www/html/include 2>/dev/null)" ]; then
    echo "include/ is empty — seeding from image defaults..."
    cp -a /var/www/html/include-orig/. /var/www/html/include/
fi

# Once osTicket has actually been installed (OSTINSTALLED = TRUE), remove setup/ for security
CONFIG_FILE=/var/www/html/include/ost-config.php
if [ -f "$CONFIG_FILE" ] && grep -qE "define\('OSTINSTALLED',\s*TRUE\)" "$CONFIG_FILE"; then
    if [ -d /var/www/html/setup ]; then
        echo "osTicket appears installed — removing setup/ directory"
        rm -rf /var/www/html/setup
    fi
fi

exec "$@"
