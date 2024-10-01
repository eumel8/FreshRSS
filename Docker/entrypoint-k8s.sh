#!/bin/sh

# put all runtime and log data in emptyDir
export APACHE_PID_FILE=/apache/run/apache2.pid
export APACHE_RUN_DIR=/apache/run
export APACHE_LOCK_DIR=/apache/run/apachelock
export APACHE_LOG_DIR=/apache/run/apachelogs

export OIDC_SESSION_INACTIVITY_TIMEOUT="${OIDC_SESSION_INACTIVITY_TIMEOUT:-300}"
export OIDC_SESSION_MAX_DURATION="${OIDC_SESSION_MAX_DURATION:-27200}"
export OIDC_SESSION_TYPE="${OIDC_SESSION_TYPE:-server-cache}"
OIDC_SCOPES=$(echo "$OIDC_SCOPES" | tr ':' ' ')
export OIDC_SCOPES

if [ ! -d '/var/www/FreshRSS' ]; then
        echo >&2 '⛔ It does not look like a FreshRSS directory; exiting!'
        exit 2
fi


if [ ! -f '/var/www/FreshRSS/constants.php' ]; then
	cp -a /var/www/FreshRSSORIG/. /var/www/FreshRSS/
	mkdir -p /var/www/FreshRSS/data/users/_/
	chmod -R g+w /var/www/FreshRSS/data/
	php -f /var/www/FreshRSS/cli/prepare.php >/dev/null
fi

exec "$@"
