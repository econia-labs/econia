# Upload file from current machine to runner.
# Relative to `dss-ci-cd` directory in both cases.
(
    local from=$1 # Relative path on current machine.
    local to=$2   # Relative path on runner.
    local encoded=$(base64 -i $from)
    source scripts/upload-base64-text-to-file.sh $encoded $to
)
