# Startup script for runner VM.

# Create working directory.
mkdir /app
cd /app

# Store DSS variables.
echo "\
APTOS_NETWORK=\"$APTOS_NETWORK\"
ECONIA_ADDRESS=\"$ECONIA_ADDRESS\"
STARTING_VERSION=\"$STARTING_VERSION\"
GRPC_DATA_SERVICE_ADDRESS=\"$GRPC_DATA_SERVICE_ADDRESS\"
GRPC_AUTH_TOKEN=\"$GRPC_AUTH_TOKEN\"" >dss-vars.sh

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
git clone https://github.com/econia-labs/econia.git --recurse-submodules
