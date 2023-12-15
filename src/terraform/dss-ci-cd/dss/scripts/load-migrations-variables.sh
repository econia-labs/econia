# Database must already have been created.
REG_EXPR='s/credentials_file.+= "(.+)"/\1/p'
CREDENTIALS_FILE=$(sed -nr $REG_EXPR terraform.tfvars)
REG_EXPR='s/db_conn_str_auth_proxy = "(.+)"/\1/p'
DB_CONN_STR_AUTH_PROXY=$(terraform output | sed -nr $REG_EXPR)
REG_EXPR='s/db_connection_name = "(.+)"/\1/p'
DB_CONNECTION_NAME=$(terraform output | sed -nr $REG_EXPR)
echo $CREDENTIALS_FILE
echo $DB_CONN_STR_AUTH_PROXY
echo $DB_CONNECTION_NAME
