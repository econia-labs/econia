(
    echo && echo "Loading project variables:"
    local tfvars=$(cat runner/terraform.tfvars)
    local get_tfvar="scripts/get-tfvar.sh"
    local organization_id=$(source $get_tfvar $tfvars organization_id)
    local billing_account_id=$(source $get_tfvar $tfvars billing_account_id)
    local project_id=$(source $get_tfvar $tfvars project_id)
    local project_name=$(source $get_tfvar $tfvars project_name)
    local region=$(source $get_tfvar $tfvars region)
    local zone=$(source $get_tfvar $tfvars zone)
    echo "Organization ID:" $organization_id
    echo "Billing account ID:" $billing_account_id
    echo "Project ID:" $project_id
    echo "Project name:" $project_name
    echo "Region:" $region
    echo "Zone:" $region

    echo && echo "Creating project:"
    gcloud projects create $project_id \
        --name $project_name \
        --organization $organization_id
    gcloud alpha billing projects link $project_id \
        --billing-account $billing_account_id
    gcloud config set project $project_id

    echo && echo "Enabling GCP APIs (be patient):"
    gcloud services enable \
        artifactregistry.googleapis.com \
        cloudbuild.googleapis.com \
        cloudresourcemanager.googleapis.com \
        compute.googleapis.com \
        iam.googleapis.com \
        run.googleapis.com \
        servicenetworking.googleapis.com \
        sqladmin.googleapis.com \
        vpcaccess.googleapis.com
    gcloud config set compute/zone $zone
    gcloud config set run/region $region
    gcloud config set artifacts/location $region
    gcloud config set artifacts/repository images

    echo && echo "Creating service account:"
    gcloud iam service-accounts create terraform
    local service_account_name=terraform@$project_id.iam.gserviceaccount.com
    gcloud iam service-accounts keys create \
        runner/service-account-key.json \
        --iam-account $service_account_name
    gcloud projects add-iam-policy-binding $project_id \
        --member serviceAccount:$service_account_name \
        --role roles/editor
    # https://stackoverflow.com/a/61250654
    gcloud projects add-iam-policy-binding $project_id \
        --member serviceAccount:$service_account_name \
        --role roles/run.admin
    # https://serverfault.com/questions/942115
    gcloud projects add-iam-policy-binding $project_id \
        --member serviceAccount:$service_account_name \
        --role roles/compute.networkAdmin
    # https://stackoverflow.com/a/54351644
    gcloud projects add-iam-policy-binding $project_id \
        --member serviceAccount:$service_account_name \
        --role roles/servicenetworking.serviceAgent

    echo && echo "Initializing runner:"
    terraform fmt -recursive
    terraform -chdir=runner init
    terraform -chdir=runner apply -auto-approve
)
