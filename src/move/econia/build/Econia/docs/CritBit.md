
<a name="0x1234_CritBit"></a>

# Module `0x1234::CritBit`

A crit-bit tree is a compact binary prefix tree, similar to a binary
search tree, that stores a prefix-free set of bitstrings, like
n-bit integers or variable-length 0-terminated byte strings. For a
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

The present implementation involves a tree with two types of nodes,
inner and outer. Inner nodes have two children each, while outer
nodes have no children. There are no nodes that have exactly one
child. Outer nodes store a key-value pair with a 128-bit integer as
a key, and an arbitrary value of generic type. Inner nodes do not
store a key, but rather, a bitmask indicating the critical bit
(crit-bit) of divergence between keys located within the node's two
subtrees: keys in the node's left subtree have a 0 at the critical
bit, while keys in the node's right subtree have a 1 at the critical
bit. Bit numbers are 0-indexed starting at the least-significant bit
(LSB), such that a critical bit of 3, for instance, corresponds to
the bitmask <code>00....001000</code>. Inner nodes are arranged hierarchically,
with the most sigificant critical bits at the top of the tree. For
instance, the keys <code>001</code>, <code>101</code>, <code>110</code>, and <code>111</code> would be stored in
a crit-bit tree as follows (vertical bars included at left of
illustration per issue with documentation build engine, namely, the
automatic stripping of leading whitespace in fenced code blocks):
```
|       2nd
|      /   \
|    001   1st
|         /   \
|       101   0th
|            /   \
|          110   111
```
Here, the inner node marked <code>2nd</code> stores the bitmask <code>00...00100</code>,
the inner node marked <code>1st</code> stores the bitmask <code>00...00010</code>, and the
inner node marked <code>0th</code> stores the bitmask <code>00...00001</code>. Hence, the
sole key in the left subtree of the inner node marked <code>2nd</code> has 0 at
bit 2, while all the keys in the node's right subtree have 1 at bit
2. And similarly for the inner node marked <code>0th</code>, its left child
node does not have bit 0 set, while its right child does have bit 0
set.

---


