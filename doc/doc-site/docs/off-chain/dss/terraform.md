# Using Terraform

If you have already finished the [Google Cloud Platform (GCP) tutorial](gcp.md) and are looking for a more programmatic deployment process, this guide will show you how to use [Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/infrastructure-as-code) to deploy the Econia DSS via declarative configurations.

This guide is for a specific use case, the Econia testnet trading competition leaderboard backend, but you can adapt as needed for your particular use case.

## Configure project

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli).

1. Clone the Econia repository:

   ```sh
   git clone https://github.com/econia-labs/econia.git
   ```

1. Navigate to the `leaderboard-backend` project directory:

   ```sh
   cd econia/src/terraform/leaderboard-backend
   ```

1. [Configure a billable GCP project](gcp#configure-project).

1. Store the project ID in a [Terraform variable file](https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables):

   ```sh
   echo $PROJECT_ID
   ```

   ```sh
   echo "project = \"$PROJECT_ID\"" > terraform.tfvars
   ```

1. Generate keys for a [service account](https://cloud.google.com/iam/docs/service-account-overview) with project editor privileges:

   ```sh
   gcloud iam service-accounts create terraform \
       --display-name "Terraform"
   ```

   ```sh
   SERVICE_ACCOUNT_NAME=terraform@$PROJECT_ID.iam.gserviceaccount.com
   echo $SERVICE_ACCOUNT_NAME
   ```

   ```
   gcloud projects add-iam-policy-binding $PROJECT_ID \
       --member "serviceAccount:$SERVICE_ACCOUNT_NAME" \
       --role "roles/editor"
   ```

   ```sh
   gcloud iam service-accounts keys create gcp-key.json \
       --iam-account $SERVICE_ACCOUNT_NAME
   ```

1. Enable relevant GCP services:

   ```sh
   gcloud services enable compute.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   ```

1. Pick a database root password:

   ```sh
   DB_ROOT_PASSWORD=<DB_ROOT_PASSWORD>
   ```

   ```sh
   echo $DB_ROOT_PASSWORD
   ```

   ```sh
   echo "db_root_password = \"$DB_ROOT_PASSWORD\"" >> terraform.tfvars
   ```

1. Store [your public IP address](https://stackoverflow.com/a/56068456):

   ```sh
   MY_IP=$(curl --silent http://checkip.amazonaws.com)
   echo $MY_IP
   echo "db_admin_public_ip = \"$MY_IP\"" >> terraform.tfvars
   ```

1. Format:

   ```sh
   terraform fmt
   ```

1. Initialize the directory:

   ```sh
   terraform init
   ```

## Build infrastructure

1. Apply the configuration:

   ```sh
   terraform apply
   ```

1. View outputs:

   ```sh
   terraform output
   ```

## Take down infrastructure

1. Destroy project resources:

   ```sh
   terraform destroy
   ```

1. Delete GCP project:

   ```sh
   gcloud projects delete $PROJECT_ID
   ```

## Diagnostics

### Connect to PostgreSQL

1. Get [`psql`](https://www.postgresql.org/download/).

1. Connect:

   ```sh
   psql \
       --dbname econia \
       --host $(terraform output -raw postgres_public_ip) \
       --username postgres
   ```
