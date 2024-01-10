#!/bin/sh

echo "Starting a dedicated PostgreSQL Docker instance"

docker run -d --rm --name econia_db_test -e POSTGRES_PASSWORD=pgpw -p 37949:5432 postgres > /dev/null

DATABASE_URL=postgres://postgres:pgpw@localhost:37949/econia

echo "Waiting 5 seconds for the database to start..." && sleep 5

echo "Running migrations back and forth"

if diesel database setup && diesel migration redo --all; then
    echo "All good !"
else
    echo "An error occured."
fi

docker stop econia_db_test > /dev/null
