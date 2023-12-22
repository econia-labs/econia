# Run command(s) on the runner as superuser, from `dss-ci-cd` directory.
# Pass command in form "terraform -chdir=dss apply" or "pwd; ls -al".
gcloud compute ssh runner \
    --command "cd /econia/src/terraform/dss-ci-cd; sudo -s eval $1" \
    --tunnel-through-iap
