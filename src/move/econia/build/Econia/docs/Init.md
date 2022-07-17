
<a name="0xc0deb00c_Init"></a>

# Module `0xc0deb00c::Init`

Initialization functionality for Econia core account resources,
which must be invoked before trades can be placed.


-  [Constants](#@Constants_0)
-  [Function `init_econia`](#0xc0deb00c_Init_init_econia)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Caps.md#0xc0deb00c_Caps">0xc0deb00c::Caps</a>;
<b>use</b> <a href="Registry.md#0xc0deb00c_Registry">0xc0deb00c::Registry</a>;
<b>use</b> <a href="Version.md#0xc0deb00c_Version">0xc0deb00c::Version</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_Init_E_NOT_ECONIA"></a>

When account/address is not Econia


<pre><code><b>const</b> <a href="Init.md#0xc0deb00c_Init_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_Init_init_econia"></a>

## Function `init_econia`

Initialize Econia core account resources, aborting if called by
non-Econia account


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Init.md#0xc0deb00c_Init_init_econia">init_econia</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Init.md#0xc0deb00c_Init_init_econia">init_econia</a>(
    account: &signer
) {
    // Verify called by Econia account
    <b>assert</b>!(s_a_o(account) == @Econia, <a href="Init.md#0xc0deb00c_Init_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    init_caps(account); // <a href="Init.md#0xc0deb00c_Init">Init</a> <b>friend</b>-like capabilities
    init_registry(account); // <a href="Init.md#0xc0deb00c_Init">Init</a> market registry
    init_mock_version_number(account); // <a href="Init.md#0xc0deb00c_Init">Init</a> mock version number
}
</code></pre>



</details>
