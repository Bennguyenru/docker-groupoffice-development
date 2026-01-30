#!/bin/sh

# Download the installer signature
EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"

if [ -z "$EXPECTED_CHECKSUM" ]; then
    >&2 echo 'ERROR: Could not fetch installer signature'
    exit 1
fi

# Download the installer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

if [ ! -f composer-setup.php ]; then
    >&2 echo 'ERROR: Could not download composer installer'
    exit 1
fi

# Verify the installer
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    >&2 echo "Expected: $EXPECTED_CHECKSUM"
    >&2 echo "Actual: $ACTUAL_CHECKSUM"
    rm composer-setup.php
    exit 1
fi

# Run the installer
php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php
exit $RESULT