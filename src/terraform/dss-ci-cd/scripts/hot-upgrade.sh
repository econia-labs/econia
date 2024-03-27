# Run a hot upgrade for specified DSS source and Terraform project revisions.
(
    dss_source_rev=$1
    terraform_project_rev=$2
    echo "Getting Terraform variables file..."
    local tfvars=$(source scripts/run.sh "cat dss/terraform.tfvars")
    local set_tfvar=scripts/set-tfvar.sh
    local tmp=$(
        source $set_tfvar $tfvars terraform_project_rev $terraform_project_rev
    )
    local new_tfvars=$(
        source $set_tfvar $tmp dss_source_rev $dss_source_rev
    )
    local new_tfvars_encoded=$(echo $new_tfvars | base64)
    echo "Uploading variables, checking out revisions, redeploying..."
    source scripts/run.sh " \
        echo \"$new_tfvars_encoded\" | base64 --decode | \
            sudo tee dss/terraform.tfvars >/dev/null; \
        git fetch;
        git checkout $terraform_project_rev; \
        git pull; \
        git submodule update --init --recursive; \
        cd dss/econia; \
        git fetch;
        git checkout $dss_source_rev; \
        git pull; \
        git submodule update --init --recursive; \
        cd ..; \
        terraform init; \
        terraform destroy -target module.db.terraform_data.re_run_migrations \
            -auto-approve; \
        terraform destroy -target module.aggregator -auto-approve; \
        terraform destroy -target module.processor -auto-approve; \
        terraform destroy -target module.mqtt -auto-approve; \
        terraform apply -parallelism 50 -auto-approve;"
)
