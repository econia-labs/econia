gcloud compute ssh runner --tunnel-through-iap -- \
    sudo journalctl --no-pager --unit google-startup-scripts.service
