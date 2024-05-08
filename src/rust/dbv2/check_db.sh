#!/bin/sh

echo "Starting a dedicated PostgreSQL Docker instance"

docker run -d --rm --name econia_db_test -e POSTGRES_PASSWORD=pgpw -e POSTGRES_DB=econia -p 37949:5432 postgres > /dev/null

TEST_DATABASE_URL=postgres://postgres:pgpw@localhost:37949/econia

echo "Waiting 5 seconds for the database to start..." && sleep 5

echo "Running migrations back and forth"

if diesel database setup --database-url $TEST_DATABASE_URL && diesel migration redo --database-url $TEST_DATABASE_URL --all; then
    echo "All good !"
else
    docker logs econia_db_test
    echo "An error occured. Above are the PostgreSQL logs."
fi

docker stop econia_db_test > /dev/null
