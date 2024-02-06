FROM ubuntu:jammy

RUN apt-get update -y && apt-get install -y postgresql-client-14

COPY src/docker/grafana_annotations/insert.sql .

ENTRYPOINT psql $DATABASE_URL -c "\i insert.sql"
