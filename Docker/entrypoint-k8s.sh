#!/bin/sh

export OIDC_SESSION_INACTIVITY_TIMEOUT="${OIDC_SESSION_INACTIVITY_TIMEOUT:-300}"
export OIDC_SESSION_MAX_DURATION="${OIDC_SESSION_MAX_DURATION:-27200}"
export OIDC_SESSION_TYPE="${OIDC_SESSION_TYPE:-server-cache}"
OIDC_SCOPES=$(echo "$OIDC_SCOPES" | tr ':' ' ')
export OIDC_SCOPES


if [ -n "$FRESHRSS_INSTALL" ]; then
	cp -r /var/www/FreshRSSORIG/ /var/www/FreshRSS
	/var/www/FreshRSS/cli/access-permissions.sh
	php -f /var/www/FreshRSS/cli/prepare.php >/dev/null
	# shellcheck disable=SC2046
	php -f /var/www/FreshRSS/cli/do-install.php -- \
		$(echo "$FRESHRSS_INSTALL" | sed -r 's/[\r\n]+/\n/g' | paste -s -)
	EXITCODE=$?

	if [ $EXITCODE -eq 3 ]; then
		echo 'ℹ️ FreshRSS already installed; no change performed.'
	elif [ $EXITCODE -eq 0 ]; then
		echo '✅ FreshRSS successfully installed.'
	else
		echo '❌ FreshRSS error during installation!'
		exit $EXITCODE
	fi
fi

if [ -n "$FRESHRSS_USER" ]; then
	# shellcheck disable=SC2046
	php -f /var/www/FreshRSS/cli/create-user.php -- \
		$(echo "$FRESHRSS_USER" | sed -r 's/[\r\n]+/\n/g' | paste -s -)
	EXITCODE=$?

	if [ $EXITCODE -eq 3 ]; then
		echo 'ℹ️ FreshRSS user already exists; no change performed.'
	elif [ $EXITCODE -eq 0 ]; then
		echo '✅ FreshRSS user successfully created.'
		/var/www/FreshRSS/cli/list-users.php | xargs -n1 /var/www/FreshRSS/cli/actualize-user.php --user
	else
		echo '❌ FreshRSS error during the creation of a user!'
		exit $EXITCODE
	fi
fi

/var/www/FreshRSS/cli/access-permissions.sh

exec "$@"
