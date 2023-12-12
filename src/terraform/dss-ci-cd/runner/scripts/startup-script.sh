# Startup script for runner VM.

# Create working directory.
mkdir /app
cd /app

# Get service account key.
SERVICE_ACCOUNT_NAME=terraform@$PROJECT_ID.iam.gserviceaccount.com
gcloud iam service-accounts keys create $CREDENTIALS_FILE \
    --iam-account $SERVICE_ACCOUNT_NAME

# Store DSS variables.
echo "\
credentials_file = \"$CREDENTIALS_FILE\"
project_id = \"$PROJECT_ID\"
aptos_network = \"$APTOS_NETWORK\"
econia_address = \"$ECONIA_ADDRESS\"
starting_version = \"$STARTING_VERSION\"
grpc_data_service_address = \"$GRPC_DATA_SERVICE_ADDRESS\"
grpc_auth_token = \"$GRPC_AUTH_TOKEN\"" >terraform.tfvars

# Install Git and Terraform.
# https://developer.hashicorp.com/terraform/install
# https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli
sudo apt-get update && apt-get install -y \
    git \
    gnupg \
    software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg |
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Get Econia.
git clone https://github.com/econia-labs/econia.git --recurse-submodules
