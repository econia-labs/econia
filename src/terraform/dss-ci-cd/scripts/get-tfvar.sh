# Extract a Terraform variable from source text in `.tfvars` format.
function get_tfvar {
    local VARIABLE_NAME=$1
    local SOURCE_TEXT=$2
    local REGULAR_EXPRESSION='s/'"$VARIABLE_NAME"'.+= "(.+)"/\1/p'
    echo $SOURCE_TEXT | sed -nr $REGULAR_EXPRESSION
}
