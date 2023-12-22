# Upload file to runner.

FROM=$1 # Relative path on current machine.
TO=$2   # Absolute path on runner.

ENCODED=$(base64 -i $FROM)
gcloud compute ssh runner \
    --command "echo $ENCODED | base64 --decode | sudo tee $TO > /dev/null" \
    --tunnel-through-iap
