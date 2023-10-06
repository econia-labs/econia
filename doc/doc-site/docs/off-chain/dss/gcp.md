# Deploying on GCP

The Econia DSS is portable infrastructure that can be run locally or on cloud compute.

This guide will show you how to run the DSS on [Google Gloud Platform (GCP)](https://cloud.google.com/), assuming you have admin privileges.

:::tip
See the [`gcloud` CLI reference](https://cloud.google.com/sdk/gcloud/reference/) for more information on the commands used in this walkthrough.
:::

## Configure project

1. [Create a GCP organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization), [try GCP for free](https://cloud.google.com/free), or otherwise get access to GCP.

1. [Install the Google Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk).

1. List the [organizations](https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy#organizations) that you are a member of:

   ```sh
   gcloud organizations list
   ```

1. Store your preferred organization ID in a shell variable:

   ```sh
   ORGANIZATION_ID=<YOUR_ORGANIZATION_ID>
   ```

1. Choose a project ID (like `fast-15`) that complies with the [GCP project ID rules](https://cloud.google.com/sdk/gcloud/reference/projects/create) and store it in a shell variable:

   ```sh
   PROJECT_ID=<YOUR_PROJECT_ID>
   ```

1. Create a new [project](https://cloud.google.com/storage/docs/projects) with the name `econia-dss`:

   ```sh
   gcloud projects create $PROJECT_ID \
       --name econia-dss \
       --organization $ORGANIZATION_ID
   ```

1. List your billing account ID:

   ```sh
   gcloud alpha billing accounts list
   ```

   :::tip
   As of the time of this writing, some billing commands were still in alpha release.

   If you prefer a stable command release, you might not need to use the `alpha` keyword.
   :::

1. Store the billing account ID in a shell variable:

   ```sh
   BILLING_ACCOUNT_ID=<YOUR_BILLING_ACCOUNT_ID>
   ```

1. Link the billing account to the project:

   ```sh
   gcloud alpha billing projects link $PROJECT_ID \
       --billing-account $BILLING_ACCOUNT_ID
   ```

1. Set the project as default:

    ```sh
    gcloud config set project $PROJECT_ID
    ```

## Configure locations

1. List available build regions:

   ```sh
   gcloud artifacts locations list
   ```

1. Pick a region that is [close to you](https://cloud.google.com/artifact-registry/docs/repositories/repo-locations) and store it in a shell variable:

   ```sh
   BUILD_REGION=<NEARBY_REGION>
   ```

1. List available deployment zones:

   ```sh
   gcloud compute zones list
   ```

1. Pick a zone that is [close to you](https://cloud.google.com/compute/docs/regions-zones#available) and store it in a shell variable:

   ```sh
   DEPLOY_ZONE=<NEARBY_ZONE>
   ```

1. Store values as defaults:

   ```sh
   gcloud config set artifacts/location $BUILD_REGION
   gcloud config set compute/zone $DEPLOY_ZONE
   gcloud config set run/region $BUILD_REGION
   ```

## Build Docker images

1. Create a [GCP Artifact Registry](https://cloud.google.com/artifact-registry/docs/overview) Docker repository named `images`:

   ```sh
   gcloud artifacts repositories create images \
       --repository-format docker
   ```

1. Set the repository as default:

   ```sh
   gcloud config set artifacts/repository images
   ```

1. Clone the Econia repository:

   ```sh
   git clone https://github.com/econia-labs/econia.git
   ```

1. Build the DSS images from source:

   ```sh
   gcloud builds submit econia \
       --config econia/src/docker/gcp-tutorial-config.yaml \
       --substitutions _REGION=$BUILD_REGION
   ```

## Create shared storage

1. Create a [GCP Compute Engine instance](https://cloud.google.com/compute/docs/instances) for bootstrapping config files, with a [persistent disk](https://cloud.google.com/compute/docs/disks):

   ```sh
   gcloud compute instances create bootstrapper \
       --create-disk name=data
   ```

1. [Create an SSH key pair](https://cloud.google.com/compute/docs/connect/create-ssh-keys) to connect to the bootstrapper:

   ```sh
   mkdir ssh
   ssh-keygen -t rsa -f ssh/gcp -C bootstrapper -b 2048
   ```

1. Upload configuration files to bootstrapper:

   ```sh
   gcloud compute scp \
       econia/src/docker/database/configs/pg_hba.conf \
       bootstrapper:~ \
       --ssh-key-file ssh/gcp
   gcloud compute scp \
       econia/src/docker/database/configs/postgresql.conf \
       bootstrapper:~ \
       --ssh-key-file ssh/gcp
   ```

1. [Connect to](https://cloud.google.com/compute/docs/connect/standard-ssh) the bootstrapper instance:

   ```sh
   gcloud compute ssh bootstrapper --ssh-key-file ssh/gcp
   ```

1. [Check connected disks](https://cloud.google.com/compute/docs/disks/format-mount-disk-linux#format_linux):

   ```sh
   sudo lsblk
   ```

   :::tip
   The device name for the new blank persistent disk will probably be `sbd`.
   :::

1. Store the device name in a shell variable:

   ```sh
   DEVICE_NAME=<PROBABLY_sdb>
   ```

1. [Format and mount the disk with read/write permissions](https://cloud.google.com/compute/docs/disks/format-mount-disk-linux#format_linux):

   ```sh
   sudo mkfs.ext4 \
       -m 0 \
       -E lazy_itable_init=0,lazy_journal_init=0,discard \
       /dev/$DEVICE_NAME
   ```

   ```sh
   sudo mkdir -p /mnt/disks/data
   ```

   ```sh
   sudo mount -o \
       discard,defaults \
       /dev/$DEVICE_NAME \
       /mnt/disks/data
   ```

   ```sh
   sudo chmod a+w /mnt/disks/data
   ```

1. Create a PostgreSQL data directory and move the config files into it:

   ```sh
   mkdir /mnt/disks/data/postgresql
   mkdir /mnt/disks/data/postgresql/data
   mv pg_hba.conf /mnt/disks/data/postgresql/data/pg_hba.conf
   mv postgresql.conf /mnt/disks/data/postgresql/data/postgresql.conf
   ```

1. End the connection with the bootstrapper:

   ```
   exit
   ```

1. Detach the shared data disk from the bootstrapper instance:

   ```sh
   gcloud compute instances detach-disk bootstrapper --disk data
   ```

## Deploy database

1. Create an administrator username and password and store them in shell variables:

   ```sh
   ADMIN_NAME=<YOUR_ADMIN_NAME>
   ADMIN_PASSWORD=<YOUR_ADMIN_PW>
   ```

1. Deploy the `postgres` image as a [Compute Engine Container](https://cloud.google.com/compute/docs/containers/deploying-containers) with the shared disk as a [data volume](https://cloud.google.com/compute/docs/containers/configuring-options-to-run-containers#mounting_a_persistent_disk_as_a_data_volume):

   ```sh
   gcloud compute instances create-with-container postgres \
       --container-env "$(printf '%s' \
           POSTGRES_USER=$ADMIN_NAME,\
           POSTGRES_PASSWORD=$ADMIN_PASSWORD\
       )" \
       --container-image \
           $BUILD_REGION-docker.pkg.dev/$PROJECT_ID/images/postgres \
       --container-mount-disk "$(printf '%s' \
           mount-path=/var/lib,\
           name=data\
       )" \
       --disk "$(printf '%s' \
           name=data,\
           device-name=data\
       )"
   ```

1. Store the instance's [internal and external IP addresses](https://cloud.google.com/compute/docs/reference/rest/v1/instances) as well [your public IP address](https://stackoverflow.com/a/56068456) in shell variables:

    ```sh
    POSTGRES_EXTERNAL_IP=$(gcloud compute instances list \
        --filter="name=postgres" \
        --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
    POSTGRES_INTERNAL_IP=$(gcloud compute instances list \
        --filter="name=postgres" \
        --format="value(networkInterfaces[0].networkIP)")
    MY_IP=$(curl --silent http://checkip.amazonaws.com)
    echo "\n\nPostgreSQL internal IP: $POSTGRES_INTERNAL_IP"
    echo "PostgreSQL external IP: $POSTGRES_EXTERNAL_IP"
    echo "Your IP: $MY_IP"
    ```

1. Allow incoming traffic on port 5432 from your IP address:

   ```sh
   gcloud compute firewall-rules create pg-admin \
       --allow tcp:5432 \
       --direction INGRESS \
       --source-ranges $MY_IP
   ```

1. Note the full description of the firewall rule:

   ```sh
   gcloud compute firewall-rules describe pg-admin
   ```

1. Store the PostgreSQL connection string as an environment variable:

   ```sh
   export DATABASE_URL="$(printf '%s' postgres://\
       $ADMIN_NAME:\
       $ADMIN_PASSWORD@\
       $POSTGRES_EXTERNAL_IP:5432/econia
   )"
   echo $DATABASE_URL
   ```

1. Install [`diesel`](https://diesel.rs/guides/getting-started) if you don't already have it, then check that the database has an empty schema:

   ```sh
   diesel print-schema
   ```

1. Run the database migrations then check the schema again:

   ```sh
   cd econia/src/rust/dbv2
   diesel migration run
   diesel print-schema
   cd ../../../..
   ```

## Deploy REST API

1. Deploy [PostgREST](https://postgrest.org/en/stable/) on [GCP Cloud Run](https://cloud.google.com/run/docs/overview/what-is-cloud-run) with [public access](https://cloud.google.com/run/docs/authenticating/public):

    ```sh
    POSTGREST_URL="$(printf '%s' postgres://\
        $ADMIN_NAME:\
        $ADMIN_PASSWORD@\
        $POSTGRES_INTERNAL_IP:5432/econia
    )"
    gcloud run deploy postgrest \
        --allow-unauthenticated \
        --image=us-docker.pkg.dev/postgrest/postgrest \
        --set-env-vars "$(printf '%s' \
            PGRST_DB_ANON_ROLE=web_anon,\
            PGRST_DB_SCHEMA=api,\
            PGRST_DB_URI=$POSTGREST_URL\
        )"
    ```