
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
* [Langley 2008](
https://www.imperialviolet.org/2008/09/29/critbit-trees.html)
* [Langley 2012](https://github.com/agl/critbit)
* [Tcler's Wiki 2021](https://wiki.tcl-lang.org/page/critbit)

The present implementation involves a tree with two types of nodes,
inner and outer. Inner nodes have two children each, while outer
nodes have no children. There are no nodes that have exactly one
child. Outer nodes store a key-value pair with a 128-bit integer as
a key, and an arbitrary value of generic type. Inner nodes do not
store a key, but rather, an 8-bit integer indicating the most
significatn critical bit (crit-bit) of divergence between keys
located within the node's two subtrees: keys in the node's left
subtree have a 0 at the critical bit, while keys in the node's right
subtree have a 1 at the critical bit. Bit numbers are 0-indexed
starting at the least-significant bit (LSB), such that a critical
bit of 3, for instance, corresponds to a comparison between the
bitstrings <code>00...00000</code> and <code>00...01111</code>. Inner nodes are arranged
hierarchically, with the most sigificant critical bits at the top of
the tree. For instance, the keys <code>001</code>, <code>101</code>, <code>110</code>, and <code>111</code>
would be stored in a crit-bit tree as follows (right carets included
at left of illustration per issue with documentation build engine,
namely, the automatic stripping of leading whitespace in fenced code
blocks):
```
>       2nd
>      /   \
>    001   1st
>         /   \
>       101   0th
>            /   \
>          110   111
```
Here, the inner node marked <code>2nd</code> stores the integer 2, the inner
node marked <code>1st</code> stores the integer 1, and the inner node marked
<code>0th</code> stores the integer 0. Hence, the sole key in the left subtree
of the inner node marked <code>2nd</code> has 0 at bit 2, while all the keys in
the node's right subtree have 1 at bit 2. And similarly for the
inner node marked <code>0th</code>, its left child node does not have bit 0
set, while its right child does have bit 0 set.

---


-  [Struct `I`](#0x1234_CritBit_I)
-  [Struct `O`](#0x1234_CritBit_O)
-  [Struct `CB`](#0x1234_CritBit_CB)
-  [Constants](#@Constants_0)
-  [Function `crit_bit`](#0x1234_CritBit_crit_bit)
-  [Function `is_set`](#0x1234_CritBit_is_set)
-  [Function `is_out`](#0x1234_CritBit_is_out)
-  [Function `o_v`](#0x1234_CritBit_o_v)
-  [Function `o_c`](#0x1234_CritBit_o_c)
-  [Function `b_lo`](#0x1234_CritBit_b_lo)
-  [Function `empty`](#0x1234_CritBit_empty)
-  [Function `singleton`](#0x1234_CritBit_singleton)
-  [Function `destroy_empty`](#0x1234_CritBit_destroy_empty)
-  [Function `is_empty`](#0x1234_CritBit_is_empty)
-  [Function `length`](#0x1234_CritBit_length)
-  [Function `b_c_o`](#0x1234_CritBit_b_c_o)
-  [Function `borrow`](#0x1234_CritBit_borrow)
-  [Function `has_key`](#0x1234_CritBit_has_key)
-  [Function `insert_empty`](#0x1234_CritBit_insert_empty)
-  [Function `insert_singleton`](#0x1234_CritBit_insert_singleton)
-  [Function `insert_general`](#0x1234_CritBit_insert_general)
-  [Function `insert`](#0x1234_CritBit_insert)
-  [Function `check_len`](#0x1234_CritBit_check_len)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1234_CritBit_I"></a>

## Struct `I`

Inner node


<pre><code><b>struct</b> <a href="CritBit.md#0x1234_CritBit_I">I</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>c: u8</code>
</dt>
<dd>
 Critical bit position. Bit numbers 0-indexed from LSB:

 ```
 11101...1010010101
  bit 5 = 0 -|    |- bit 0 = 1
 ```
</dd>
<dt>
<code>l: u64</code>
</dt>
<dd>
 Left child node index. When bit 63 is set, left child is an
 outer node. Otherwise left child is an inner node.
</dd>
<dt>
<code>r: u64</code>
</dt>
<dd>
 Right child node index. When bit 63 is set, right child is
 an outer node. Otherwise right child is an inner node.
</dd>
</dl>


</details>

<a name="0x1234_CritBit_O"></a>

## Struct `O`

Outer node with key <code>k</code> and value <code>v</code>


<pre><code><b>struct</b> <a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>k: u128</code>
</dt>
<dd>
 Key, which would preferably be a generic type representing
 the union of {<code>u8</code>, <code>u64</code>, <code>u128</code>}. However this kind of
 union typing is not supported by Move, so the most general
 (and memory intensive) <code>u128</code> is instead specified strictly.
 Must be an integer for bitwise operations.
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
 Root node index. When bit 63 is set, root node is an outer
 node. Otherwise root is an inner node. Should be 0 if empty
</dd>
<dt>
<code>i: vector&lt;<a href="CritBit.md#0x1234_CritBit_I">CritBit::I</a>&gt;</code>
</dt>
<dd>
 Inner nodes
</dd>
<dt>
<code>o: vector&lt;<a href="CritBit.md#0x1234_CritBit_O">CritBit::O</a>&lt;V&gt;&gt;</code>
</dt>
<dd>
 Outer nodes
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1234_CritBit_E_BIT_NOT_0_OR_1"></a>

When a char in a bytestring is neither 0 nor 1


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_E_BIT_NOT_0_OR_1">E_BIT_NOT_0_OR_1</a>: u64 = 0;
</code></pre>



<a name="0x1234_CritBit_E_BORROW_EMPTY"></a>

When unable to borrow from empty tree


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_E_BORROW_EMPTY">E_BORROW_EMPTY</a>: u64 = 3;
</code></pre>



<a name="0x1234_CritBit_E_DESTROY_NOT_EMPTY"></a>

When attempting to destroy a non-empty crit-bit tree


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>: u64 = 1;
</code></pre>



<a name="0x1234_CritBit_E_HAS_K"></a>

When an insertion key is already present in a crit-bit tree


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_E_HAS_K">E_HAS_K</a>: u64 = 2;
</code></pre>



<a name="0x1234_CritBit_E_INSERT_LENGTH"></a>

When no more keys can be inserted


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_E_INSERT_LENGTH">E_INSERT_LENGTH</a>: u64 = 5;
</code></pre>



<a name="0x1234_CritBit_E_NOT_HAS_K"></a>

When no matching key in tree


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_E_NOT_HAS_K">E_NOT_HAS_K</a>: u64 = 4;
</code></pre>



<a name="0x1234_CritBit_HI_128"></a>

<code>u128</code> bitmask with all bits set


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_HI_128">HI_128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0x1234_CritBit_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0x1234_CritBit_IN"></a>

Node type bit flag indicating inner node


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_IN">IN</a>: u64 = 0;
</code></pre>



<a name="0x1234_CritBit_L"></a>

Left direction


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_L">L</a>: bool = <b>true</b>;
</code></pre>



<a name="0x1234_CritBit_MSB_u128"></a>

Most significant bit number for a <code>u128</code>


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_MSB_u128">MSB_u128</a>: u8 = 127;
</code></pre>



<a name="0x1234_CritBit_N_TYPE"></a>

Bit number of node type flag in a <code>u64</code> vector index


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_N_TYPE">N_TYPE</a>: u8 = 63;
</code></pre>



<a name="0x1234_CritBit_OUT"></a>

Node type bit flag indicating outer node


<pre><code><b>const</b> <a href="CritBit.md#0x1234_CritBit_OUT">OUT</a>: u64 = 1;
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
>           s1: 11110001
>           s2: 11011100
>  x = s1 ^ s2: 00101101
>                 |- critical bit = 5
```
Here, the critical bit is equivalent to the bit number of the
most significant set bit in XOR result <code>x = s1 ^ s2</code>. At this
point, [Langley 2012](https://github.com/agl/critbit) notes that
<code>x</code> bitwise AND <code>x - 1</code> will be nonzero so long as <code>x</code> contains
at least some bits set which are of lesser significance than the
critical bit:
```
>               x: 00101101
>           x - 1: 00101100
> x = x & (x - 1): 00101100
```
Thus he suggests repeating <code>x & (x - 1)</code> while the new result
<code>x = x & (x - 1)</code> is not equal to zero, because such a loop will
eventually reduce <code>x</code> to a power of two (excepting the trivial
case where <code>x</code> starts as all 0 except bit 0 set, for which the
loop never enters past the initial conditional check). Per this
method, using the new <code>x</code> value for the current example, the
second iteration proceeds as follows:
```
>               x: 00101100
>           x - 1: 00101011
> x = x & (x - 1): 00101000
```
The third iteration:
```
>               x: 00101000
>           x - 1: 00100111
> x = x & (x - 1): 00100000
```
Now, <code>x & x - 1</code> will equal zero and the loop will not begin a
fourth iteration:
```
>             x: 00100000
>         x - 1: 00011111
> x AND (x - 1): 00000000
```
Thus after three iterations a corresponding critical bit bitmask
has been determined. However, in the case where the two input
strings vary at all bits of lesser significance than that of the
critical bit, there may be required as many as <code>k - 1</code>
iterations, where <code>k</code> is the number of bits in each string under
comparison. For instance, consider the case of the two 8-bit
strings <code>s1</code> and <code>s2</code> as follows:
```
>              s1: 10101010
>              s2: 01010101
>     x = s1 ^ s2: 11111111
>                  |- critical bit = 7
> x = x & (x - 1): 11111110 [iteration 1]
> x = x & (x - 1): 11111100 [iteration 2]
> x = x & (x - 1): 11111000 [iteration 3]
> ...
```
Notably, this method is only suggested after already having
indentified the varying byte between the two strings, thus
limiting <code>x & (x - 1)</code> operations to at most 7 iterations. But
for the present implementation, strings are not partioned into
a multi-byte array, rather, they are stored as <code>u128</code> integers,
so a binary search is instead proposed. Here, the same
<code>x = s1 ^ s2</code> operation is first used to identify all differing
bits, before iterating on an upper and lower bound for the
critical bit number:
```
>          s1: 10101010
>          s2: 01010101
> x = s1 ^ s2: 11111111
>       u = 7 -|      |- l = 0
```
The upper bound <code>u</code> is initialized to the length of the string
(7 in this example, but 127 for a <code>u128</code>), and the lower bound
<code>l</code> is initialized to 0. Next the midpoint <code>m</code> is calculated as
the average of <code>u</code> and <code>l</code>, in this case <code>m = (7 + 0) / 2 = 3</code>,
per truncating integer division. Now, the shifted compare value
<code>s = r &gt;&gt; m</code> is calculated and updates are applied according to
three potential outcomes:

* <code>s == 1</code> means that the critical bit <code>c</code> is equal to <code>m</code>
* <code>s == 0</code> means that <code>c &lt; m</code>, so <code>u</code> is set to <code>m - 1</code>
* <code>s &gt; 1</code> means that <code>c &gt; m</code>, so <code>l</code> us set to <code>m + 1</code>

Hence, continuing the current example:
```
>          x: 11111111
> s = x >> m: 00011111
```
<code>s &gt; 1</code>, so <code>l = m + 1 = 4</code>, and the search window has shrunk:
```
> x = s1 ^ s2: 11111111
>       u = 7 -|  |- l = 4
```
Updating the midpoint yields <code>m = (7 + 4) / 2 = 5</code>:
```
>          x: 11111111
> s = x >> m: 00000111
```
Again <code>s &gt; 1</code>, so update <code>l = m + 1 = 6</code>, and the window
shrinks again:
```
> x = s1 ^ s2: 11111111
>       u = 7 -||- l = 6
> s = x >> m: 00000011
```
Again <code>s &gt; 1</code>, so update <code>l = m + 1 = 7</code>, the final iteration:
```
> x = s1 ^ s2: 11111111
>       u = 7 -|- l = 7
> s = x >> m: 00000001
```
Here, <code>s == 1</code>, which means that <code>c = m = 7</code>. Notably this
search has converged after only 3 iterations, as opposed to 7
for the linear search proposed above, and in general such a
search converges after log_2(<code>k</code>) iterations at most, where <code>k</code>
is the number of bits in each of the strings <code>s1</code> and <code>s2</code> under
comparison. Hence this search method improves the O(<code>k</code>) search
proposed by [Langley 2012](https://github.com/agl/critbit) to
O(log(<code>k</code>)), and moreover, determines the actual number of the
critical bit, rather than just a bitmask with bit <code>c</code> set, as he
proposes, which can also be easily generated via <code>1 &lt;&lt; c</code>.


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_crit_bit">crit_bit</a>(s1: u128, s2: u128): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_crit_bit">crit_bit</a>(
    s1: u128,
    s2: u128,
): u8 {
    <b>let</b> x = s1 ^ s2; // XOR result marked 1 at bits that differ
    <b>let</b> l = 0; // Lower bound on critical bit search
    <b>let</b> u = <a href="CritBit.md#0x1234_CritBit_MSB_u128">MSB_u128</a>; // Upper bound on critical bit search
    <b>loop</b> { // Begin binary search
        <b>let</b> m = (l + u) / 2; // Calculate midpoint of search window
        <b>let</b> s = x &gt;&gt; m; // Calculate midpoint shift of XOR result
        <b>if</b> (s == 1) <b>return</b> m; // If shift equals 1, c = m
        <b>if</b> (s &gt; 1) l = m + 1 <b>else</b> u = m - 1; // Update search bounds
    }
}
</code></pre>



</details>

<a name="0x1234_CritBit_is_set"></a>

## Function `is_set`

Return <code><b>true</b></code> if <code>k</code> is set at bit <code>b</code>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_is_set">is_set</a>(k: u128, b: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_is_set">is_set</a>(k: u128, b: u8): bool {k &gt;&gt; b & 1 == 1}
</code></pre>



</details>

<a name="0x1234_CritBit_is_out"></a>

## Function `is_out`

Return <code><b>true</b></code> if vector index <code>i</code> indicates an outer node


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_is_out">is_out</a>(i: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_is_out">is_out</a>(i: u64): bool {(i &gt;&gt; <a href="CritBit.md#0x1234_CritBit_N_TYPE">N_TYPE</a> & 1 == 1)}
</code></pre>



</details>

<a name="0x1234_CritBit_o_v"></a>

## Function `o_v`

Convert flagged child node index <code>c</code> to unflagged outer node
vector index, by AND with a bitmask that has only flag bit unset


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_o_v">o_v</a>(c: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_o_v">o_v</a>(c: u64): u64 {c & <a href="CritBit.md#0x1234_CritBit_HI_64">HI_64</a> ^ <a href="CritBit.md#0x1234_CritBit_OUT">OUT</a> &lt;&lt; <a href="CritBit.md#0x1234_CritBit_N_TYPE">N_TYPE</a>}
</code></pre>



</details>

<a name="0x1234_CritBit_o_c"></a>

## Function `o_c`

Convert unflagged outer node vector index <code>v</code> to flagged child
node index, by OR with a bitmask that has only flag bit set


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_o_c">o_c</a>(v: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_o_c">o_c</a>(v: u64): u64 {v | <a href="CritBit.md#0x1234_CritBit_OUT">OUT</a> &lt;&lt; <a href="CritBit.md#0x1234_CritBit_N_TYPE">N_TYPE</a>}
</code></pre>



</details>

<a name="0x1234_CritBit_b_lo"></a>

## Function `b_lo`

Return a bitmask with all bits high except for bit <code>b</code>,
0-indexed starting at LSB: bitshift 1 by <code>b</code>, XOR with <code><a href="CritBit.md#0x1234_CritBit_HI_128">HI_128</a></code>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_b_lo">b_lo</a>(b: u8): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_b_lo">b_lo</a>(b: u8): u128 {1 &lt;&lt; b ^ <a href="CritBit.md#0x1234_CritBit_HI_128">HI_128</a>}
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
    <a href="CritBit.md#0x1234_CritBit_CB">CB</a>{r: 0, i: v_e&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(), o: v_e&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;()}
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
    <b>let</b> cb = <a href="CritBit.md#0x1234_CritBit_CB">CB</a>{r: 0, i: v_e&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(), o: v_e&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;()};
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
    <b>let</b> <a href="CritBit.md#0x1234_CritBit_CB">CB</a>{r: _, i, o} = cb; // Unpack root index and node vectors
    v_d_e(i); // Destroy empty inner node vector
    v_d_e(o); // Destroy empty outer node vector
}
</code></pre>



</details>

<a name="0x1234_CritBit_is_empty"></a>

## Function `is_empty`

Return <code><b>true</b></code> if <code>cb</code> has no outer nodes


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;): bool {v_i_e&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o)}
</code></pre>



</details>

<a name="0x1234_CritBit_length"></a>

## Function `length`

Return number of keys in <code>cb</code> (number of outer nodes)


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_length">length</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_length">length</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;): u64 {v_l&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o)}
</code></pre>



</details>

<a name="0x1234_CritBit_b_c_o"></a>

## Function `b_c_o`

Walk a non-empty tree until arriving at the outer node sharing
the largest common prefix with <code>k</code>, then return a reference to
it. <code>b_c_o</code> indicates "borrow closest outer"


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_b_c_o">b_c_o</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): &<a href="CritBit.md#0x1234_CritBit_O">CritBit::O</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_b_c_o">b_c_o</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): &<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt; {
    // If root is an outer node, <b>return</b> reference <b>to</b> it
    <b>if</b> (<a href="CritBit.md#0x1234_CritBit_is_out">is_out</a>(cb.r)) <b>return</b> (v_b&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, <a href="CritBit.md#0x1234_CritBit_o_v">o_v</a>(cb.r)));
    // Otherwise borrow inner node at root
    <b>let</b> n = v_b&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(&cb.i, cb.r);
    <b>loop</b> { // Loop over inner nodes
        // If key is set at critical bit, get index of child on <a href="CritBit.md#0x1234_CritBit_R">R</a>
        <b>let</b> i_c = <b>if</b> (<a href="CritBit.md#0x1234_CritBit_is_set">is_set</a>(k, n.c)) n.r <b>else</b> n.l; // Otherwise <a href="CritBit.md#0x1234_CritBit_L">L</a>
        // If child is outer node, borrow and <b>return</b> it
        <b>if</b> (<a href="CritBit.md#0x1234_CritBit_is_out">is_out</a>(i_c)) <b>return</b> v_b&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, <a href="CritBit.md#0x1234_CritBit_o_v">o_v</a>(i_c));
        n = v_b&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(&cb.i, i_c); // Borrow next inner node <b>to</b> review
    }
}
</code></pre>



</details>

<a name="0x1234_CritBit_borrow"></a>

## Function `borrow`

Borrow value corresponding to key <code>k</code> in <code>cb</code>, aborting if empty
tree or no match


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_borrow">borrow</a>&lt;V&gt;(cb: &<a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): &V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_borrow">borrow</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): &V {
    <b>assert</b>!(!<a href="CritBit.md#0x1234_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb), <a href="CritBit.md#0x1234_CritBit_E_BORROW_EMPTY">E_BORROW_EMPTY</a>); // Abort <b>if</b> empty
    <b>let</b> c_o = <a href="CritBit.md#0x1234_CritBit_b_c_o">b_c_o</a>&lt;V&gt;(cb, k); // Borrow closest outer node
    <b>assert</b>!(c_o.k == k, <a href="CritBit.md#0x1234_CritBit_E_NOT_HAS_K">E_NOT_HAS_K</a>); // Abort <b>if</b> key not in tree
    &c_o.v // Return immutable reference <b>to</b> corresponding value
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
    // Return <b>true</b> <b>if</b> closest outer node <b>has</b> same key
    <b>return</b> <a href="CritBit.md#0x1234_CritBit_b_c_o">b_c_o</a>&lt;V&gt;(cb, k).k == k
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
    // Push back outer node onto tree's vector of outer nodes
    v_pu_b&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;{k, v});
    // Set root index field <b>to</b> indicate 0th outer node
    cb.r = <a href="CritBit.md#0x1234_CritBit_OUT">OUT</a> &lt;&lt; <a href="CritBit.md#0x1234_CritBit_N_TYPE">N_TYPE</a>;
}
</code></pre>



</details>

<a name="0x1234_CritBit_insert_singleton"></a>

## Function `insert_singleton`

Insert key <code>k</code> and value <code>v</code> into singleton tree <code>cb</code>, a special
case that that requires updating the root field of the tree,
aborting if <code>k</code> already in <code>cb</code>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_insert_singleton">insert_singleton</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_insert_singleton">insert_singleton</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V
) {
    <b>let</b> n = v_b&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, 0); // Borrow existing outer node
    <b>assert</b>!(k != n.k, <a href="CritBit.md#0x1234_CritBit_E_HAS_K">E_HAS_K</a>); // Assert insertion key not in tree
    <b>let</b> c = <a href="CritBit.md#0x1234_CritBit_crit_bit">crit_bit</a>(n.k, k); // Get critical bit between two keys
    // If insertion key greater than existing key, new inner node at
    // root should have existing key <b>as</b> left child and insertion key
    // <b>as</b> right child, otherwise the opposite
    <b>let</b> (l, r) = <b>if</b> (k &gt; n.k) (<a href="CritBit.md#0x1234_CritBit_o_c">o_c</a>(0), <a href="CritBit.md#0x1234_CritBit_o_c">o_c</a>(1)) <b>else</b> (<a href="CritBit.md#0x1234_CritBit_o_c">o_c</a>(1), <a href="CritBit.md#0x1234_CritBit_o_c">o_c</a>(0));
    // Push back new outer node onto outer node vector
    v_pu_b&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;{k, v});
    // Push back new inner node <b>with</b> corresponding children
    v_pu_b&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, <a href="CritBit.md#0x1234_CritBit_I">I</a>{c, l, r});
    // Update tree root field for newly-created inner node
    cb.r = 0;
}
</code></pre>



</details>

<a name="0x1234_CritBit_insert_general"></a>

## Function `insert_general`

Insert key <code>k</code> and value <code>v</code> into tree <code>cb</code> already having <code>n</code>
keys for general case where root is an inner node, aborting if
<code>k</code> is already present


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_insert_general">insert_general</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V, n: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_insert_general">insert_general</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V,
    n: u64
) {
    <b>let</b> i_p = cb.r; // Initialize parent index <b>to</b> that of root node
    <b>let</b> i_c: u64; // Initialize tracker for child node index
    <b>let</b> c_s: bool; // Initialize tracker for child side
    <b>loop</b> { // Loop over inner nodes
        <b>let</b> p = v_b&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(&cb.i, i_p); // Borrow parent inner node
        // If key is set at critical bit, track the <a href="CritBit.md#0x1234_CritBit_R">R</a> child, <b>else</b> <a href="CritBit.md#0x1234_CritBit_L">L</a>
        (i_c, c_s) = <b>if</b> (<a href="CritBit.md#0x1234_CritBit_is_set">is_set</a>(k, p.c)) (p.r, <a href="CritBit.md#0x1234_CritBit_R">R</a>) <b>else</b> (p.l, <a href="CritBit.md#0x1234_CritBit_L">L</a>);
        <b>if</b> (<a href="CritBit.md#0x1234_CritBit_is_out">is_out</a>(i_c)) <b>break</b>; // Stop <b>loop</b> <b>if</b> child is outer node
        i_p = i_c; // Otherwise borrow next inner node <b>to</b> review
    }; // Now child node index corresponds <b>to</b> closest outer node
    // Get key of closest outer node, the child from the <b>loop</b>
    <b>let</b> c_o_k = v_b&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, <a href="CritBit.md#0x1234_CritBit_o_v">o_v</a>(i_c)).k;
    <b>assert</b>!(c_o_k != k, <a href="CritBit.md#0x1234_CritBit_E_HAS_K">E_HAS_K</a>); // Assert key not already in tree
    // Push back outer node <b>with</b> new key-value pair
    v_pu_b&lt;<a href="CritBit.md#0x1234_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0x1234_CritBit_O">O</a>{k, v});
    <b>let</b> n_i_i = v_l&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(&cb.i); // Get index of new inner node <b>to</b> add
    <b>let</b> c = <a href="CritBit.md#0x1234_CritBit_crit_bit">crit_bit</a>(c_o_k, k); // Get critical bit of divergence
    <b>if</b> (k &lt; c_o_k) { // If insertion key less than closest outer key
        // Push back new inner node <b>with</b> insertion key at left child
        // and closest outer key at right child
        v_pu_b&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, <a href="CritBit.md#0x1234_CritBit_I">I</a>{c, l: <a href="CritBit.md#0x1234_CritBit_o_c">o_c</a>(n), r:    i_c});
    } <b>else</b> { // Otherwise the opposite
        v_pu_b&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, <a href="CritBit.md#0x1234_CritBit_I">I</a>{c, l:    i_c, r: <a href="CritBit.md#0x1234_CritBit_o_c">o_c</a>(n)});
    };
    <b>if</b> (c_s == <a href="CritBit.md#0x1234_CritBit_L">L</a>) { // If side of child from <b>loop</b> parent node is <a href="CritBit.md#0x1234_CritBit_L">L</a>
        // Update its left child <b>to</b> the new inner node
        v_b_m&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_p).l = n_i_i;
    } <b>else</b> { // Otherwise <b>update</b> right child <b>to</b> the new inner node
        v_b_m&lt;<a href="CritBit.md#0x1234_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_p).r = n_i_i;
    }
}
</code></pre>



</details>

<a name="0x1234_CritBit_insert"></a>

## Function `insert`

Insert key <code>k</code> and value <code>v</code> into <code>cb</code>, aborting if <code>k</code> already
in <code>cb</code>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_insert">insert</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0x1234_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0x1234_CritBit_insert">insert</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0x1234_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V
) {
    <b>let</b> l = <a href="CritBit.md#0x1234_CritBit_length">length</a>(cb); // Get length of tree
    <a href="CritBit.md#0x1234_CritBit_check_len">check_len</a>(l); // Verify insertion can take place
    // Insert via one of three cases, depending on the length
    <b>if</b> (l == 0) <a href="CritBit.md#0x1234_CritBit_insert_empty">insert_empty</a>(cb, k , v) <b>else</b>
    <b>if</b> (l == 1) <a href="CritBit.md#0x1234_CritBit_insert_singleton">insert_singleton</a>(cb, k, v) <b>else</b>
    <a href="CritBit.md#0x1234_CritBit_insert_general">insert_general</a>(cb, k , v, l);
}
</code></pre>



</details>

<a name="0x1234_CritBit_check_len"></a>

## Function `check_len`

Assert that <code>l</code> is less than the value indicated by a bitmask
where only the 63rd bit is not set (the maximum number of keys
that can be stored in a tree, since the 63rd bit is reserved for
the node type bit flag)


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_check_len">check_len</a>(l: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0x1234_CritBit_check_len">check_len</a>(l: u64) {<b>assert</b>!(l &lt; <a href="CritBit.md#0x1234_CritBit_HI_64">HI_64</a> ^ 1 &lt;&lt; <a href="CritBit.md#0x1234_CritBit_N_TYPE">N_TYPE</a>, <a href="CritBit.md#0x1234_CritBit_E_INSERT_LENGTH">E_INSERT_LENGTH</a>);}
</code></pre>



</details>
