TFSTATE_BASE_64=$(
    gcloud compute ssh runner --tunnel-through-iap -- \
        base64 -i /econia/src/terraform/dss-ci-cd/dss/terraform.tfstate
)
echo $TFSTATE_BASE_64 | base64 --decode >dss/terraform.tfstate
