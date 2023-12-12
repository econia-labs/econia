echo && echo "Loading project variables:"
source project-vars.sh
ORGANIZATION_ID=$(gcloud organizations list --format "value(name)")
BILLING_ACCOUNT_ID=$(gcloud alpha billing accounts list --format "value(name)")
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
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable sqladmin.googleapis.com

echo && echo "Creating IAM account:"
gcloud iam service-accounts create terraform
SERVICE_ACCOUNT_NAME=terraform@$PROJECT_ID.iam.gserviceaccount.com
gcloud iam service-accounts keys create $CREDENTIALS_FILE \
    --iam-account $SERVICE_ACCOUNT_NAME
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_NAME \
    --role roles/editor

echo && echo "Initializing runner:"
echo "\
credentials_file = \"$CREDENTIALS_FILE\"
project = \"$PROJECT_ID\"" >terraform.tfvars
terraform fmt
terraform init
terraform apply -auto-approve
