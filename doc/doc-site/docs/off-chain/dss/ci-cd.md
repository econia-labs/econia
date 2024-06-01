---
title: CI/CD
---

# Continuous integration and deployment

This guide will help you set up continuous integration/continuous deployment (CI/CD) workflows for a DSS deployment on Google Cloud Platform (GCP).

## Dependencies

1. [Create a GCP organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization), [try GCP for free](https://cloud.google.com/free), or otherwise get access to GCP.

1. [Install the Google Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk).

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli).

1. Add the [Cloud SQL Auth Proxy client](https://cloud.google.com/sql/docs/postgres/connect-instance-auth-proxy#install-proxy) to your `PATH`.

   :::tip
   Try `brew install cloud-sql-proxy`
   :::

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
   [You can get a gRPC auth token from Aptos Labs](https://developers.aptoslabs.com/)
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

1. Archive Terraform state for the runner on the runner itself, now that it has been bootstrapped:

   ```sh
   source scripts/archive-runner-tfstate.sh
   ```

   :::tip
   This will upload `runner/terraform.tfstate` to `/econia/src/terraform/dss-ci-cd/runner` on the runner.
   Other relevant data is stored on the runner under `/econia/src/terraform/dss-ci-cd/dss`, including:

   1. Terraform state for the DSS (generated upon deployment, the next step)
   1. GCP service account credentials.
   1. `terraform.tfvars`, used by both the DSS and runner Terraform projects.

1. Now you can remotely execute commands on the runner.
   For example, to deploy the DSS:

   ```sh
   source scripts/run.sh "terraform -chdir=dss apply -parallelism 50"
   ```

1. And, if you'd like to connect to the runner for an interactive session as root user:

   ```sh
   source scripts/connect-to-runner.sh
   ```

## Starting a new project

If you'd like to start a new project, make sure you've archived the runner state as described above.
Then, before running the init-project script again, clear local project state:

```sh
source scripts/clear-local-project-state.sh
```

This will leave behind `runner/terraform.tfvars` so you can manually edit it, then initialize a new project.

## Continued operations

After the DSS has been deployed and the runner state has been archived, you can change your `gcloud` CLI config options to work on other GCP projects.

If you'd like to resume operations, or if someone else would like to get involved (and they have permissions for the relevant GCP project), then all that is required is the GCP project ID:

```sh
source scripts/engage-dss-project GCP_PROJECT_ID
```

This command will simply update the local `gcloud` CLI config to the same project, region, and zone as the runner.
Updating the config enables local development, for example, like downloading Terraform state files to simulate a runner on the local machine in order to test out modifications to Terraform configuration files.

If you'd like to engage in this or other complex development operations, see the scripts directory.

## Hot upgrade

If you'd like to redeploy your DSS after a release without having to sync data from chain tip, you can perform a "hot upgrade", which involves:

1. Shutting off the aggregator and processor.
1. Running the latest migrations.
1. Redeploying the aggregator and processor.

To perform a hot upgrade, you'll need to pick two Git revisions (e.g. a tag like `dss-v1.5.0`):

1. A revision for the DSS source code (including migrations and Docker image source).
1. A revision for the Terraform project.

```sh
DSS_SOURCE_REV=dss-v1.5.0
TERRAFORM_PROJECT_REV=dss-v1.5.0
source scripts/hot-upgrade.sh $DSS_SOURCE_REV $TERRAFORM_PROJECT_REV
```

## Suspend/resume runner

In order to avoid getting charged for a mostly unused service, you can suspend the runner when you're not using it, and resume it before hot upgrading for example.

To do so, you can use `scripts/suspend-runner.sh` like so:

```bash
source scripts/suspend-runner.sh GCP_PROJECT_ID
```

and `scripts/resume-runner.sh` like so:

```bash
source scripts/resume-runner.sh GCP_PROJECT_ID
```

Note that when resuming, you should wait for the runner to be running before using it.
You can check its status by running:

```bash
gcloud compute instances list --filter name=runner
```
