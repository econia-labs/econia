# Internal DSS deployment

This Terraform project is designed to support an internal deployment of the Econia Data Service Stack (DSS).
If you wish to use it in production, note that it uses a compromised JWT secret, does not implement load balancing or IP rate limiting, etc., and you will probably want to tune it for your own deployment.

See the docs site for example deployment commands, denial-of-service (DoS) mitigation strategies, etc.

## Connect to Cloud SQL

The Cloud SQL database is configured to allow connections from an administrator IP address, corresponding to the machine that deployed the Google Cloud Platform (GCP) project.
If you are not the admin but you still have access to the GCP project, you can connect to the database as follows:

1. Set up [Application Default Credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc):

   ```sh
   gcloud auth application-default login
   ```

1. Configure the default `gcloud` project:

   ```sh
   gcloud config set project $PROJECT_ID
   ```

1. Launch [Cloud SQL Auth Proxy](https://cloud.google.com/sql/docs/postgres/connect-instance-auth-proxy) (tip: you can `brew install cloud-sql-proxy`):

   ```sh
   INSTANCE=$(gcloud sql instances list --format "value(connectionName)")
   cloud-sql-proxy $INSTANCE
   ```

1. In another shell:

   ```sh
   psql "host=127.0.0.1 port=5432 sslmode=disable dbname=econia user=postgres"
   ```
