---
title: CI/CD
---

# Continuous integration and deployment

If you have already finished the [Terraform tutorial](terraform.md) and would rather not rebuild the entire DSS every time a new upgrade comes out, this guide will help you set up continuous integration/continuous deployment (CI/CD) workflows for your DSS deployment.

## Initialize runner

1. Clone the Econia repository and configure project variables:

   ```sh
   git clone https://github.com/econia-labs/econia.git
   cd econia/src/terraform/dss-ci-cd
   cp runner/template.tfvars runner/terraform.tfvars
   vim runner/terraform.tfvars
   ```

1. Initialize the CI/CD project runner:

   ```sh
   source scripts/init-project.sh
   ```

   :::tip
   Once the runner has been created it may take up to 10 minutes to complete the startup script, since it has to compile binaries from source.
   :::

1. You can then connect to the runner via [GCP Identity-Aware Proxy](https://cloud.google.com/compute/docs/connect/ssh-using-iap):

   ```sh title="Get startup script logs"
   source scripts/get-runner-startup-logs.sh
   ```

   ```sh title="Starting interactive session"
   source scripts/connect-to-runner.sh
   ```

   ```sh title="Disconnect from interactive session"
   exit
   ```
