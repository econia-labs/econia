
<a name="0xc0deb00c_capability"></a>

# Module `0xc0deb00c::capability`

Defines and administers the <code><a href="capability.md#0xc0deb00c_capability_EconiaCapability">EconiaCapability</a></code>, which is required
for assorted cross-module function calls internal to Econia.


-  [Struct `EconiaCapability`](#0xc0deb00c_capability_EconiaCapability)
-  [Constants](#@Constants_0)
-  [Function `get_econia_capability`](#0xc0deb00c_capability_get_econia_capability)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
</code></pre>



<a name="0xc0deb00c_capability_EconiaCapability"></a>

## Struct `EconiaCapability`

Internal capability for cross-module Econia function calls


<pre><code><b>struct</b> <a href="capability.md#0xc0deb00c_capability_EconiaCapability">EconiaCapability</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_capability_E_NOT_ECONIA"></a>

When not called by Econia account


<pre><code><b>const</b> <a href="capability.md#0xc0deb00c_capability_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_capability_get_econia_capability"></a>

## Function `get_econia_capability`

Return an <code><a href="capability.md#0xc0deb00c_capability_EconiaCapability">EconiaCapability</a></code> when called by Econia account


<pre><code><b>public</b> <b>fun</b> <a href="capability.md#0xc0deb00c_capability_get_econia_capability">get_econia_capability</a>(<a href="">account</a>: &<a href="">signer</a>): <a href="capability.md#0xc0deb00c_capability_EconiaCapability">capability::EconiaCapability</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="capability.md#0xc0deb00c_capability_get_econia_capability">get_econia_capability</a>(
    <a href="">account</a>: &<a href="">signer</a>
): <a href="capability.md#0xc0deb00c_capability_EconiaCapability">EconiaCapability</a> {
    // Assert called by Econia <a href="">account</a>
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="capability.md#0xc0deb00c_capability_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Return an Econia <a href="capability.md#0xc0deb00c_capability">capability</a>
    <a href="capability.md#0xc0deb00c_capability_EconiaCapability">EconiaCapability</a>{}
}
</code></pre>



</details>
