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
