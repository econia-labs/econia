# Run command(s) on the runner as superuser, from `dss-ci-cd` directory.
# Format command(s) in a string, for example:
#     source scripts/run.sh "terraform -chdir=dss apply"
#     source scripts/run.sh "pwd; ls -al; echo 'foo'\" bar\""
gcloud compute ssh runner \
    --command "cd /econia/src/terraform/dss-ci-cd; sudo bash -cl '$1'" \
    --tunnel-through-iap
