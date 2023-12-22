# Run command(s) on the runner as superuser, from DSS Terraform directory.

COMMAND=$1 # For example "terraform apply" or "pwd; ls -al".

gcloud compute ssh runner \
    --command "cd /econia/src/terraform/dss-ci-cd/dss; sudo -s eval $COMMAND" \
    --tunnel-through-iap
