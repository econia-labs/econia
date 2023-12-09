---
title: CI/CD
---

# Continuous integration and deployment

If you have already finished the [Terraform tutorial](terraform.md) and would rather not rebuild the entire DSS every time a new upgrade comes out, this guide will help you set up continuous integration/continuous deployment (CI/CD) workflows for your DSS deployment.

## Configure project

1. Clone the Econia repository and navigate to the `executor` module of the `dss-ci-cd` project directory:

   ```sh
   git clone https://github.com/econia-labs/econia.git
   cd econia/src/terraform/dss-ci-cd/modules/executor
   ```

1. [Configure a billable GCP project](gcp#configure-project):

   ```sh
   PROJECT_NAME=dss-ci-cd-demo
   PROJECT_ID=<YOUR_PROJECT_ID>
   ```

   ```sh
   echo $PROJECT_ID
   echo $PROJECT_NAME
   echo $ORGANIZATION_ID
   echo $BILLING_ACCOUNT_ID
   ```

   ```sh
   gcloud projects create $PROJECT_ID \
       --name $PROJECT_NAME \
       --organization $ORGANIZATION_ID
   gcloud alpha billing projects link $PROJECT_ID \
       --billing-account $BILLING_ACCOUNT_ID
   gcloud config set project $PROJECT_ID
   gcloud services enable compute.googleapis.com
   ```

1. Generate keys for a [service account](https://cloud.google.com/iam/docs/service-account-overview):

   ```sh
   KEY_FILE=gcp-key.json
   ```

   ```sh
   echo $KEY_FILE
   ```

   :::tip
   `.gitignore` ignores any files of pattern `*gcp-key*.json`.
   :::

   ```sh
   gcloud iam service-accounts create terraform
   SERVICE_ACCOUNT_NAME=terraform@$PROJECT_ID.iam.gserviceaccount.com
   gcloud iam service-accounts keys create $KEY_FILE \
       --iam-account $SERVICE_ACCOUNT_NAME
   gcloud projects add-iam-policy-binding $PROJECT_ID \
       --member serviceAccount:$SERVICE_ACCOUNT_NAME \
       --role roles/editor
   ```

1. Store variables in a [Terraform variable file](https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables), then format and initialize the directory:

   ```sh
   echo "project = \"$PROJECT_ID\"" > terraform.tfvars
   echo "credentials_file = \"$KEY_FILE\"" >> terraform.tfvars
   terraform fmt
   echo "\n\nContents of terraform.tfvars:\n\n"
   cat terraform.tfvars
   ```

   ```sh
   terraform init
   ```

1. Initialize the CI/CD executor:

   ```sh
   terraform apply
   ```
