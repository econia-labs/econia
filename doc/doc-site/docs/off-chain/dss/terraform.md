# Using Terraform

If you have already finished the [Google Cloud Platform (GCP) tutorial](gcp.md) and are looking for a more programmatic deployment process, this guide will show you how to use [Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/infrastructure-as-code) to deploy the Econia DSS via declarative configurations.

This guide is for a specific use case, the Econia testnet trading competition leaderboard backend, but you can adapt as needed for your particular use case.

## Configure project

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli).

1. Get [Diesel for postgres](https://diesel.rs/guides/getting-started).

1. Clone the Econia repository and navigate to the `leaderboard-backend` project directory:

   ```sh
   git clone https://github.com/econia-labs/econia.git
   cd econia
   git submodule update --init --recursive
   cd src/terraform/leaderboard-backend
   ```

1. [Configure a billable GCP project](gcp#configure-project) and store the project ID:

   ```sh
   echo $PROJECT_ID
   ```

   ```sh
   gcloud config set project $PROJECT_ID
   ```

1. Pick a database root password:

   ```sh
   DB_ROOT_PASSWORD=<DB_ROOT_PASSWORD>
   ```

   ```sh
   echo $DB_ROOT_PASSWORD
   ```

   :::tip
   Avoid using the special characters `@`, `/`, `.`, or `:`, which are used in connection strings.
   :::

1. Store [your public IP address](https://stackoverflow.com/a/56068456):

   ```sh
   MY_IP=$(curl --silent http://checkip.amazonaws.com)
   echo $MY_IP
   ```

1. Generate keys for a [service account](https://cloud.google.com/iam/docs/service-account-overview):

   ```sh
   gcloud iam service-accounts create terraform
   ```

   ```sh
   SERVICE_ACCOUNT_NAME=terraform@$PROJECT_ID.iam.gserviceaccount.com
   echo $SERVICE_ACCOUNT_NAME
   ```

   ```sh
   gcloud iam service-accounts keys create gcp-key.json \
       --iam-account $SERVICE_ACCOUNT_NAME
   ```

1. Generate SSH keys:

   ```sh
   rm -rf ssh
   mkdir ssh
   ssh-keygen -t rsa -f ssh/gcp -C bootstrapper -b 2048 -q -N ""
   ```

1. Store variables in a [Terraform variable file](https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables), then format and initialize the directory:

   ```sh
   echo "project = \"$PROJECT_ID\"" > terraform.tfvars
   echo "db_admin_public_ip = \"$MY_IP\"" >> terraform.tfvars
   echo "db_root_password = \"$DB_ROOT_PASSWORD\"" >> terraform.tfvars
   ```

   ```sh
   terraform fmt
   ```

   ```sh
   echo "\n\nContents of terraform.tfvars:\n\n"
   cat terraform.tfvars
   ```

   ```sh
   terraform init
   ```

## Build infrastructure

1. Update `/src/docker/processor/config.yaml`.

   :::tip
   Don't worry about `postgres_connection_string`, this will be automatically handled later.
   :::

1. Apply the configuration:

   ```sh
   terraform apply --parallelism 20
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

   :::tip
   This might not destroy quite everything, since [GCP has a Cloud SQL deletion waiting period that blocks the deletion of private service networking](https://cloud.google.com/vpc/docs/configure-private-services-access#removing-connection).
   This issue was supposed to be resolved as of the [Google Provider 5.0.0 release for Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/version_5_upgrade#resource-google_service_networking_connection), but it appears not to be resolved per https://github.com/hashicorp/terraform-provider-google/issues/16275.

   If `terraform destroy` gets stuck on deleting the network connection, you can manually delete the network connection [in the GCP console](https://console.cloud.google.com/networking/peering) then run `terraform destroy` again.

   Or you can simply delete the project even if Terraform has not destroyed all resources.
   :::

1. Delete GCP project:

   ```sh
   gcloud projects delete $PROJECT_ID
   ```

## Diagnostics

### Connect to PostgreSQL

1. Get [`psql`](https://www.postgresql.org/download/).

1. Connect:

   ```sh
   psql $(terraform output -raw db_conn_str_admin)
   ```

### Target a specific resource

1. Apply:

   ```sh
   terraform apply -target <RESOURCE_NAME>
   ```

1. Destroy:

   ```sh
   terraform destroy -target <RESOURCE_NAME>
   ```

### Generate a dependency graph

1. Check that you have `dot`:

   ```sh
   which dot
   ```

1. [Generate graph](https://developer.hashicorp.com/terraform/cli/commands/graph#generating-images):

   ```sh
   terraform graph | dot -Tsvg > graph.svg
   ```

### Check resource metadata

1. [Show state](https://developer.hashicorp.com/terraform/cli/commands/show):

   ```sh
   terraform show
   ```

1. [List state](https://developer.hashicorp.com/terraform/cli/commands/state/list):

   ```sh
   terraform state list
   ```

1. [Show state for a resource](https://developer.hashicorp.com/terraform/cli/commands/state/show)

   ```sh
   terraform state show <RESOURCE_TYPE.RESOURCE_NAME>
   ```
