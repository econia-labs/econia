TFSTATE=$(base64 -i dss/terraform.tfstate)
TARGET_PATH=/econia/src/terraform/dss-ci-cd/dss/terraform.tfstate
gcloud compute ssh runner --tunnel-through-iap --command \
    "echo $TFSTATE | base64 --decode | sudo tee $TARGET_PATH > /dev/null"
