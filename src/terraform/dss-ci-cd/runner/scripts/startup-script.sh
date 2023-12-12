# Startup script for runner VM.

# Create working directory.
mkdir /app
cd /app

# Install dependencies.
# https://developer.hashicorp.com/terraform/install
# https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli
apt update && apt install -y \
    git \
    gnupg \
    software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg |
    gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install -y terraform

# Get service account key.
SERVICE_ACCOUNT_NAME=terraform@$PROJECT_ID.iam.gserviceaccount.com
gcloud iam service-accounts keys create $CREDENTIALS_FILE \
    --iam-account $SERVICE_ACCOUNT_NAME

# Initialize Terraform project.
git clone \
    https://github.com/econia-labs/econia.git \
    --branch ECO-1018 \
    --recurse-submodules
cp -R econia/src/terraform/dss-ci-cd/dss/* .
echo "\
credentials_file = \"$CREDENTIALS_FILE\"
project = \"$PROJECT_ID\"
aptos_network = \"$APTOS_NETWORK\"
econia_address = \"$ECONIA_ADDRESS\"
starting_version = \"$STARTING_VERSION\"
grpc_data_service_address = \"$GRPC_DATA_SERVICE_ADDRESS\"
grpc_auth_token = \"$GRPC_AUTH_TOKEN\"" >terraform.tfvars
terraform fmt
terraform init
