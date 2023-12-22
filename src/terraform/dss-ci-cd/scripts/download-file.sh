# Download file from runner.

FROM=$1 # Absolute path on runner.
TO=$2   # Relative path on current machine.

ENCODED=$(
    gcloud compute ssh runner \
        --tunnel-through-iap \
        --command "base64 -i $FROM"
)
echo $ENCODED | base64 --decode >$TO
