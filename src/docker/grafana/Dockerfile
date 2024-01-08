FROM ubuntu:jammy

RUN apt-get update -y && apt-get install -y postgresql-client-14

ENTRYPOINT psql $DATABASE_URL -c "\copy annotations from 'annotations.csv' with delimiter ',' null 'null'"
