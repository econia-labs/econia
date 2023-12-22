# Clear local project state except for runner/terraform.tfvars.
rm -rf \
    dss/.terraform \
    dss/econia \
    runner/.terraform
rm -f dss/terraform.tfvars
find dss/ runner/ \
    -name '*.terraform*' \
    -o -name '*terraform.tfstate*' \
    -o -name '*service-account-key.json' |
    xargs rm