# Startup script for runner VM.
# https://developer.hashicorp.com/terraform/install
# https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli
# https://cloud.google.com/sdk/docs/install#deb
sudo apt-get update
sudo apt-get install -y \
    git \
    gnupg \
    software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg |
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
cd /
git clone https://github.com/econia-labs/econia.git --recurse-submodules
