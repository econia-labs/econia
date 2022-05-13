
<a name="0x1234_CritBit"></a>

# Module `0x1234::CritBit`

A crit-bit tree is a compact binary prefix tree, similar to a binary
search tree, that stores a prefix-free set of bitstrings, like
64-bit integers or variable-length 0-terminated byte strings. For a
given set of keys there exists a unique crit-bit tree representing
the set, hence crit-bit trees do not requre complex rebalancing
algorithms like those of AVL or red-black binary search trees.
Crit-bit trees support the following operations, quickly:
* Membership testing
* Insertion
* Deletion
* Predecessor
* Successor
* Iteration

References:
* [Bernstein 2006](https://cr.yp.to/critbit.html)
* [Langley 2012](https://github.com/agl/critbit)
* [Tcler's Wiki 2021](https://wiki.tcl-lang.org/page/critbit)


- [Module `0x1234::CritBit`](#module-0x1234critbit)
  - [Struct `N`](#struct-n)
  - [Struct `CBT`](#struct-cbt)
  - [Constants](#constants)
  - [Function `bu8`](#function-bu8)
  - [Function `empty`](#function-empty)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1234_CritBit_N"></a>

## Struct `N`

A node in the crit-bit tree, representing a key-value pair of
key type <code>K</code> and value type <code>V</code>


<pre><code><b>struct</b> <a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;K, V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>p: K</code>
</dt>
<dd>
 Bitstring prefix from key
</dd>
<dt>
<code>c: u8</code>
</dt>
<dd>
 Critical bit position
</dd>
<dt>
<code>l: u64</code>
</dt>
<dd>
 Left child node index
</dd>
<dt>
<code>r: u64</code>
</dt>
<dd>
 Right child node index
</dd>
<dt>
<code>v: V</code>
</dt>
<dd>
 Value from the key-value pair
</dd>
</dl>


</details>

<a name="0x1234_CritBit_CBT"></a>

## Struct `CBT`

A crit-bit tree (CBT) for key-value pairs with key type <code>K</code> and
value type <code>V</code>


<pre><code><b>struct</b> <a href="CritBit.md#0x1234_CritBit_CBT">CBT</a>&lt;K, V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>r: u64</code>
</dt>
<dd>
 Root node index
</dd>
<dt>
<code>t: vector&lt;<a href="CritBit.md#0x1234_CritBit_N">CritBit::N</a>&lt;K, V&gt;&gt;</code>
</dt>
<dd>
 Vector of nodes in the tree
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1234_CritBit_E_BIT_NOT_0_OR_1"></a>



<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_E_BIT_NOT_0_OR_1">E_BIT_NOT_0_OR_1</a>: u64 = 0;
</code></pre>



<a name="0x1234_CritBit_NIL"></a>

Flag to indicate that there is no connected node for the given
child relationship field, analagous to a <code>NULL</code> pointer


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_NIL">NIL</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0x1234_CritBit_bu8"></a>

## Function `bu8`

Return a <code>u8</code> corresponding to the provided human-readable
string. The input string should contain only "0"s and "1"s, up
to 8 characters max, (e.g. <code>b"10101010"</code>)


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_bu8">bu8</a>(s: vector&lt;u8&gt;): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_bu8">bu8</a>(
    // Human-readable string, of form `b"10101010"`
    s: vector&lt;u8&gt;
): u8 {
    <b>let</b> n = v_l&lt;u8&gt;(&s); // Get number of bits in the string
    <b>let</b> r = 0; // Initialize result <b>to</b> 0
    <b>let</b> i = 0; // Start <b>loop</b> at least significant bit
    <b>while</b> (i &lt; n) { // While there are bits left <b>to</b> review
        <b>let</b> b = *v_b&lt;u8&gt;(&s, n - 1 - i); // Get bit under review
        <b>if</b> (b == 0x31) { // If the bit is 1 (0x31 in ASCII)
            // Or result <b>with</b> the correspondingly leftshifted bit
            r = r | 1 &lt;&lt; (i <b>as</b> u8);
        // Otherwise, <b>assert</b> bit is marked 0 (0x30 in ASCII)
        } <b>else</b> <b>assert</b>!(b == 0x30, <a href="CritBit.md#0x1234_CritBit_E_BIT_NOT_0_OR_1">E_BIT_NOT_0_OR_1</a>);
        i = i + 1; // Proceed <b>to</b> next-least-significant bit
    };
    r // Return result
}
</code></pre>



</details>

<a name="0x1234_CritBit_empty"></a>

## Function `empty`

Return an empty CBT


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_empty">empty</a>&lt;K, V&gt;(): <a href="CritBit.md#0x1234_CritBit_CBT">CritBit::CBT</a>&lt;K, V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_empty">empty</a>&lt;K, V&gt;():
<a href="CritBit.md#0x1234_CritBit_CBT">CBT</a>&lt;K, V&gt; {
    <a href="CritBit.md#0x1234_CritBit_CBT">CBT</a>{r: <a href="CritBit.md#0x1234_CritBit_NIL">NIL</a>, t: v_e&lt;<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;K, V&gt;&gt;()}
}
</code></pre>



</details>
