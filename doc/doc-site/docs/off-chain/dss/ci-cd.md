---
title: CI/CD
---

# Continuous integration and deployment

If you have already finished the [Terraform tutorial](terraform.md) and would rather not rebuild the entire DSS every time a new upgrade comes out, this guide will help you set up continuous integration/continuous deployment (CI/CD) workflows for your DSS deployment.

## Initialize runner

1. Clone the Econia repository and configure project variables for the `dss-ci-cd/runner` project:

   ```sh
   git clone https://github.com/econia-labs/econia.git
   cd econia/src/terraform/dss-ci-cd/runner
   cp project-vars.template.sh project-vars.sh
   vim project-vars.sh
   ```

   :::tip
   `.gitignore` ignores any files of pattern `*gcp-key*.json`.
   :::

1. Initialize the CI/CD runner:

   ```sh
   source init-runner.sh
   ```

   :::tip
   Once the runner has been created, it may take a minute or two before it completes the startup script and you can connect to it.
   :::

1. You can then connect to the runner via [Identity-Aware Proxy from GCP](https://cloud.google.com/compute/docs/connect/ssh-using-iap):

   ```sh title="Checking startup script logs"
   gcloud compute ssh runner --tunnel-through-iap -- \
   sudo journalctl --no-pager --unit google-startup-scripts.service
   ```

   ```sh title="Starting interactive session"
   gcloud compute ssh runner --tunnel-through-iap
   ```

   ```sh title="Disconnecting from interactive session"
   exit
   ```
