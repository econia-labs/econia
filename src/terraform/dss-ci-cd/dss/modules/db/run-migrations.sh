# Run Cloud SQL Auth Proxy in background, run migrations, kill proxy.
cloud-sql-proxy $DB_CONNECTION_NAME --credentials-file $CREDENTIALS_FILE &
sleep 5 # Give proxy time to start up.
diesel migration run --migration-dir migrations
# https://unix.stackexchange.com/a/104825
kill $(pgrep cloud-sql-proxy)
