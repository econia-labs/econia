
<a name="0xc0deb00c_Version"></a>

# Module `0xc0deb00c::Version`

Mock version number functionality for simulating Aptos database
version number. Calls to <code><a href="Version.md#0xc0deb00c_Version_get_v_n">get_v_n</a>()</code> can be easily replaced with a
Move native function for getting the true database version number
(once it is implemented).


-  [Resource `MC`](#0xc0deb00c_Version_MC)
-  [Constants](#@Constants_0)
-  [Function `get_v_n`](#0xc0deb00c_Version_get_v_n)
-  [Function `init_mock_version_number`](#0xc0deb00c_Version_init_mock_version_number)
-  [Function `get_updated_mock_version_number`](#0xc0deb00c_Version_get_updated_mock_version_number)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
</code></pre>



<a name="0xc0deb00c_Version_MC"></a>

## Resource `MC`

Mock version number counter


<pre><code><b>struct</b> <a href="Version.md#0xc0deb00c_Version_MC">MC</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>i: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_Version_E_NOT_ECONIA"></a>

When account/address is not Econia


<pre><code><b>const</b> <a href="Version.md#0xc0deb00c_Version_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Version_E_MC_EXISTS"></a>

When mock version number counter already exists


<pre><code><b>const</b> <a href="Version.md#0xc0deb00c_Version_E_MC_EXISTS">E_MC_EXISTS</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_Version_get_v_n"></a>

## Function `get_v_n`

Wrapped get-update function for mock version number counter,
calls to which can be easily replaced once a true version number
getter is implemented as a Move native function


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Version.md#0xc0deb00c_Version_get_v_n">get_v_n</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Version.md#0xc0deb00c_Version_get_v_n">get_v_n</a>():
u64
<b>acquires</b> <a href="Version.md#0xc0deb00c_Version_MC">MC</a> {
    <a href="Version.md#0xc0deb00c_Version_get_updated_mock_version_number">get_updated_mock_version_number</a>()
}
</code></pre>



</details>

<a name="0xc0deb00c_Version_init_mock_version_number"></a>

## Function `init_mock_version_number`

Initialize mock version number counter under Econia account,
aborting if called by another signer or if counter exists


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Version.md#0xc0deb00c_Version_init_mock_version_number">init_mock_version_number</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Version.md#0xc0deb00c_Version_init_mock_version_number">init_mock_version_number</a>(
    <a href="">account</a>: &<a href="">signer</a>
) {
    <b>let</b> addr = s_a_o(<a href="">account</a>); // Get <a href="">account</a> <b>address</b>
    <b>assert</b>!(addr == @Econia, <a href="Version.md#0xc0deb00c_Version_E_NOT_ECONIA">E_NOT_ECONIA</a>); // Assert Econia called
    // Assert mock <a href="">version</a> number counter doesn't exist already
    <b>assert</b>!(!<b>exists</b>&lt;<a href="Version.md#0xc0deb00c_Version_MC">MC</a>&gt;(addr), <a href="Version.md#0xc0deb00c_Version_E_MC_EXISTS">E_MC_EXISTS</a>);
    <b>move_to</b>&lt;<a href="Version.md#0xc0deb00c_Version_MC">MC</a>&gt;(<a href="">account</a>, <a href="Version.md#0xc0deb00c_Version_MC">MC</a>{i: 0}); // Move mock counter <b>to</b> Econia
}
</code></pre>



</details>

<a name="0xc0deb00c_Version_get_updated_mock_version_number"></a>

## Function `get_updated_mock_version_number`

Increment mock version number counter by one and return result.
To reduce overhead, assume <code><a href="Version.md#0xc0deb00c_Version_MC">MC</a></code> has already been initialized


<pre><code><b>fun</b> <a href="Version.md#0xc0deb00c_Version_get_updated_mock_version_number">get_updated_mock_version_number</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Version.md#0xc0deb00c_Version_get_updated_mock_version_number">get_updated_mock_version_number</a>():
u64
<b>acquires</b> <a href="Version.md#0xc0deb00c_Version_MC">MC</a> {
    // Borrow mutable reference <b>to</b> mock <a href="">version</a> number counter value
    <b>let</b> v_n = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Version.md#0xc0deb00c_Version_MC">MC</a>&gt;(@Econia).i;
    *v_n = *v_n + 1; // Increment by 1
    *v_n // Return new value
}
</code></pre>



</details>
