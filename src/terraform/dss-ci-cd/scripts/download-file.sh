# Download file from runner.
# Relative to `dss-ci-cd` directory in both cases.
(
    local from=$1 # Relative path on runner.
    local to=$2   # Relative path on current machine.
    local abs_path=/econia/src/terraform/dss-ci-cd/$from
    local encoded=$(
        gcloud compute ssh runner \
            --command "base64 -i $abs_path" \
            --tunnel-through-iap
    )
    echo $encoded | base64 --decode >$to
)
