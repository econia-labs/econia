# Update gcloud CLI config to match runner for a given project ID.
(
    local project_id=$1
    gcloud config set project $project_id
    local zone=$(
        gcloud compute instances list \
            --filter name=runner \
            --format "value(zone)"
    )
    gcloud config set compute/zone $zone
    local tfvars=$(source scripts/run.sh "cat dss/terraform.tfvars")
    local get_tfvar="scripts/get-tfvar.sh"
    local project_name=$(source $get_tfvar $tfvars project_name)
    local region=$(source $get_tfvar $tfvars region)
    gcloud config set run/region $region
    gcloud config set artifacts/location $region
    gcloud config set artifacts/repository images
    echo "\ngcloud CLI config for $project_name:\n"
    gcloud config list
)
