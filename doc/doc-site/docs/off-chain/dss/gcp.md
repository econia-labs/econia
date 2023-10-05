# Deploying on GCP

The Econia DSS is portable infrastructure that can be run locally or on cloud compute.

This guide will show you how to run the DSS on [Google Gloud Platform (GCP)](https://cloud.google.com/), assuming you have admin privileges.

:::tip
See the [`gcloud` CLI reference](https://cloud.google.com/sdk/gcloud/reference/) for more information on the commands used in this walkthrough.
:::

## Configure a billable project

1. [Create a GCP organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization), [try GCP for free](https://cloud.google.com/free), or otherwise get access to GCP.

1. [Install the Google Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk).

1. List the [organizations](https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy#organizations) that you are a member of:

   ```sh
   gcloud organizations list
   ```

1. Store your organization ID in a shell variable:

   ```sh
   ORG_ID=<YOUR_ORG_ID>
   ```

1. Choose a project ID that complies with the [GCP project ID rules](https://cloud.google.com/sdk/gcloud/reference/projects/create) and store it in a shell variable:

   ```sh
   PROJ_ID=<PREFERRED_PROJECT_ID>
   ```

1. Create a new [project](https://cloud.google.com/storage/docs/projects) with the name `econia-dss`:

   ```sh
   gcloud projects create $PROJ_ID \
       --name econia-dss \
       --organization $ORG_ID
   ```

1. Check your projects to verify that the project is listed:

   ```sh
   gcloud projects list
   ```

1. List your billing account ID:

   ```sh
   gcloud billing accounts list
   ```

   :::tip
   Some of the billing commands are still in alpha release, and the CLI may recommend you substitute `gcloud alpha billing`.
   :::

1. Store the billing account ID in a shell variable:

   ```sh
   BILLING_ACCOUNT_ID=<YOUR_BILLING_ACCOUNT_ID>
   ```

1. Link the billing account to the project:

   ```sh
   gcloud billing projects link $PROJ_ID \
       --billing-account $BILLING_ACCOUNT_ID
   ```

1. Verify that the project is linked:

   ```sh
   gcloud billing projects list \
       --billing-account $BILLING_ACCOUNT_ID
   ```

## Build Docker images

1. List available build regions:

   ```sh
   gcloud artifacts locations list --project $PROJ_ID
   ```

1. Pick a region that is [close to you](https://cloud.google.com/artifact-registry/docs/repositories/repo-locations) and store it in a shell variable:

   ```sh
   BUILD_REGION=<NEARBY_REGION>
   ```

1. Create a [GCP Artifact Registry](https://cloud.google.com/artifact-registry/docs/overview) Docker repository named `images`:

   ```sh
   gcloud artifacts repositories create images \
       --location $BUILD_REGION \
       --project $PROJ_ID \
       --repository-format docker
   ```

1. Verify that your repository was created:

   ```sh
   gcloud artifacts repositories list --project $PROJ_ID
   ```

1. Create an administrator username and password and store them in shell variables:

   ```sh
   ADMIN_NAME=<YOUR_ADMIN_NAME>
   ADMIN_PW=<YOUR_ADMIN_PW>
   ```

1. Clone the Econia repository:

   ```sh
   git clone https://github.com/econia-labs/econia.git
   ```

1. Build the DSS images from source:

   ```sh
   gcloud builds submit econia \
       --config econia/src/docker/gcp-tutorial-config.yaml \
       --project $PROJ_ID \
       --region $BUILD_REGION \
       --substitutions "$(printf '%s' \
           _ADMIN_NAME=$ADMIN_NAME,\
           _ADMIN_PW=$ADMIN_PW,\
           _REGION=$BUILD_REGION\
       )"
   ```

1. Verify the Docker artifacts:

   ```sh
   gcloud artifacts docker images list \
       $BUILD_REGION-docker.pkg.dev/$PROJ_ID/images
   ```

## Deploy database

1. List available deployment zones:

   ```sh
   gcloud compute zones list --project $PROJ_ID
   ```

1. Pick a zone that is [close to you](https://cloud.google.com/compute/docs/regions-zones) and store it in a shell variable:

   ```sh
   DEPLOY_ZONE=<NEARBY_ZONE>
   ```

1. Deploy the `postgres` image as a [GCP Compute Engine instance](https://cloud.google.com/compute/docs/containers):

   ```sh
   gcloud compute instances create-with-container postgres \
       --container-image \
           $BUILD_REGION-docker.pkg.dev/$PROJ_ID/images/postgres \
       --project $PROJ_ID \
       --zone $DEPLOY_ZONE
   ```

1. Verify your instance is listed as running:

   ```sh
   gcloud compute instances list --project $PROJ_ID
   ```

1. Store the external IP address in a shell variable:

   ```sh
   POSTGRES_IP=<POSTGRES_EXTERNAL_IP>
   ```

1. Allow incoming traffic on port 5432:

   ```sh
   gcloud compute firewall-rules create pg-admin \
       --allow tcp:5432 \
       --direction INGRESS \
       --project $PROJ_ID
   ```

1. Verify the firewall rule is listed:

   ```sh
   gcloud compute firewall-rules list --project $PROJ_ID
   ```

1. Store the PostgreSQL connection string as an environment variable:

   ```sh
   export DATABASE_URL=postgres://$ADMIN_NAME:$ADMIN_PW@$POSTGRES_IP:5432/econia
   ```