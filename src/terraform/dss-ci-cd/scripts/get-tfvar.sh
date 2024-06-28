# Get the value of a variable in `.tfvars`-formatted source text.
(
    local source_text=$1
    local variable=$2
    local regular_expression='s/'"$variable"'.+= "(.+)"/\1/p'
    echo $source_text | sed -nr $regular_expression
)
