
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

---


-  [Struct `N`](#0x1234_CritBit_N)
-  [Struct `CB`](#0x1234_CritBit_CB)
-  [Constants](#@Constants_0)
-  [Function `bu8`](#0x1234_CritBit_bu8)
-  [Function `bit_lo`](#0x1234_CritBit_bit_lo)
-  [Function `empty`](#0x1234_CritBit_empty)
-  [Function `insert_empty`](#0x1234_CritBit_insert_empty)
-  [Function `singleton`](#0x1234_CritBit_singleton)
-  [Function `destroy_empty`](#0x1234_CritBit_destroy_empty)
-  [Function `is_empty`](#0x1234_CritBit_is_empty)
-  [Function `b_c`](#0x1234_CritBit_b_c)
-  [Function `borrow_closest_ext`](#0x1234_CritBit_borrow_closest_ext)
-  [Function `has_key`](#0x1234_CritBit_has_key)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1234_CritBit_N"></a>

## Struct `N`

A node in the crit-bit tree, representing a key-value pair with
value type <code>V</code>


<pre><code><b>struct</b> <a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>s: u128</code>
</dt>
<dd>
 Bitstring, which would preferably be a generic type
 representing the union of {u8, u64, u128}. However this kind
 of union typing is not supported by Move, so the most
 general (and memory intensive) u128 is instead specified
 strictly.
</dd>
<dt>
<code>c: u8</code>
</dt>
<dd>
 Critical bit position. Bit numbers 0-indexed from LSB:

 ```
 11101...1000100100
             |    |- bit 0 is 0
 bit 5 is 1 -|
 ```
</dd>
<dt>
<code>l: u64</code>
</dt>
<dd>
 Left child node index, marked <code><a href="CritBit.md#0x1234_CritBit_NIL">NIL</a></code> when external node
</dd>
<dt>
<code>r: u64</code>
</dt>
<dd>
 Right child node index, marked <code><a href="CritBit.md#0x1234_CritBit_NIL">NIL</a></code> when external node
</dd>
<dt>
<code>v: V</code>
</dt>
<dd>
 Value from the key-value pair
</dd>
</dl>


</details>

<a name="0x1234_CritBit_CB"></a>

## Struct `CB`

A crit-bit tree for key-value pairs with value type <code>V</code>


<pre><code><b>struct</b> <a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt; <b>has</b> store
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
<code>t: vector&lt;<a href="CritBit.md#0x1234_CritBit_N">CritBit::N</a>&lt;V&gt;&gt;</code>
</dt>
<dd>
 Vector of nodes in the tree
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1234_CritBit_ALL_HI"></a>

u128 bitmask with all bits high


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_ALL_HI">ALL_HI</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0x1234_CritBit_EXT"></a>

Flag to indicate external node


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_EXT">EXT</a>: u8 = 255;
</code></pre>



<a name="0x1234_CritBit_E_BIT_NOT_0_OR_1"></a>



<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_E_BIT_NOT_0_OR_1">E_BIT_NOT_0_OR_1</a>: u64 = 0;
</code></pre>



<a name="0x1234_CritBit_E_DESTROY_NOT_EMPTY"></a>



<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>: u64 = 1;
</code></pre>



<a name="0x1234_CritBit_L"></a>

Left direction


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_L">L</a>: bool = <b>true</b>;
</code></pre>



<a name="0x1234_CritBit_NIL"></a>

Flag to indicate that there is no connected node for the given
child relationship field, analagous to a <code>NULL</code> pointer


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_NIL">NIL</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0x1234_CritBit_R"></a>

Right direction


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_R">R</a>: bool = <b>false</b>;
</code></pre>



<a name="0x1234_CritBit_bu8"></a>

## Function `bu8`

Return a <code>u8</code> corresponding to the provided human-readable
string. The input string should contain only "0"s and "1"s, up
to 8 characters max (e.g. <code>b"10101010"</code>)


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
            // OR result <b>with</b> the correspondingly leftshifted bit
            r = r | 1 &lt;&lt; (i <b>as</b> u8);
        // Otherwise, <b>assert</b> bit is marked 0 (0x30 in ASCII)
        } <b>else</b> <b>assert</b>!(b == 0x30, <a href="CritBit.md#0x1234_CritBit_E_BIT_NOT_0_OR_1">E_BIT_NOT_0_OR_1</a>);
        i = i + 1; // Proceed <b>to</b> next-least-significant bit
    };
    r // Return result
}
</code></pre>



</details>

<a name="0x1234_CritBit_bit_lo"></a>

## Function `bit_lo`

Return a bitmask with all bits high except for bit <code>b</code>,
0-indexed starting at LSB: bitshift 1 by <code>b</code>, XOR with <code><a href="CritBit.md#0x1234_CritBit_ALL_HI">ALL_HI</a></code>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_bit_lo">bit_lo</a>(b: u8): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_bit_lo">bit_lo</a>(b: u8): u128 {1 &lt;&lt; b ^ <a href="CritBit.md#0x1234_CritBit_ALL_HI">ALL_HI</a>}
</code></pre>



</details>

<a name="0x1234_CritBit_empty"></a>

## Function `empty`

Return an empty tree


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_empty">empty</a>&lt;V&gt;(): <a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_empty">empty</a>&lt;V&gt;():
<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt; {
    <a href="CritBit.md#0x1234_CritBit_CB">CB</a>{r: <a href="CritBit.md#0x1234_CritBit_NIL">NIL</a>, t: v_e&lt;<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;&gt;()}
}
</code></pre>



</details>

<a name="0x1234_CritBit_insert_empty"></a>

## Function `insert_empty`

Insert key-value pair <code>k</code> and <code>v</code> into an empty <code>cb</code>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_insert_empty">insert_empty</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_insert_empty">insert_empty</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V
) {
    v_pu_b&lt;<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;&gt;(&<b>mut</b> cb.t, <a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;{s: k, c: <a href="CritBit.md#0x1234_CritBit_EXT">EXT</a>, l: <a href="CritBit.md#0x1234_CritBit_NIL">NIL</a>, r: <a href="CritBit.md#0x1234_CritBit_NIL">NIL</a>, v});
}
</code></pre>



</details>

<a name="0x1234_CritBit_singleton"></a>

## Function `singleton`

Return a tree with one node having key <code>k</code> and value <code>v</code>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_singleton">singleton</a>&lt;V&gt;(k: u128, v: V): <a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_singleton">singleton</a>&lt;V&gt;(
    k: u128,
    v: V
):
<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt; {
    <b>let</b> cb = <a href="CritBit.md#0x1234_CritBit_CB">CB</a>{r: 0, t: v_e&lt;<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;&gt;()};
    <a href="CritBit.md#0x1234_CritBit_insert_empty">insert_empty</a>&lt;V&gt;(&<b>mut</b> cb, k, v);
    cb
}
</code></pre>



</details>

<a name="0x1234_CritBit_destroy_empty"></a>

## Function `destroy_empty`

Destroy empty tree <code>cb</code>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_destroy_empty">destroy_empty</a>&lt;V&gt;(cb: <a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_destroy_empty">destroy_empty</a>&lt;V&gt;(
    cb: <a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;
) {
    <b>assert</b>!(<a href="CritBit.md#0x1234_CritBit_is_empty">is_empty</a>(&cb), <a href="CritBit.md#0x1234_CritBit_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>);
    <b>let</b> <a href="CritBit.md#0x1234_CritBit_CB">CB</a>{r: _, t} = cb; // Unpack root node index and node vector
    v_d_e(t); // Destroy empty node vector
}
</code></pre>



</details>

<a name="0x1234_CritBit_is_empty"></a>

## Function `is_empty`

Return <code><b>true</b></code> if the tree is empty (if root is <code><a href="CritBit.md#0x1234_CritBit_NIL">NIL</a></code>)


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;): bool {cb.r == <a href="CritBit.md#0x1234_CritBit_NIL">NIL</a>}
</code></pre>



</details>

<a name="0x1234_CritBit_b_c"></a>

## Function `b_c`

Return immutable reference to either left or right child of node
<code>n</code> in <code>cb</code> (left when <code>d</code> is <code><a href="CritBit.md#0x1234_CritBit_L">L</a></code>, right when <code>d</code> is <code><a href="CritBit.md#0x1234_CritBit_R">R</a></code>)


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_b_c">b_c</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, n: &<a href="CritBit.md#0x1234_CritBit_N">CritBit::N</a>&lt;V&gt;, d: bool): &<a href="CritBit.md#0x1234_CritBit_N">CritBit::N</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_b_c">b_c</a>&lt;V&gt;(
    cb: & <a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    n: & <a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;,
    d: bool
): &<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt; {
    <b>if</b> (d == <a href="CritBit.md#0x1234_CritBit_L">L</a>) v_b&lt;<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;&gt;(&cb.t, n.l) <b>else</b> v_b&lt;<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;&gt;(&cb.t, n.r)
}
</code></pre>



</details>

<a name="0x1234_CritBit_borrow_closest_ext"></a>

## Function `borrow_closest_ext`

Walk a non-empty tree until arriving at the external node
sharing the largest common prefix with <code>k</code>, then return a
reference to the node. Internal nodes store a bitstring where
all bits except the critical bit are 1, so if bitwise OR between
this bitstring and <code>k</code> is identical to the bitstring, then <code>k</code>
has 0 at the critical bit:
```
Internal node bitstring, c = 5: ....1111011111
Insertion key, bit 5 = 0:       ....1011000101
Result of bitwise OR:           ....1111011111
```
Hence, since the directional constants <code><a href="CritBit.md#0x1234_CritBit_L">L</a></code> and <code><a href="CritBit.md#0x1234_CritBit_R">R</a></code> are set to
<code><b>true</b></code> and <code><b>false</b></code> respectively, a conditional check on equality
between the bitwise OR result and the original empty node
bitstring evaluates to <code><a href="CritBit.md#0x1234_CritBit_L">L</a></code> when <code>k</code> has the critical bit at 0
and <code><a href="CritBit.md#0x1234_CritBit_R">R</a></code> when <code>k</code> has the critical bit at 1.


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_borrow_closest_ext">borrow_closest_ext</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): &<a href="CritBit.md#0x1234_CritBit_N">CritBit::N</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_borrow_closest_ext">borrow_closest_ext</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): &<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt; {
    <b>let</b> n = v_b&lt;<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;&gt;(&cb.t, cb.r); // Borrow root node reference
    <b>while</b> (n.c != <a href="CritBit.md#0x1234_CritBit_EXT">EXT</a>) { // While node under review is <b>internal</b> node
        // Borrow either <a href="CritBit.md#0x1234_CritBit_L">L</a> or <a href="CritBit.md#0x1234_CritBit_R">R</a> child node depending on OR result
        n = <a href="CritBit.md#0x1234_CritBit_b_c">b_c</a>&lt;V&gt;(cb, n, n.s | k == n.s);
    }; // Node reference now corresponds <b>to</b> closest match
    n // Return node reference
}
</code></pre>



</details>

<a name="0x1234_CritBit_has_key"></a>

## Function `has_key`

Return true if <code>cb</code> has key <code>k</code>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_has_key">has_key</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_has_key">has_key</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): bool {
    <b>if</b> (<a href="CritBit.md#0x1234_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb)) <b>return</b> <b>false</b>; // Return <b>false</b> <b>if</b> empty
    // Return <b>true</b> <b>if</b> closest external node match bitstring is `k`
    <b>return</b> <a href="CritBit.md#0x1234_CritBit_borrow_closest_ext">borrow_closest_ext</a>&lt;V&gt;(cb, k).s == k
}
</code></pre>



</details>
