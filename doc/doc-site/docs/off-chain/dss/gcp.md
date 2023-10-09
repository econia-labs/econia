# Deploying on GCP

The Econia DSS is portable infrastructure that can be run locally or on cloud compute.

This guide will show you how to run the DSS on [Google Gloud Platform (GCP)](https://cloud.google.com/), assuming you have admin privileges.

:::tip
See the [`gcloud` CLI reference](https://cloud.google.com/sdk/gcloud/reference/) for more information on the commands used in this walkthrough.
:::

## Initial setup

Follow the steps in this section in order, making sure to keep the relevant shell variables stored in your active shell session.

:::tip
Use a scratchpad text file to store shell variable assignment statements that you can copy-paste into your shell:

```sh
ORGANIZATION_ID=123456789012
BILLING_ACCOUNT_ID=ABCDEF-GHIJKL-MNOPQR
REGION=a-region
ZONE=a-zone
```

:::

### Configure project

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

   ```sh
   echo $ORGANIZATION_ID
   ```

1. Choose a project ID (like `fast-15`) that complies with the [GCP project ID rules](https://cloud.google.com/sdk/gcloud/reference/projects/create) and store it in a shell variable:

   ```sh
   PROJECT_ID=<YOUR_PROJECT_ID>
   ```

   ```sh
   echo $PROJECT_ID
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

   ```sh
   echo $BILLING_ACCOUNT_ID
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

### Configure locations

1. List available build regions:

   ```sh
   gcloud artifacts locations list
   ```

1. Pick a region that is [close to you](https://cloud.google.com/artifact-registry/docs/repositories/repo-locations) and store it in a shell variable:

   ```sh
   REGION=<NEARBY_REGION>
   ```

1. List available deployment zones:

   ```sh
   gcloud compute zones list
   ```

1. Pick a zone that is [close to you](https://cloud.google.com/compute/docs/regions-zones#available) and store it in a shell variable:

   ```sh
   ZONE=<NEARBY_ZONE>
   ```

1. Store values as defaults:

   ```sh
   echo $REGION
   echo $ZONE
   ```

   ```sh
   gcloud config set artifacts/location $REGION
   gcloud config set compute/zone $ZONE
   gcloud config set run/region $REGION
   ```

### Build images

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
       --substitutions _REGION=$REGION
   ```

   :::tip
   This will take a while, since it involves the compilation of several binaries from source.
   :::

### Create bootstrapper

1. Create a [GCP Compute Engine instance](https://cloud.google.com/compute/docs/instances) for bootstrapping config files, with two attached [persistent disks](https://cloud.google.com/compute/docs/disks):

   ```sh
   gcloud compute instances create bootstrapper \
       --create-disk "$(printf '%s' \
            auto-delete=no,\
            name=postgres-disk,\
            size=100GB\
       )" \
       --create-disk "$(printf '%s' \
            auto-delete=no,\
            name=processor-disk,\
            size=1GB\
       )"
   ```

1. [Create an SSH key pair](https://cloud.google.com/compute/docs/connect/create-ssh-keys) and use it to upload PostgreSQL configuration files to the bootstrapper:

   ```sh
   mkdir ssh
   ssh-keygen -t rsa -f ssh/gcp -C bootstrapper -b 2048 -q -N ""
   gcloud compute scp \
       econia/src/docker/database/configs/pg_hba.conf \
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
   The device name for the `postgres` disk will probably be `sbd`, and the device name for the `processor` will probably be `sdc` (check the disk sizes if you are unsure).
   :::

1. Store the device names in shell variables:

   ```sh
   POSTGRES_DISK_DEVICE_NAME=<PROBABLY_sdb>
   PROCESSOR_DISK_DEVICE_NAME=<PROBABLY_sdc>
   ```

   ```sh
   echo "PostgreSQL disk device name: $POSTGRES_DISK_DEVICE_NAME"
   echo "Processor disk device name: $PROCESSOR_DISK_DEVICE_NAME"
   ```

1. [Format and mount the disks with read/write permissions](https://cloud.google.com/compute/docs/disks/format-mount-disk-linux#format_linux):

   ```sh
   sudo mkfs.ext4 \
       -m 0 \
       -E lazy_itable_init=0,lazy_journal_init=0,discard \
       /dev/$POSTGRES_DISK_DEVICE_NAME
   sudo mkfs.ext4 \
       -m 0 \
       -E lazy_itable_init=0,lazy_journal_init=0,discard \
       /dev/$PROCESSOR_DISK_DEVICE_NAME
   sudo mkdir -p /mnt/disks/postgres
   sudo mkdir -p /mnt/disks/processor
   sudo mount -o \
       discard,defaults \
       /dev/$POSTGRES_DISK_DEVICE_NAME \
       /mnt/disks/postgres
   sudo mount -o \
       discard,defaults \
       /dev/$PROCESSOR_DISK_DEVICE_NAME \
       /mnt/disks/processor
   sudo chmod a+w /mnt/disks/postgres
   sudo chmod a+w /mnt/disks/processor
   ```

1. Create a PostgreSQL data directory and move the config files into it:

   ```sh
   mkdir /mnt/disks/postgres/data
   mv pg_hba.conf /mnt/disks/postgres/data/pg_hba.conf
   mv postgresql.conf /mnt/disks/postgres/data/postgresql.conf
   ```

1. End the connection with the bootstrapper:

   ```sh
   exit
   ```

1. Detach `postgres-disk` from the bootstrapper:

   ```sh
   gcloud compute instances detach-disk bootstrapper --disk postgres-disk
   ```

### Deploy database

1. Create an administrator username and password and store them in shell variables:

   ```sh
   ADMIN_NAME=<YOUR_ADMIN_NAME>
   ADMIN_PASSWORD=<YOUR_ADMIN_PW>
   ```

   ```sh
   echo "Admin name: $ADMIN_NAME"
   echo "Admin password: $ADMIN_PASSWORD"
   ```

1. Deploy the `postgres` image as a [Compute Engine Container](https://cloud.google.com/compute/docs/containers/deploying-containers) with the `postgres` disk as a [data volume](https://cloud.google.com/compute/docs/containers/configuring-options-to-run-containers#mounting_a_persistent_disk_as_a_data_volume):

   ```sh
   gcloud compute instances create-with-container postgres \
       --container-env "$(printf '%s' \
           POSTGRES_USER=$ADMIN_NAME,\
           POSTGRES_PASSWORD=$ADMIN_PASSWORD\
       )" \
       --container-image \
           $REGION-docker.pkg.dev/$PROJECT_ID/images/postgres:latest \
       --container-mount-disk "$(printf '%s' \
           mount-path=/var/lib/postgresql,\
           name=postgres-disk\
       )" \
       --disk "$(printf '%s' \
           auto-delete=no,\
           device-name=postgres-disk,\
           name=postgres-disk\
       )"
   ```

1. Store the instance's [internal and external IP addresses](https://cloud.google.com/compute/docs/reference/rest/v1/instances) as well [your public IP address](https://stackoverflow.com/a/56068456) in shell variables:

   ```sh
   POSTGRES_EXTERNAL_IP=$(gcloud compute instances list \
       --filter name=postgres \
       --format "value(networkInterfaces[0].accessConfigs[0].natIP)" \
   )
   POSTGRES_INTERNAL_IP=$(gcloud compute instances list \
       --filter name=postgres \
       --format "value(networkInterfaces[0].networkIP)" \
   )
   MY_IP=$(curl --silent http://checkip.amazonaws.com)
   echo "\n\nPostgreSQL external IP: $POSTGRES_EXTERNAL_IP"
   echo "PostgreSQL internal IP: $POSTGRES_INTERNAL_IP"
   echo "Your IP: $MY_IP"
   ```

1. Promote the instance's [external](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#promote_ephemeral_ip) and [internal](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-internal-ip-address#promote-in-use-internal-address) addresses from ephemeral to static:

   ```sh
   gcloud compute addresses create postgres-external \
       --addresses $POSTGRES_EXTERNAL_IP \
       --region $REGION
   ```

   ```sh
   gcloud compute addresses create postgres-internal \
       --addresses $POSTGRES_INTERNAL_IP \
       --region $REGION \
       --subnet default
   ```

1. Allow incoming traffic on port 5432 from your IP address:

   ```sh
   gcloud compute firewall-rules create pg-admin \
       --allow tcp:5432 \
       --direction INGRESS \
       --source-ranges $MY_IP
   ```

1. Store the PostgreSQL public connection string as an environment variable:

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

   :::tip
   You might not be able to connect to the database until a minute or so after you've first created the instance.
   :::

1. Run the database migrations then check the schema again:

   ```sh
   cd econia/src/rust/dbv2
   diesel migration run
   diesel print-schema
   cd ../../../..
   ```

### Deploy REST API

1. [Create a connector](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#create-connector) for your project's `default` [Virtual Private Cloud (VPC)](https://cloud.google.com/vpc/docs/overview) network:

   ```sh
   gcloud compute networks vpc-access connectors create \
       postgrest \
       --range 10.8.0.0/28 \
       --region $REGION
   ```

1. Verify that the connector is ready:

   ```sh
   STATE=$(gcloud compute networks vpc-access connectors describe \
       postgrest \
       --region $REGION \
       --format "value(state)"
   )
   echo "Connector state is: $STATE"
   ```

1. Construct the PosgREST connection URL to connect to the `postgres` instance:

   ```sh
   DB_URL_PRIVATE="$(printf '%s' postgres://\
       $ADMIN_NAME:\
       $ADMIN_PASSWORD@\
       $POSTGRES_INTERNAL_IP:5432/econia
   )"
   echo $DB_URL_PRIVATE
   ```

1. Deploy [PostgREST](https://postgrest.org/en/stable/) on [GCP Cloud Run](https://cloud.google.com/run/docs/overview/what-is-cloud-run) with [public access](https://cloud.google.com/run/docs/authenticating/public):

   ```sh
   gcloud run deploy postgrest \
       --allow-unauthenticated \
       --image \
           $REGION-docker.pkg.dev/$PROJECT_ID/images/postgrest:latest \
       --port 3000 \
       --set-env-vars "$(printf '%s' \
           PGRST_DB_ANON_ROLE=web_anon,\
           PGRST_DB_SCHEMA=api,\
           PGRST_DB_URI=$DB_URL_PRIVATE\
       )" \
       --vpc-connector postgrest
   ```

1. Store the [service URL](https://cloud.google.com/run/docs/reference/rest/v1/namespaces.services#ServiceStatus) in a shell variable:

   ```sh
   export REST_URL=$(
       gcloud run services describe postgrest \
           --format "value(status.url)"
   )
   echo $REST_URL
   ```

1. Verify that you can query the PostgREST API from the public URL:

   ```sh
   curl $REST_URL
   ```

### Deploy processor

1. Create a config at `econia/src/docker/processor/config.yaml` per the [general DSS guidelies](./data-service-stack.md):

   :::tip
   For `postgres_connection_string` use the same one that the `postgrest` service uses:

   ```sh
   echo $DB_URL_PRIVATE
   ```

   :::

1. Upload the processor config to the bootstrapper:

   ```sh
   gcloud compute scp \
       econia/src/docker/processor/config.yaml \
       bootstrapper:~ \
       --ssh-key-file ssh/gcp
   ```

1. Connect to the bootstrapper:

   ```sh
   gcloud compute ssh bootstrapper --ssh-key-file ssh/gcp
   ```

1. Create a processor data directory and move the config file into it:

   ```sh
   mkdir /mnt/disks/processor/data
   mv config.yaml /mnt/disks/processor/data/config.yaml
   ```

1. End the connection with the bootstrapper:

   ```sh
   exit
   ```

1. Stop the bootstrapper:

   ```sh
   gcloud compute instances stop bootstrapper
   ```

1. Detach `processor-disk` from the bootstrapper:

   ```sh
   gcloud compute instances detach-disk bootstrapper --disk processor-disk
   ```

1. Deploy the `processor` image:

   ```sh
   gcloud compute instances create-with-container processor \
       --container-env HEALTHCHECK_BEFORE_START=false \
       --container-image \
           $REGION-docker.pkg.dev/$PROJECT_ID/images/processor:latest \
       --container-mount-disk "$(printf '%s' \
           mount-path=/config,\
           name=processor-disk\
       )" \
       --disk "$(printf '%s' \
           auto-delete=no,\
           device-name=processor-disk,\
           name=processor-disk\
       )"
   ```

1. Give the processor a minute or so to start up, then [view the container logs](https://cloud.google.com/compute/docs/containers/deploying-containers#viewing_container_logs):

   ```sh
   PROCESSOR_ID=$(gcloud compute instances describe processor \
       --zone $ZONE \
       --format="value(id)"
   )
   gcloud logging read "resource.type=gce_instance AND \
       logName=projects/$PROJECT_ID/logs/cos_containers AND \
       resource.labels.instance_id=$PROCESSOR_ID" \
       --limit 5
   ```

1. Once the processor has had enough time to sync, check some of the events:

   ```sh
   curl $REST_URL/<AN_ENDPOINT>
   ```

   :::tip
   For immediate results (but with missed events and a corrupted database) during testing, use a testnet config with the following:

   - `econia_address: 0xc0de11113b427d35ece1d8991865a941c0578b0f349acabbe9753863c24109ff`
   - `starting_version: 683453241`

   Then try `curl $REST_URL/balance_updates`, since this starting version immediately precedes a series of balance update operations on tesnet.
   :::

### Deploy aggregator

1. Deploy an `aggregator` instance using the private connection string:

   ```sh
   echo $DB_URL_PRIVATE
   ```

   ```sh
   gcloud compute instances create-with-container aggregator \
       --container-env DATABASE_URL=$DB_URL_PRIVATE \
       --container-image \
           $REGION-docker.pkg.dev/$PROJECT_ID/images/aggregator:latest
   ```

1. Wait a minute or two then check logs:

   ```sh
   AGGREGATOR_ID=$(gcloud compute instances describe aggregator \
       --zone $ZONE \
       --format="value(id)"
   )
   gcloud logging read "resource.type=gce_instance AND \
       logName=projects/$PROJECT_ID/logs/cos_containers AND \
       resource.labels.instance_id=$AGGREGATOR_ID" \
       --limit 5
   ```

1. Once the aggregator has had enough time to aggregate events, check some aggregated data.
   For example on testnet:

   ```sh
   echo $REST_URL
   ```

   ```sh
   curl "$(printf '%s' \
       "$REST_URL/"\
       "limit_orders?"\
       "order=price.desc,"\
       "last_increase_stamp.asc&"\
       "market_id=eq.3&"\
       "side=eq.ask&"\
       "order_status=eq.closed&"\
       "limit=3"\
   )"
   ```

### Deploy WebSockets API

1. Create a connector:

   ```sh
   gcloud compute networks vpc-access connectors create \
       websockets \
       --range 10.64.0.0/28 \
       --region $REGION
   ```

1. Verify connector readiness:

   ```sh
   STATE=$(gcloud compute networks vpc-access connectors describe \
       websockets \
       --region $REGION \
       --format "value(state)"
   )
   echo "Connector state is: $STATE"
   ```

1. Construct WebSockets connection string:

   ```sh
   PGWS_DB_URI="$(printf '%s' postgres://\
       $ADMIN_NAME:\
       $ADMIN_PASSWORD@\
       $POSTGRES_INTERNAL_IP/econia
   )"
   echo $PGWS_DB_URI
   ```

1. Deploy the `websockets` service:

   ```sh
   gcloud run deploy websockets \
       --allow-unauthenticated \
       --image \
           $REGION-docker.pkg.dev/$PROJECT_ID/images/websockets:latest \
       --port 3000 \
       --set-env-vars "$(printf '%s' \
           PGWS_DB_URI=$PGWS_DB_URI,\
           PGWS_JWT_SECRET=econia_0000000000000000000000000,\
           PGWS_CHECK_LISTENER_INTERVAL=1000,\
           PGWS_LISTEN_CHANNEL=econiaws\
       )" \
       --vpc-connector websockets
   ```

1. Store service URL:

   ```sh
   WS_HTTPS_URL=$(
       gcloud run services describe websockets \
           --format "value(status.url)"
   )
   export WS_URL=$(echo $WS_HTTPS_URL | sed 's/https/wss/')
   echo $WS_URL
   ```

1. Monitor events using the [WebSockets listening script](./websocket.md):

   ```sh
   echo $WS_URL
   echo $REST_URL
   echo $WS_CHANNEL
   ```

   ```sh
   cd econia/src/python/sdk
   poetry install
   poetry run event
   ```

   ```sh
   # To quit
   <Ctrl+C>
   ```

   ```sh
   cd ../../../..
   ```

## Redeployment

Once you have the DSS running you might want to redeploy within the same GCP project, for example using a different chain or with new image binaries.

Whenever you redeploy, restart all instances and services, and reset the database as follows so that you do not break startup dependencies or generate any corrupted data.

### Basic

1. [Rebuild images](#build-images) in the existing `images` registry.

   :::tip
   All deploy commands use the `latest` image.
   :::

1. Delete `postgrest` and `websockets` services:

   ```sh
   gcloud run services delete postgrest --quiet
   gcloud run services delete websockets --quiet
   ```

   :::tip
   When these are redeployed, they will [have the same endpoint URL as before](https://cloud.google.com/run/docs/managing/services#delete).
   :::

1. Stop `aggregator` and `processor` instances, then `postgres` instance:

   ```sh
   gcloud compute instances stop aggregator --quiet
   gcloud compute instances stop processor --quiet
   gcloud compute instances stop postgres --quiet
   ```

1. Optionally [change the processor config](#change-processor-config).

1. Update `postgres` container and restart:

   ```sh
   echo $ADMIN_NAME
   echo $ADMIN_PASSWORD
   echo $REGION
   echo $PROJECT_ID
   ```

   ```sh
   gcloud compute instances update-container postgres \
       --container-env "$(printf '%s' \
           POSTGRES_USER=$ADMIN_NAME,\
           POSTGRES_PASSWORD=$ADMIN_PASSWORD\
       )" \
       --container-image \
           $REGION-docker.pkg.dev/$PROJECT_ID/images/postgres:latest \
       --container-mount-disk "$(printf '%s' \
           mount-path=/var/lib/postgresql,\
           name=postgres-disk\
       )"
   ```

   ```sh
   gcloud compute instances start postgres
   ```

1. Reset the database:

   ```sh
   POSTGRES_EXTERNAL_IP=$(gcloud compute instances list \
       --filter name=postgres \
       --format "value(networkInterfaces[0].accessConfigs[0].natIP)" \
   )
   export DATABASE_URL="$(printf '%s' postgres://\
       $ADMIN_NAME:\
       $ADMIN_PASSWORD@\
       $POSTGRES_EXTERNAL_IP:5432/econia
   )"
   echo $DATABASE_URL
   ```

   ```sh
   cd econia/src/rust/dbv2
   diesel database reset
   cd ../../../..
   ```

   :::tip
   Give the instance a minute or so to start up before resetting the database.
   :::

1. Update `processor` container and restart:

   ```sh
   gcloud compute instances update-container processor \
       --container-env HEALTHCHECK_BEFORE_START=false \
       --container-image \
           $REGION-docker.pkg.dev/$PROJECT_ID/images/processor:latest \
       --container-mount-disk "$(printf '%s' \
           mount-path=/config,\
           name=processor-disk\
       )"
   ```

   ```sh
   gcloud compute instances start processor
   ```

1. Update `aggregator` container and restart:

   ```sh
   POSTGRES_INTERNAL_IP=$(gcloud compute instances list \
       --filter name=postgres \
       --format "value(networkInterfaces[0].networkIP)" \
   )
   DB_URL_PRIVATE="$(printf '%s' postgres://\
       $ADMIN_NAME:\
       $ADMIN_PASSWORD@\
       $POSTGRES_INTERNAL_IP:5432/econia
   )"
   echo $DB_URL_PRIVATE
   ```

   ```sh
   gcloud compute instances update-container aggregator \
       --container-env DATABASE_URL=$DB_URL_PRIVATE \
       --container-image \
           $REGION-docker.pkg.dev/$PROJECT_ID/images/aggregator:latest
   ```

   ```sh
   gcloud compute instances start aggregator
   ```

1. Redeploy `postgrest` using the `gcloud run deploy` command [from initial deployment](#deploy-rest-api).

1. Redeploy `websockets` using the `gcloud run deploy` command [from initial deployment](#deploy-websockets-api), after reconstructing the WebSockets connection string:

   ```sh
   PGWS_DB_URI="$(printf '%s' postgres://\
       $ADMIN_NAME:\
       $ADMIN_PASSWORD@\
       $POSTGRES_INTERNAL_IP/econia
   )"
   echo $PGWS_DB_URI
   ```

### Change processor config

1. Start the [basic redeployment](#basic) checklist, but after you shut down `processor` complete the rest of this checklist before continuing.

1. Update your local processor config at `econia/src/docker/processor/config.yaml`.

1. Detach `processor-disk` from the processor and attach to the bootsrapper:

   ```sh
   gcloud compute instances detach-disk processor --disk processor-disk
   gcloud compute instances attach-disk bootstrapper --disk processor-disk
   ```

1. Start the bootstrapper:

   ```sh
   gcloud compute instances start bootstrapper
   ```

1. Upload the config:

   ```sh
   gcloud compute scp \
       econia/src/docker/processor/config.yaml \
       bootstrapper:~ \
       --ssh-key-file ssh/gcp
   ```

   :::tip

   You'll need to [create more SSH keys](#create-bootstrapper) if you deleted the ones you were previously using.

   :::

1. Connect to the bootstrapper:

   ```sh
   gcloud compute ssh bootstrapper --ssh-key-file ssh/gcp
   ```

1. Mount the disk:

   ```sh
   sudo lsblk
   ```

   ```sh
   PROCESSOR_DISK_DEVICE_NAME=<NEW_NAME>
   ```

   ```sh
   echo $PROCESSOR_DISK_DEVICE_NAME
   ```

   ```sh
   sudo mount -o \
       discard,defaults \
       /dev/$PROCESSOR_DISK_DEVICE_NAME \
       /mnt/disks/processor
   sudo chmod a+w /mnt/disks/processor
   ```

   :::tip
   See the [bootstrapper creation](#create-bootstrapper) process for a recapitulation of this process
   :::

1. Replace the old config:

   ```sh
   mv config.yaml /mnt/disks/processor/data/config.yaml
   echo "New config:"
   cat /mnt/disks/processor/data/config.yaml
   echo
   ```

1. Disconnect from the bootstrapper:

   ```sh
   exit
   ```

1. Stop the bootstrapper:

   ```sh
   gcloud compute instances stop bootstrapper
   ```

1. Detach the `processor-disk` from the bootstrapper, and reattach to the processor:

   ```sh
   gcloud compute instances detach-disk bootstrapper --disk processor-disk
   gcloud compute instances attach-disk processor \
       --device-name processor-disk \
       --disk processor-disk
   ```
