# Startup script for runner VM.

# Install dependencies.
apt update && apt install -y \
    build-essential \
    git \
    gnupg \
    jq \
    libpq-dev \
    postgresql-client \
    software-properties-common
# https://developer.hashicorp.com/terraform/install
# https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli
wget -O- https://apt.releases.hashicorp.com/gpg |
    gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install -y terraform
# https://cloud.google.com/sql/docs/mysql/sql-proxy#linux-64-bit
curl -o cloud-sql-proxy $(
    printf '%s' \
        "https://storage.googleapis.com/cloud-sql-connectors/" \
        "cloud-sql-proxy/v2.8.1/cloud-sql-proxy.linux.amd64"
)
chmod +x cloud-sql-proxy
mv cloud-sql-proxy /usr/bin/cloud-sql-proxy
# https://www.rust-lang.org/tools/install
# https://github.com/rust-lang-deprecated/rustup.sh/issues/83
# https://stackoverflow.com/a/52445962
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -sSf | sh -s -- -y
export PATH="/root/.cargo/bin:$PATH"
# https://diesel.rs/guides/getting-started
cargo install diesel_cli --no-default-features --features postgres

# Initialize Terraform project.
function init_econia_repo_at_rev {
    local revision=$1
    git clone https://github.com/econia-labs/econia.git
    cd econia
    git checkout $revision
    git submodule update --init --recursive
    cd ..
}
init_econia_repo_at_rev $TERRAFORM_PROJECT_REV
cd /econia/src/terraform/dss-ci-cd/dss
init_econia_repo_at_rev $DSS_SOURCE_REV
echo $KEY_BASE_64 | base64 --decode >service-account-key.json
echo $VARS_BASE_64 | base64 --decode >terraform.tfvars
gcloud config set compute/zone $ZONE
gcloud config set run/region $REGION
terraform init
