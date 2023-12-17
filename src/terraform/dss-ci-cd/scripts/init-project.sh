echo && echo "Loading project variables:"
source scripts/get-tfvar.sh
TFVARS=$(cat runner/terraform.tfvars)
ORGANIZATION_ID=$(get_tfvar organization_id $TFVARS)
BILLING_ACCOUNT_ID=$(get_tfvar billing_account_id $TFVARS)
PROJECT_ID=$(get_tfvar project_id $TFVARS)
PROJECT_NAME=$(get_tfvar project_name $TFVARS)
echo "Organization ID:" $ORGANIZATION_ID
echo "Billing account ID:" $BILLING_ACCOUNT_ID
echo "Project ID:" $PROJECT_ID
echo "Project name:" $PROJECT_NAME
echo "Credentials file:" $CREDENTIALS_FILE

echo && echo "Creating project:"
gcloud projects create $PROJECT_ID \
    --name $PROJECT_NAME \
    --organization $ORGANIZATION_ID
gcloud alpha billing projects link $PROJECT_ID \
    --billing-account $BILLING_ACCOUNT_ID
gcloud config set project $PROJECT_ID

echo && echo "Enabling GCP APIs (be patient):"
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable sqladmin.googleapis.com

echo && echo "Creating service account:"
gcloud iam service-accounts create terraform
SERVICE_ACCOUNT_NAME=terraform@$PROJECT_ID.iam.gserviceaccount.com
gcloud iam service-accounts keys create \
    runner/service-account-key.json \
    --iam-account $SERVICE_ACCOUNT_NAME
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME \
    --role roles/editor
# https://serverfault.com/questions/942115
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME \
    --role roles/compute.networkAdmin

echo && echo "Initializing runner:"
terraform fmt -recursive
terraform -chdir=runner init
terraform -chdir=runner apply -auto-approve
