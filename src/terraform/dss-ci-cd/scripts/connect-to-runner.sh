# Start interactive root login shell on runner, in `dss-ci-cd` directory.
gcloud compute ssh runner \
    --command "cd /econia/src/terraform/dss-ci-cd; sudo bash -l" \
    --ssh-flag="-t" \
    --tunnel-through-iap
