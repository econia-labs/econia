rm -rf dss/.terraform
rm -rf dss/econia
rm -rf dss/migrations
rm -rf runner/.terraform
find . \
    -name '*.terraform*' \
    -o -name '*terraform.tfstate*' \
    -o -name '*service-account-key.json' |
    xargs rm
