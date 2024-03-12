# Upload base64-encoded text to a file on runner, decoding on disk at runner.
# Destination file path relative to `dss-ci-cd` directory.
(
    local encoded_text=$1
    local destination_path=$2
    source scripts/run.sh "echo \"$encoded\" | \
        base64 --decode | \
        sudo tee $destination_path >/dev/null"
)
