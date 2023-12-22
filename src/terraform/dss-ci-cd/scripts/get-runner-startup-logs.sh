# Print all startup logs from runner.
source scripts/run.sh \
    "journalctl --no-pager --unit google-startup-scripts.service"
