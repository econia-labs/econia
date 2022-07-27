
<a name="0xc0deb00c_util"></a>

# Module `0xc0deb00c::util`

Low-level utility functions


-  [Function `are_same_type_info`](#0xc0deb00c_util_are_same_type_info)


<pre><code><b>use</b> <a href="">0x1::type_info</a>;
</code></pre>



<a name="0xc0deb00c_util_are_same_type_info"></a>

## Function `are_same_type_info`

Return <code><b>true</b></code> if <code>type_info_1</code> and <code>type_info_2</code> are the same


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0xc0deb00c_util_are_same_type_info">are_same_type_info</a>(type_info_1: &<a href="_TypeInfo">type_info::TypeInfo</a>, type_info_2: &<a href="_TypeInfo">type_info::TypeInfo</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0xc0deb00c_util_are_same_type_info">are_same_type_info</a>(
    type_info_1: &TypeInfo,
    type_info_2: &TypeInfo
): bool {
    (account_address(type_info_1) == account_address(type_info_2)) &&
    (module_name(type_info_1) == module_name(type_info_2)) &&
    (struct_name(type_info_1) == struct_name(type_info_2))
}
</code></pre>



</details>
