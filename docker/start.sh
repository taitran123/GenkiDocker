#!/usr/bin/env bash

# stops the execution of a script if a command or pipeline has an error - which is the opposite of the default shell behaviour, which is to ignore errors in scripts.
set -e 

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

if [ "$env" != "local" ]; then
    echo "Caching configuration..."
    (cd /gkdata && php artisan config:clear && php artisan cache:clear && php artisan queue:restart)
fi

if [ "$role" = "app" ]; then

    exec apache2-foreground

elif [ "$role" = "queue" ]; then

    echo "Running the queue..."
    php /gkdata/artisan queue:work --verbose --tries=3 --timeout=90

elif [ "$role" = "scheduler" ]; then

    while [ true ]
    do
      php /gkdata/artisan schedule:run --verbose --no-interaction &
      sleep 60
    done

else
    echo "Could not match the container role \"$role\""
    exit 1
fi
