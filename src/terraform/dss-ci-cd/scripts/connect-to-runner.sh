# Start interactive root login shell on runner, in DSS Terraform directory.
gcloud compute ssh runner \
    --command "cd /econia/src/terraform/dss-ci-cd/dss; sudo bash -l" \
    --ssh-flag="-t" \
    --tunnel-through-iap
