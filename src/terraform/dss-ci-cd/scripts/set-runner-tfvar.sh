# Set the value of a variable in `dss-ci-cd/dss/terraform.tfvars` on runner.
(
    local variable=$1
    local new_value=$2
    local source_text=$(source scripts/run.sh "cat dss/terraform.tfvars")
    local new_file_contents=$(
        source scripts/set-tfvar.sh $source_text $variable $new_value
    )
    local encoded=$(echo $new_file_contents | base64)
    source scripts/upload-base64-text-to-file.sh $encoded dss/terraform.tfvars
)
