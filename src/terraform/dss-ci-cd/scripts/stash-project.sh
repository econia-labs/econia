source scripts/get-tfvar.sh
TFVARS=$(cat runner/terraform.tfvars)
PROJECT_ID=$(get_tfvar project_id $TFVARS)
STASH_DIR=stashed-projects/$PROJECT_ID
rm -rf $STASH_DIR
mkdir -p $STASH_DIR
mv "runner/terraform.tfstate" "$STASH_DIR/terraform.tfstate"
cp "runner/terraform.tfvars" "$STASH_DIR/terraform.tfvars"
mv "runner/service-account-key.json" "$STASH_DIR/service-account-key.json"
source scripts/clear-project-state-except-tfvars.sh
