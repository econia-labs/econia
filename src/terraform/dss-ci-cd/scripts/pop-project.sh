PROJECT_ID=$1
STASH_DIR="stashed-projects/$PROJECT_ID"
source scripts/clear-project-state-except-tfvars.sh
mv "$STASH_DIR/terraform.tfstate" "runner/terraform.tfstate"
mv "$STASH_DIR/terraform.tfvars" "runner/terraform.tfvars"
mv "$STASH_DIR/service-account-key.json" "runner/service-account-key.json"
terraform -chdir=runner init
rm -rf $STASH_DIR
source scripts/get-tfvar.sh
TFVARS=$(cat runner/terraform.tfvars)
REGION=$(get_tfvar region $TFVARS)
ZONE=$(get_tfvar zone $TFVARS)
gcloud config set project $PROJECT_ID
gcloud config set compute/zone $ZONE
gcloud config set run/region $REGION
