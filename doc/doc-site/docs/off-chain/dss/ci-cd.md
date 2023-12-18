---
title: CI/CD
---

# Continuous integration and deployment

This guide will help you set up continuous integration/continuous deployment (CI/CD) workflows for a DSS deployment on Google Cloud Platform (GCP).

## Dependencies

1. [Create a GCP organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization), [try GCP for free](https://cloud.google.com/free), or otherwise get access to GCP.

1. [Install the Google Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk).

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli).

## Initialize runner

1. Check your GCP metadata:

   ```sh
   gcloud organizations list
   ```

   ```sh
   gcloud alpha billing accounts list
   ```

1. Clone the Econia repository and configure project variables using the values from above:

   ```sh
   git clone https://github.com/econia-labs/econia.git
   cd econia/src/terraform/dss-ci-cd
   cp runner/template.tfvars runner/terraform.tfvars
   ```

   ```sh
   vim runner/terraform.tfvars
   ```

   :::tip
   [You can get a gRPC auth token from Aptos Labs](https://aptos-api-gateway-prod.firebaseapp.com/)
   :::

1. Initialize the CI/CD project runner, which on startup will run a script that installs dependencies:

   ```sh
   source scripts/init-project.sh
   ```

1. After the runner has been created, you can pull the startup script logs via:

   ```sh
   source scripts/get-runner-startup-logs.sh
   ```

1. After 5–10 minutes, the startup script logs should show something like:

   ```sh
   ...
   ... google_metadata_script_runner[754]: startup-script exit status 0
   ... google_metadata_script_runner[754]: Finished running startup scripts.
   ... systemd[1]: google-startup-scripts.service: Deactivated successfully.
   ... systemd[1]: Finished google-startup-scripts.service - Google Compute Engine Startup Scripts.
   ... systemd[1]: google-startup-scripts.service: Consumed 7min 17.688s CPU time.
   ```
