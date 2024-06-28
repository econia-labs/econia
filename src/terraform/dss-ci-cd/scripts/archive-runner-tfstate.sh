# Archive runner Terraform state from local machine on runner itself.
(
    source scripts/upload-file.sh \
        runner/terraform.tfstate \
        runner/terraform.tfstate
)
