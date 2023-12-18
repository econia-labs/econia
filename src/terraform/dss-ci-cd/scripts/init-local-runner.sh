cp runner/service-account-key.json dss/service-account-key.json
cp runner/terraform.tfvars dss/terraform.tfvars
cp -R ../../rust/dbv2/migrations/ dss/migrations
git clone \
    https://github.com/econia-labs/econia.git \
    --branch ECO-1018 \
    --recurse-submodules
mv econia dss/econia
terraform -chdir=dss init
