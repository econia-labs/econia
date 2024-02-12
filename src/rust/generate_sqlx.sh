#!/bin/sh

echo "Starting a dedicated PostgreSQL Docker instance"

docker run -d --rm --name econia_db_sqlx -e POSTGRES_PASSWORD=pgpw -p 37949:5432 postgres > /dev/null

TEST_DATABASE_URL=postgres://postgres:pgpw@localhost:37949/econia

echo "Waiting 5 seconds for the database to start..." && sleep 5

echo "Running migrations"

if diesel --config-file dbv2/diesel.toml database setup --database-url $TEST_DATABASE_URL; then
    echo "Migrations ran correctly"
    echo "Generating .sqlx files"
    if cargo sqlx prepare --workspace --database-url $TEST_DATABASE_URL; then
        echo ".sqlx files generated"
    else
        echo "An error occured."
    fi
else
    echo "An error occured."
fi

docker stop econia_db_sqlx > /dev/null
