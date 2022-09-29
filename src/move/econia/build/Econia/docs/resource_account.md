
<a name="0xc0deb00c_resource_account"></a>

# Module `0xc0deb00c::resource_account`

Manages an Econia-owned resource account.


-  [Resource `SignerCapabilityStore`](#0xc0deb00c_resource_account_SignerCapabilityStore)
-  [Function `get_address`](#0xc0deb00c_resource_account_get_address)
-  [Function `get_signer`](#0xc0deb00c_resource_account_get_signer)
-  [Function `init_module`](#0xc0deb00c_resource_account_init_module)
    -  [Seed considerations](#@Seed_considerations_0)


<pre><code><b>use</b> <a href="">0x1::account</a>;
</code></pre>



<a name="0xc0deb00c_resource_account_SignerCapabilityStore"></a>

## Resource `SignerCapabilityStore`

Stores a signing capability for the Econia resource account.


<pre><code><b>struct</b> <a href="resource_account.md#0xc0deb00c_resource_account_SignerCapabilityStore">SignerCapabilityStore</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>signer_capability: <a href="_SignerCapability">account::SignerCapability</a></code>
</dt>
<dd>
 Signer capability for Econia resource account.
</dd>
</dl>


</details>

<a name="0xc0deb00c_resource_account_get_address"></a>

## Function `get_address`

Return resource account address.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="resource_account.md#0xc0deb00c_resource_account_get_address">get_address</a>(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="resource_account.md#0xc0deb00c_resource_account_get_address">get_address</a>():
<b>address</b>
<b>acquires</b> <a href="resource_account.md#0xc0deb00c_resource_account_SignerCapabilityStore">SignerCapabilityStore</a> {
    // Borrow immutable reference <b>to</b> <a href="">signer</a> capability.
    <b>let</b> signer_capability_ref = &<b>borrow_global</b>&lt;<a href="resource_account.md#0xc0deb00c_resource_account_SignerCapabilityStore">SignerCapabilityStore</a>&gt;(
        @econia).signer_capability;
    // Return its <b>address</b>.
    <a href="_get_signer_capability_address">account::get_signer_capability_address</a>(signer_capability_ref)
}
</code></pre>



</details>

<a name="0xc0deb00c_resource_account_get_signer"></a>

## Function `get_signer`

Return resource account signer.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="resource_account.md#0xc0deb00c_resource_account_get_signer">get_signer</a>(): <a href="">signer</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="resource_account.md#0xc0deb00c_resource_account_get_signer">get_signer</a>():
<a href="">signer</a>
<b>acquires</b> <a href="resource_account.md#0xc0deb00c_resource_account_SignerCapabilityStore">SignerCapabilityStore</a> {
    // Borrow immutable reference <b>to</b> <a href="">signer</a> capability.
    <b>let</b> signer_capability_ref = &<b>borrow_global</b>&lt;<a href="resource_account.md#0xc0deb00c_resource_account_SignerCapabilityStore">SignerCapabilityStore</a>&gt;(
        @econia).signer_capability;
    // Return associated <a href="">signer</a>.
    <a href="_create_signer_with_capability">account::create_signer_with_capability</a>(signer_capability_ref)
}
</code></pre>



</details>

<a name="0xc0deb00c_resource_account_init_module"></a>

## Function `init_module`

Initialize the Econia resource account upon module publication.


<a name="@Seed_considerations_0"></a>

### Seed considerations


* Resource account creation seed supplied as an empty vector,
pending the acceptance of <code>aptos-core</code> PR #4173. If PR is not
accepted by version release, will be updated with similar
functionality.


<pre><code><b>fun</b> <a href="resource_account.md#0xc0deb00c_resource_account_init_module">init_module</a>(econia: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="resource_account.md#0xc0deb00c_resource_account_init_module">init_module</a>(
    econia: &<a href="">signer</a>
) {
    // Create resource <a href="">account</a>, storing <a href="">signer</a> capability.
    <b>let</b> (_, signer_capability) =
        <a href="_create_resource_account">account::create_resource_account</a>(econia, b"");
    // Store signing capability under Econia <a href="">account</a>.
    <b>move_to</b>(econia, <a href="resource_account.md#0xc0deb00c_resource_account_SignerCapabilityStore">SignerCapabilityStore</a>{signer_capability});
}
</code></pre>



</details>
