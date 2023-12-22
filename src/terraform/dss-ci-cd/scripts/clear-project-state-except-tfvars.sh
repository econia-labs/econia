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
