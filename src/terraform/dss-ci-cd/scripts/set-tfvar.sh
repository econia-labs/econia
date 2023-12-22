# Set the value of a variable in `.tfvars`-formatted source text.
(
    local source_text=$1
    local variable=$2
    local new_value=$3
    local regular_expression='s/('"$variable"'.+= )"(.+)"/\1"'"$new_value"'"/g'
    echo $source_text | sed -E $regular_expression
)