-  [Struct `N`](#0x1234_CritBit_N)
-  [Struct `CB`](#0x1234_CritBit_CB)
-  [Constants](#@Constants_0)
-  [Function `crit_bit`](#0x1234_CritBit_crit_bit)
-  [Function `b_lo`](#0x1234_CritBit_b_lo)
-  [Function `empty`](#0x1234_CritBit_empty)
-  [Function `insert_empty`](#0x1234_CritBit_insert_empty)
-  [Function `singleton`](#0x1234_CritBit_singleton)
-  [Function `destroy_empty`](#0x1234_CritBit_destroy_empty)
-  [Function `is_empty`](#0x1234_CritBit_is_empty)
-  [Function `b_c`](#0x1234_CritBit_b_c)
-  [Function `borrow_closest_outer`](#0x1234_CritBit_borrow_closest_outer)
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
 Left child node index, marked <code><a href="CritBit.md#0x1234_CritBit_NIL">NIL</a></code> when outer node
</dd>
<dt>
<code>r: u64</code>
</dt>
<dd>
 Right child node index, marked <code><a href="CritBit.md#0x1234_CritBit_NIL">NIL</a></code> when outer node
</dd>
<dt>
<code>v: V</code>
</dt>
<dd>
 Value from node's key-value pair
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

u128 bitmask with all bits set


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_ALL_HI">ALL_HI</a>: u128 = 340282366920938463463374607431768211455;
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



<a name="0x1234_CritBit_OUT"></a>

Flag to indicate outer node


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_OUT">OUT</a>: u8 = 255;
</code></pre>



<a name="0x1234_CritBit_R"></a>

Right direction


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_R">R</a>: bool = <b>false</b>;
</code></pre>



<a name="0x1234_CritBit_crit_bit"></a>

## Function `crit_bit`

Return the number of the most significant bit (0-indexed from
LSB) at which two non-identical bitstrings, <code>s1</code> and <code>s2</code>, vary.
To begin with, a bitwise XOR is used to flag all differing bits:
```
s1: 101110001
s2: 101011100
s1 ^ s2: 000101101
|- critical bit = 5
```
Next
```
r: 000101101
r - 1: 000101100
r & (r - 1): 000101100
r = r >> 1: 000010110
```
The critical bit is then the number of the left-most 1 in the
XOR result <code>r</code>. From here, so long as <code>r</code> is greater than 1,
then <code>r</code> AND (<code>r</code> - 1)
then <code>r</code> if the LSB of <code>r</code> is 1, then so will
the LSB of the <code>r</code> & (<code>r</code> - 1) if the LSB
of <code>r</code> is 1, which means that so long as <code>r</code> AND (<code>r</code> - 1) is
not equal to


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_crit_bit">crit_bit</a>(s1: u128, s2: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_crit_bit">crit_bit</a>(
    s1: u128,
    s2: u128,
) {
    <b>let</b> r = s1 ^ s2; // Marked 1 at bits that differ
    r;
}
</code></pre>



</details>

<a name="0x1234_CritBit_b_lo"></a>

## Function `b_lo`

Return a bitmask with all bits high except for bit <code>b</code>,
0-indexed starting at LSB: bitshift 1 by <code>b</code>, XOR with <code><a href="CritBit.md#0x1234_CritBit_ALL_HI">ALL_HI</a></code>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_b_lo">b_lo</a>(b: u8): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_b_lo">b_lo</a>(b: u8): u128 {1 &lt;&lt; b ^ <a href="CritBit.md#0x1234_CritBit_ALL_HI">ALL_HI</a>}
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
    v_pu_b&lt;<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;&gt;(&<b>mut</b> cb.t, <a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;{s: k, c: <a href="CritBit.md#0x1234_CritBit_OUT">OUT</a>, l: <a href="CritBit.md#0x1234_CritBit_NIL">NIL</a>, r: <a href="CritBit.md#0x1234_CritBit_NIL">NIL</a>, v});
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

<a name="0x1234_CritBit_borrow_closest_outer"></a>

## Function `borrow_closest_outer`

Walk a non-empty tree until arriving at the outer node sharing
the largest common prefix with <code>k</code>, then return a reference to
the node. Inner nodes store a bitmask where all bits except the
critical bit are not set, so if bitwise AND between <code>k</code> and an
inner node's bitmask is 0, then <code>k</code> has 0 at the critical bit:
```
Insertion key, bit 5 = 0:  ...1011000101
Inner node bitmask, c = 5: ...0000100000
Result of bitwise AND:     ...0000000000
```
Hence, since the directional constants <code><a href="CritBit.md#0x1234_CritBit_L">L</a></code> and <code><a href="CritBit.md#0x1234_CritBit_R">R</a></code> are set to
<code><b>true</b></code> and <code><b>false</b></code> respectively, a conditional check on equality
between the 0 and the bitwise AND result evaluates to <code><a href="CritBit.md#0x1234_CritBit_L">L</a></code> when
<code>k</code> does not have the critical bit set, and <code><a href="CritBit.md#0x1234_CritBit_R">R</a></code> when <code>k</code> does
have the critical bit set.


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_borrow_closest_outer">borrow_closest_outer</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): &<a href="CritBit.md#0x1234_CritBit_N">CritBit::N</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_borrow_closest_outer">borrow_closest_outer</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): &<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt; {
    <b>let</b> n = v_b&lt;<a href="CritBit.md#0x1234_CritBit_N">N</a>&lt;V&gt;&gt;(&cb.t, cb.r); // Borrow root node reference
    <b>while</b> (n.c != <a href="CritBit.md#0x1234_CritBit_OUT">OUT</a>) { // While node under review is inner node
        // Borrow either <a href="CritBit.md#0x1234_CritBit_L">L</a> or <a href="CritBit.md#0x1234_CritBit_R">R</a> child node depending on AND result
        n = <a href="CritBit.md#0x1234_CritBit_b_c">b_c</a>&lt;V&gt;(cb, n, n.s & k == 0);
    }; // Node reference now corresponds <b>to</b> closest outer node
    n // Return closest outer node reference
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
    // Return <b>true</b> <b>if</b> closest outer node match bitstring is `k`
    <b>return</b> <a href="CritBit.md#0x1234_CritBit_borrow_closest_outer">borrow_closest_outer</a>&lt;V&gt;(cb, k).s == k
}
</code></pre>



</details>
