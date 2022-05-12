
<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST"></a>

# Module `0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178::BST`

Red-black binary search tree


-  [Struct `N`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N)
-  [Struct `BST`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST)
-  [Constants](#@Constants_0)
-  [Function `use_v_funcs`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_use_v_funcs)
-  [Function `empty`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_empty)
-  [Function `singleton`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_singleton)
-  [Function `count`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_count)
-  [Function `is_empty`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_empty)
-  [Function `destroy_empty`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_destroy_empty)
-  [Function `borrow`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow)
-  [Function `borrow_mut`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow_mut)
-  [Function `get_c`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_c)
-  [Function `is_red`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_red)
-  [Function `is_black`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_black)
-  [Function `get_k`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_k)
-  [Function `get_p`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p)
-  [Function `get_l`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l)
-  [Function `get_r`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r)
-  [Function `set_c`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c)
-  [Function `set_p`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_p)
-  [Function `set_l`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_l)
-  [Function `set_r`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_r)
-  [Function `l_rotate`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_l_rotate)
-  [Function `parent_child_swap`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_child_swap)
-  [Function `r_rotate`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_r_rotate)
-  [Function `add_red_leaf`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_add_red_leaf)
-  [Function `search_parent_index`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_search_parent_index)
-  [Function `has_red_parent`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_red_parent)
-  [Function `parent_is_l_child`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_l_child)
-  [Function `parent_is_r_child`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_r_child)
-  [Function `right_uncle`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_right_uncle)
-  [Function `left_uncle`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_left_uncle)
-  [Function `uncle_on_side`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_uncle_on_side)
-  [Function `rotate_to_side`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_rotate_to_side)
-  [Function `is_child_on_side`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_child_on_side)
-  [Function `insertion_cleanup`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_insertion_cleanup)
-  [Function `fix_violation_cases`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_fix_violation_cases)
-  [Function `insert`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_insert)
-  [Function `limit`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_limit)
-  [Function `min`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_min)
-  [Function `max`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_max)
-  [Function `get_i`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_i)
-  [Function `get_ref`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_ref)
-  [Function `has_key`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_key)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N"></a>

## Struct `N`

A node in the binary search tree, representing a key-value pair
with a <code>u64</code> key and a value of type <code>V</code>


<pre><code><b>struct</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>k: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>c: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>p: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>l: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>r: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>v: V</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST"></a>

## Struct `BST`

A red-black binary search tree for key-value pairs with values
of type <code>V</code>


<pre><code><b>struct</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>r: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>t: vector&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">BST::N</a>&lt;V&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_B"></a>

Flag for black node


<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_B">B</a>: bool = <b>true</b>;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_CLEANUP_COLOR_INVALID"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_CLEANUP_COLOR_INVALID">E_CLEANUP_COLOR_INVALID</a>: u64 = 24;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_CLEANUP_RELATION_ERROR"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_CLEANUP_RELATION_ERROR">E_CLEANUP_RELATION_ERROR</a>: u64 = 25;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_DESTROY_NOT_EMPTY"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>: u64 = 4;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_EMPTY_NOT_NIL_MIN"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_EMPTY_NOT_NIL_MIN">E_EMPTY_NOT_NIL_MIN</a>: u64 = 29;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_GET_I_ERROR"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_GET_I_ERROR">E_GET_I_ERROR</a>: u64 = 32;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_GET_REF_ERROR"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_GET_REF_ERROR">E_GET_REF_ERROR</a>: u64 = 36;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_HAS_KEY_ERROR"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_HAS_KEY_ERROR">E_HAS_KEY_ERROR</a>: u64 = 34;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_INSERTION_DUPLICATE"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_INSERTION_DUPLICATE">E_INSERTION_DUPLICATE</a>: u64 = 11;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_INSERT_ROOT_NOT_EMPTY"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_INSERT_ROOT_NOT_EMPTY">E_INSERT_ROOT_NOT_EMPTY</a>: u64 = 12;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_KEY_ALREADY_EXISTS"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_KEY_ALREADY_EXISTS">E_KEY_ALREADY_EXISTS</a>: u64 = 35;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_ROTATE_NO_R_CHILD"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_ROTATE_NO_R_CHILD">E_L_ROTATE_NO_R_CHILD</a>: u64 = 5;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_ROTATE_RELATIONSHIP"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_ROTATE_RELATIONSHIP">E_L_ROTATE_RELATIONSHIP</a>: u64 = 6;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_ROTATE_ROOT"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_ROTATE_ROOT">E_L_ROTATE_ROOT</a>: u64 = 7;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_UNCLE_INVALID"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_UNCLE_INVALID">E_L_UNCLE_INVALID</a>: u64 = 28;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_UNCLE_N_P_L_C"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_UNCLE_N_P_L_C">E_L_UNCLE_N_P_L_C</a>: u64 = 27;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_MAX_INVALID"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_MAX_INVALID">E_MAX_INVALID</a>: u64 = 31;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_MIN_INVALID"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_MIN_INVALID">E_MIN_INVALID</a>: u64 = 30;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_NEW_NOT_EMPTY"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_NEW_NOT_EMPTY">E_NEW_NOT_EMPTY</a>: u64 = 0;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_NIL_KEY_LOOKUP"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_NIL_KEY_LOOKUP">E_NIL_KEY_LOOKUP</a>: u64 = 33;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_PARENT_L_C_INVALID"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_PARENT_L_C_INVALID">E_PARENT_L_C_INVALID</a>: u64 = 21;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_PARENT_R_C_INVALID"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_PARENT_R_C_INVALID">E_PARENT_R_C_INVALID</a>: u64 = 26;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_COLOR"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_COLOR">E_RED_LEAF_COLOR</a>: u64 = 16;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_KEY"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_KEY">E_RED_LEAF_KEY</a>: u64 = 15;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_L"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_L">E_RED_LEAF_L</a>: u64 = 18;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_LENGTH"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_LENGTH">E_RED_LEAF_LENGTH</a>: u64 = 13;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_P"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_P">E_RED_LEAF_P</a>: u64 = 17;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_R"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_R">E_RED_LEAF_R</a>: u64 = 19;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_ROOT_INDEX"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_ROOT_INDEX">E_RED_LEAF_ROOT_INDEX</a>: u64 = 14;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_V"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_LEAF_V">E_RED_LEAF_V</a>: u64 = 19;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_PARENT_INVALID"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_RED_PARENT_INVALID">E_RED_PARENT_INVALID</a>: u64 = 20;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_ROTATE_NO_L_CHILD"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_ROTATE_NO_L_CHILD">E_R_ROTATE_NO_L_CHILD</a>: u64 = 8;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_ROTATE_RELATIONSHIP"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_ROTATE_RELATIONSHIP">E_R_ROTATE_RELATIONSHIP</a>: u64 = 9;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_ROTATE_ROOT"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_ROTATE_ROOT">E_R_ROTATE_ROOT</a>: u64 = 10;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_UNCLE_INVALID"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_UNCLE_INVALID">E_R_UNCLE_INVALID</a>: u64 = 23;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_UNCLE_N_P_L_C"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_UNCLE_N_P_L_C">E_R_UNCLE_N_P_L_C</a>: u64 = 22;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_SINGLETON_NOT_EMPTY"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_SINGLETON_NOT_EMPTY">E_SINGLETON_NOT_EMPTY</a>: u64 = 1;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_SINGLETON_N_VAL"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_SINGLETON_N_VAL">E_SINGLETON_N_VAL</a>: u64 = 3;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_SINGLETON_R_VAL"></a>



<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_SINGLETON_R_VAL">E_SINGLETON_R_VAL</a>: u64 = 2;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_LEFT"></a>

Flag for checking left branch conditions


<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_LEFT">LEFT</a>: bool = <b>true</b>;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_MAX_NODES"></a>

Maximum number of nodes that can be kept in the tree, equivalent
to <code><a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a></code> - 1


<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_MAX_NODES">MAX_NODES</a>: u64 = 18446744073709551614;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL"></a>

Flag to indicate that there is no connected node for the given
relationship field (<code>parent</code>, <code>left</code>, or <code>right</code>), analagous to
a null pointer


<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_R"></a>

Flag for red node


<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_R">R</a>: bool = <b>false</b>;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_RIGHT"></a>

Flag for checking right branch conditions


<pre><code><b>const</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_RIGHT">RIGHT</a>: bool = <b>false</b>;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_use_v_funcs"></a>

## Function `use_v_funcs`

So Move doesn't raise unused member error in non-test mode


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_use_v_funcs">use_v_funcs</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_use_v_funcs">use_v_funcs</a>() {
    v_i_e(&v_s&lt;u8&gt;(1));
    v_po_b&lt;u8&gt;(&<b>mut</b> v_s&lt;u8&gt;(1));
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_empty"></a>

## Function `empty`

Return an empty BST with key-value pair values of type <code>V</code>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_empty">empty</a>&lt;V&gt;(): <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_empty">empty</a>&lt;V&gt;():
<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt; {
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>{r: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>, t: v_e&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;()}
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_singleton"></a>

## Function `singleton`

Return a BST with one node having key <code>k</code> and value <code>v</code>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_singleton">singleton</a>&lt;V&gt;(k: u64, v: V): <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_singleton">singleton</a>&lt;V&gt;(
    k: u64,
    v: V
):
<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt; {
    // Initialize first node <b>to</b> black, without parent or children
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>{r: 0, t: v_s&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;{k, c: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_B">B</a>, p: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>, l: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>, r: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>, v})}
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_count"></a>

## Function `count`

Return number of nodes in the BST


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_count">count</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_count">count</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;
): u64 {
    v_l&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&b.t) // Return length of the <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>'s vector of nodes
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_empty"></a>

## Function `is_empty`

Return true if the BST has no elements


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_empty">is_empty</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_empty">is_empty</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;
): bool {
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_count">count</a>(b) == 0
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_destroy_empty"></a>

## Function `destroy_empty`

Destroy the empty BST <code>b</code>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_destroy_empty">destroy_empty</a>&lt;V&gt;(b: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_destroy_empty">destroy_empty</a>&lt;V&gt;(
    b: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;
) {
    <b>assert</b>!(<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_empty">is_empty</a>(&b), <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>);
    <b>let</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>{r: _, t} = b;
    v_d_e(t);
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow"></a>

## Function `borrow`



<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow">borrow</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">BST::N</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow">borrow</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt; {
    v_b&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&b.t, n_i)
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow_mut"></a>

## Function `borrow_mut`

Return mutable reference to node at vector index <code>n_i</code> in BST
<code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow_mut">borrow_mut</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">BST::N</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow_mut">borrow_mut</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt; {
    v_b_m&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&<b>mut</b> b.t, n_i)
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_c"></a>

## Function `get_c`



<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_c">get_c</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_c">get_c</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): bool {
    v_b&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&b.t, n_i).c
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_red"></a>

## Function `is_red`



<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_red">is_red</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_red">is_red</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): bool {
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_c">get_c</a>&lt;V&gt;(b, n_i) == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_R">R</a>
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_black"></a>

## Function `is_black`



<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_black">is_black</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_black">is_black</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): bool {
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_c">get_c</a>&lt;V&gt;(b, n_i) == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_B">B</a>
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_k"></a>

## Function `get_k`

Return key of node at vector index <code>n_i</code> within BST <code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_k">get_k</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_k">get_k</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): u64 {
    v_b&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&b.t, n_i).k
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p"></a>

## Function `get_p`

Return vector index of parent to node at index <code>n_i</code>, within
BST <code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): u64 {
    v_b&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&b.t, n_i).p
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l"></a>

## Function `get_l`

Return vector index of left child to node at index <code>n_i</code>, within
BST <code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): u64 {
    v_b&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&b.t, n_i).l
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r"></a>

## Function `get_r`

Return vector index of right child to node at index <code>n_i</code>,
within BST <code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): u64 {
    v_b&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&b.t, n_i).r
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c"></a>

## Function `set_c`

Set node at vector index <code>n_i</code> within BST <code>b</code> to have color <code>c</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c">set_c</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64, c: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c">set_c</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64,
    c: bool
) {
    v_b_m&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&<b>mut</b> b.t, n_i).c = c;
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_p"></a>

## Function `set_p`

Set node at vector index <code>n_i</code> to have parent at index <code>p_i</code>,
within BST <code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_p">set_p</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64, p_i: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_p">set_p</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64,
    p_i: u64
) {
    v_b_m&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&<b>mut</b> b.t, n_i).p = p_i;
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_l"></a>

## Function `set_l`

Set node at vector index <code>n_i</code> to have left child at index
<code>l_i</code>, within BST <code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_l">set_l</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64, l_i: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_l">set_l</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64,
    l_i: u64
) {
    v_b_m&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&<b>mut</b> b.t, n_i).l = l_i;
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_r"></a>

## Function `set_r`

Set node at vector index <code>n_i</code> to have right child at index
<code>l_i</code>, within BST <code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_r">set_r</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64, r_i: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_r">set_r</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64,
    r_i: u64
) {
    v_b_m&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&<b>mut</b> b.t, n_i).r = r_i;
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_l_rotate"></a>

## Function `l_rotate`

Left rotate on the node with vector index <code>n_i</code> in BST <code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_l_rotate">l_rotate</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, x_i: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_l_rotate">l_rotate</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    x_i: u64, // Index of node <b>to</b> left rotate on
) {
    // Get index of x's right child (y)
    <b>let</b> y_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>&lt;V&gt;(b, x_i);
    // Assert x actually <b>has</b> a right child
    <b>assert</b>!(y_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_ROTATE_NO_R_CHILD">E_L_ROTATE_NO_R_CHILD</a>);
    // Get index of y's left child (w)
    <b>let</b> w_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>&lt;V&gt;(b, y_i);
    // Set x's right child <b>as</b> w
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_r">set_r</a>&lt;V&gt;(b, x_i, w_i);
    <b>if</b> (w_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) { // If y <b>has</b> a left child (<b>if</b> w is not null)
        // Set w's parent <b>to</b> be x
        <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_p">set_p</a>&lt;V&gt;(b, w_i, x_i);
    };
    // Swap the parent relationship between x and z <b>to</b> y
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_child_swap">parent_child_swap</a>(x_i, y_i, b);
    // Set y's left child <b>as</b> x
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_l">set_l</a>&lt;V&gt;(b, y_i, x_i);
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_child_swap"></a>

## Function `parent_child_swap`

Replace the bidirectional relationship between <code>x</code> and its
parent with a relationship between <code>y</code> and the same parent,
updating <code>x</code> to recognize <code>y</code> as a parent


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_child_swap">parent_child_swap</a>&lt;V&gt;(x_i: u64, y_i: u64, b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_child_swap">parent_child_swap</a>&lt;V&gt;(
    x_i: u64,
    y_i: u64,
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;
) {
    // Get index of x's parent (z)
    <b>let</b> z_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, x_i);
    // Set y's parent <b>as</b> z
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_p">set_p</a>&lt;V&gt;(b, y_i, z_i);
    <b>if</b> (z_i == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) { // If x is the root node
        b.r = y_i; // Set y <b>as</b> the new root node
    } <b>else</b> { // If x is not the root node
        // Get mutable reference <b>to</b> z
        <b>let</b> z = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow_mut">borrow_mut</a>&lt;V&gt;(b, z_i);
        <b>if</b> (z.l == x_i) { // If x is a left child
            z.l = y_i; // Set z's new left child <b>as</b> y
        } <b>else</b> { // If x is a right child
            z.r = y_i; // Set z's new right child <b>as</b> y
        }
    };
    // Set x's parent <b>as</b> y
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_p">set_p</a>&lt;V&gt;(b, x_i, y_i);
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_r_rotate"></a>

## Function `r_rotate`

Right rotate on node with vector index <code>n_i</code> in BST <code>b</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_r_rotate">r_rotate</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, x_i: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_r_rotate">r_rotate</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    x_i: u64 // Index of node <b>to</b> right rotate on
) {
    // Get index of x's left child (y)
    <b>let</b> y_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>&lt;V&gt;(b, x_i);
    // Assert x actually <b>has</b> a left child
    <b>assert</b>!(y_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_ROTATE_NO_L_CHILD">E_R_ROTATE_NO_L_CHILD</a>);
    // Get index of y's right child (w)
    <b>let</b> w_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>&lt;V&gt;(b, y_i);
    // Set x's left child <b>as</b> w
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_l">set_l</a>&lt;V&gt;(b, x_i, w_i);
    <b>if</b> (w_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) { // If y <b>has</b> a right child (<b>if</b> w is not null)
        // Set w's parent <b>to</b> be x
        <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_p">set_p</a>&lt;V&gt;(b, w_i, x_i);
    };
    // Swap the parent relationship between x and its parent <b>to</b> y
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_child_swap">parent_child_swap</a>(x_i, y_i, b);
    // Set y's right child <b>as</b> x
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_r">set_r</a>&lt;V&gt;(b, y_i, x_i);
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_add_red_leaf"></a>

## Function `add_red_leaf`

Insert key <code>k</code> and value <code>v</code> into BST <code>b</code> as a read leaf,
returning vector index of inserted node


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_add_red_leaf">add_red_leaf</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, k: u64, v: V): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_add_red_leaf">add_red_leaf</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    k: u64,
    v: V
): u64 {
    // Index of node that would have <b>as</b> a leaf a node <b>with</b> key `k`
    <b>let</b> p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_search_parent_index">search_parent_index</a>&lt;V&gt;(b, k);
    // Set index of insertion node <b>to</b> length of nodes vector, since
    // appending <b>to</b> the end of it
    <b>let</b> n_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_count">count</a>&lt;V&gt;(b);
    <b>if</b> (p_i == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) { // If inserting at root
        // Assert vector of nodes in tree is empty
        <b>assert</b>!(<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_empty">is_empty</a>&lt;V&gt;(b), <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_INSERT_ROOT_NOT_EMPTY">E_INSERT_ROOT_NOT_EMPTY</a>);
        b.r = n_i; // Set tree root <b>to</b> index of node (which is 0)
    } <b>else</b> { // If not inserting at root
        <b>let</b> p_k = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_k">get_k</a>&lt;V&gt;(b, p_i); // Get key of parent node
        <b>if</b> (k &lt; p_k) { // If insertion key less than parent key
            // Set parent's left child <b>to</b> insertion node
            <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_l">set_l</a>(b, p_i, n_i);
        // Since parent index search aborts for equality, only other
        // option is that insertion key is greater than parent key
        } <b>else</b> { // If insertion key is greater than parent key
            // Set parent's right child <b>to</b> insertion node
            <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_r">set_r</a>(b, p_i, n_i);
        }
    };
    // Append red leaf <b>to</b> tree's nodes vector
    v_pu_b&lt;<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;&gt;(&<b>mut</b> b.t, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_N">N</a>&lt;V&gt;{k, c: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_R">R</a>, p: p_i, l: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>, r: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>, v});
    n_i
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_search_parent_index"></a>

## Function `search_parent_index`

Search nodes from root of BST <code>b</code>, returning index of parent
node that would have as a leaf a node with key <code>k</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_search_parent_index">search_parent_index</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, k: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_search_parent_index">search_parent_index</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    k: u64
): u64 {
    <b>let</b> p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>; // Assume inserting at root, without a parent
    <b>let</b> s_i = b.r; // Index of search node, starting from root
    <b>while</b> (s_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) { // While search inspects an actual node
        p_i = s_i; // Set parent index <b>to</b> search index
        <b>let</b> s_k = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_k">get_k</a>(b, s_i); // Get key of search node
        // Abort <b>if</b> insertion key equals search key
        <b>if</b> (k == s_k) { <b>abort</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_INSERTION_DUPLICATE">E_INSERTION_DUPLICATE</a>
        // If insertion key less than search key
        } <b>else</b> <b>if</b> (k &lt; s_k) {
            s_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>(b, s_i); // Run next search <b>to</b> left
        } <b>else</b> { // If insertion key greater than search key
            s_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>(b, s_i); // Run next search <b>to</b> right
        }
    };
    p_i
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_red_parent"></a>

## Function `has_red_parent`

Return true if node at vector index <code>n_i</code> within BST <code>b</code> has a
red parent


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_red_parent">has_red_parent</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_red_parent">has_red_parent</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): bool {
    <b>let</b> p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, n_i); // Index of parent
    // Short-circuit logic will not try <b>to</b> check parent color <b>if</b> no
    // parent
    (p_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a> && <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_red">is_red</a>&lt;V&gt;(b, p_i))
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_l_child"></a>

## Function `parent_is_l_child`

Return true if node at vector index <code>n_i</code> within BST <code>b</code> has a
a parent that is a left child


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_l_child">parent_is_l_child</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_l_child">parent_is_l_child</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): bool {
    <b>let</b> p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, n_i); // Index of parent
    <b>if</b> (p_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) { // If n <b>has</b> a parent
        <b>let</b> g_p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, p_i); // Index of grandparent
        <b>if</b> (g_p_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) { // If n <b>has</b> a grandparent
            // Return <b>true</b> <b>if</b> grandparent's l child is parent
            <b>if</b> (<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>&lt;V&gt;(b, g_p_i) == p_i) <b>return</b> <b>true</b>
        }
    };
    <b>false</b>
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_r_child"></a>

## Function `parent_is_r_child`

Return true if node at vector index <code>n_i</code> within BST <code>b</code> has a
a parent that is a right child


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_r_child">parent_is_r_child</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_r_child">parent_is_r_child</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): bool {
    <b>let</b> p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, n_i); // Index of parent
    <b>if</b> (p_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) { // If n <b>has</b> a parent
        <b>let</b> g_p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, p_i); // Index of grandparent
        <b>if</b> (g_p_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) { // If n <b>has</b> a grandparent
            // Return <b>true</b> <b>if</b> grandparent's r child is parent
            <b>if</b> (<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>&lt;V&gt;(b, g_p_i) == p_i) <b>return</b> <b>true</b>
        }
    };
    <b>false</b>
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_right_uncle"></a>

## Function `right_uncle`

Return node vector index of right child of grandparent to node
<code>n_i</code> in BST <code>b</code>. Should only be called if node has parent that
is a left child


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_right_uncle">right_uncle</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_right_uncle">right_uncle</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): u64 {
    <b>assert</b>!(<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_l_child">parent_is_l_child</a>&lt;V&gt;(b, n_i), <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_R_UNCLE_N_P_L_C">E_R_UNCLE_N_P_L_C</a>);
    <b>let</b> p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, n_i); // Index of parent
    <b>let</b> g_p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, p_i); // Index of grandparent
    // Return grandparent's right child
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>&lt;V&gt;(b, g_p_i)
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_left_uncle"></a>

## Function `left_uncle`

Return node vector index of left child of grandparent to node
<code>n_i</code> in BST <code>b</code>. Should only be called if node has parent that
is a right child


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_left_uncle">left_uncle</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_left_uncle">left_uncle</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
): u64 {
    <b>assert</b>!(<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_r_child">parent_is_r_child</a>&lt;V&gt;(b, n_i), <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_L_UNCLE_N_P_L_C">E_L_UNCLE_N_P_L_C</a>);
    <b>let</b> p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, n_i); // Index of parent
    <b>let</b> g_p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, p_i); // Index of grandparent
    // Return grandparent's left child
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>&lt;V&gt;(b, g_p_i)
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_uncle_on_side"></a>

## Function `uncle_on_side`

Return vector index of uncle to node at <code>n_i</code>, on a given side


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_uncle_on_side">uncle_on_side</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64, s: bool): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_uncle_on_side">uncle_on_side</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64,
    s: bool
): u64 {
    <b>if</b> (s == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_LEFT">LEFT</a>) {
        <b>return</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_left_uncle">left_uncle</a>&lt;V&gt;(b, n_i)
    } <b>else</b> {
        <b>return</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_right_uncle">right_uncle</a>&lt;V&gt;(b, n_i)
    }
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_rotate_to_side"></a>

## Function `rotate_to_side`

Rotate on vector at index <code>n_i</code> to given side


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_rotate_to_side">rotate_to_side</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64, s: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_rotate_to_side">rotate_to_side</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64,
    s: bool
) {
    <b>if</b> (s == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_LEFT">LEFT</a>) {
        <b>return</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_l_rotate">l_rotate</a>&lt;V&gt;(b, n_i)
    } <b>else</b> {
        <b>return</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_r_rotate">r_rotate</a>&lt;V&gt;(b, n_i)
    }
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_child_on_side"></a>

## Function `is_child_on_side`

Determine if node at index <code>n_i</code> is a child of parent at index
<code>p_i</code>, for the given side


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_child_on_side">is_child_on_side</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64, p_i: u64, s: bool): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_child_on_side">is_child_on_side</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64,
    p_i: u64,
    s: bool
): bool {
    <b>if</b> (s == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_LEFT">LEFT</a>) {
        <b>return</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>&lt;V&gt;(b, p_i) == n_i
    } <b>else</b> {
        <b>return</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>&lt;V&gt;(b, p_i) == n_i
    }
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_insertion_cleanup"></a>

## Function `insertion_cleanup`

Starting at node <code>n_i</code>, cleanup property violations from
<code><a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_add_red_leaf">add_red_leaf</a>()</code>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_insertion_cleanup">insertion_cleanup</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_insertion_cleanup">insertion_cleanup</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64
) {
    <b>while</b> (<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_red_parent">has_red_parent</a>&lt;V&gt;(b, n_i)) { // While node <b>has</b> red parent
        // If node's parent is a left child
        <b>if</b> (<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_parent_is_l_child">parent_is_l_child</a>&lt;V&gt;(b, n_i)) { // I
            n_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_fix_violation_cases">fix_violation_cases</a>&lt;V&gt;(b, n_i, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_LEFT">LEFT</a>);
        // If node's parent is neither a left child nor a right
        // child, can be flagged <b>as</b> being a right child, since
        // mutation logic in `<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_fix_violation_cases">fix_violation_cases</a>()` will not
        // execute in this case. Hence, <b>if</b> node's parent is not a
        // left child, simply flag <b>as</b> being a right child
        } <b>else</b> {
            n_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_fix_violation_cases">fix_violation_cases</a>&lt;V&gt;(b, n_i, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_RIGHT">RIGHT</a>);
        };
    };
    <b>let</b> r_i = b.r; // Index of root
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c">set_c</a>&lt;V&gt;(b, r_i, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_B">B</a>); // Set root node <b>to</b> be black
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_fix_violation_cases"></a>

## Function `fix_violation_cases`

Fix BST property violation cases observed from node having
vector index <code>n_i</code> in BST <code>b</code>, depending on what kind of child
the node's parent is. Return vector index for next node to try
cleanup on


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_fix_violation_cases">fix_violation_cases</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, n_i: u64, s: bool): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_fix_violation_cases">fix_violation_cases</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    n_i: u64,
    s: bool // What kind of child red parent is, left or right
): u64 {
    <b>let</b> p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, n_i); // Index of parent
    <b>let</b> g_p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, p_i); // Grandparent index
    // Uncle <b>to</b> node on side opposite that of red parent's side <b>as</b>
    // a child
    <b>let</b> u_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_uncle_on_side">uncle_on_side</a>&lt;V&gt;(b, n_i, !s);
    // If node actually <b>has</b> an uncle and the uncle is red
    <b>if</b> ((u_i != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) && (<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_c">get_c</a>&lt;V&gt;(b, u_i) == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_R">R</a>)) {
        // Shift red up a level, conserving black height
        <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c">set_c</a>&lt;V&gt;(b, p_i, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_B">B</a>); // Set parent <b>to</b> black
        <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c">set_c</a>&lt;V&gt;(b, u_i, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_B">B</a>); // Set uncle <b>to</b> black
        <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c">set_c</a>&lt;V&gt;(b, g_p_i, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_R">R</a>); // Set grandparent <b>to</b> red
        n_i = g_p_i; // Repeat cleanup on newly-red grandparent
    } <b>else</b> { // If node does not have a red uncle
        // If node is a child on side opposite that of red parent
        <b>if</b> (<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_child_on_side">is_child_on_side</a>&lt;V&gt;(b, n_i, p_i, !s)) {
            n_i = p_i; // Mark parent node for new cleanup
            // Rotate on parent <b>to</b> side for which red parent is a
            // child
            <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_rotate_to_side">rotate_to_side</a>&lt;V&gt;(b, p_i, s);
            p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, n_i); // Get new parent
            g_p_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_p">get_p</a>&lt;V&gt;(b, p_i); // Get new grandparent
            // Passes onto case of node <b>as</b> child on side same <b>as</b>
            // red parent's side, which is now the case
        }; // If cleanup node is child on same side <b>as</b> red parent
        <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c">set_c</a>&lt;V&gt;(b, p_i, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_B">B</a>); // Set parent color <b>to</b> black
        <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_set_c">set_c</a>&lt;V&gt;(b, g_p_i, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_R">R</a>); // Set grandparent <b>to</b> red
        // Rotate on grandparent <b>to</b> side opposite that of red
        // parent's side <b>as</b> a child
        <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_rotate_to_side">rotate_to_side</a>(b, g_p_i, !s);
    };
    n_i
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_insert"></a>

## Function `insert`

Insert key-value pair with key <code>k</code> and value <code>v</code> into BST <code>b</code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_insert">insert</a>&lt;V&gt;(b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, k: u64, v: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_insert">insert</a>&lt;V&gt;(
    b: &<b>mut</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    k: u64,
    v: V
) {
    // Assert key is not already in <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>
    <b>assert</b>!(!<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_key">has_key</a>(b, k), <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_KEY_ALREADY_EXISTS">E_KEY_ALREADY_EXISTS</a>);
    // Append key-value pair <b>as</b> pre-cleanup red leaf
    <b>let</b> n_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_add_red_leaf">add_red_leaf</a>&lt;V&gt;(b, k, v);
    // Check <b>to</b> make sure <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a> didn't overflow by adding one <b>to</b> the
    // count of nodes in the nodes vector, since the max possible
    // index value is reserved for <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>. This will trigger a u64
    // overflow error <b>if</b> attempting <b>to</b> add more than <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_MAX_NODES">MAX_NODES</a>
    <b>let</b> _check: u64 = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_count">count</a>&lt;V&gt;(b) + 1;
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_insertion_cleanup">insertion_cleanup</a>&lt;V&gt;(b, n_i); // Cleanup (rebalance) tree
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_limit"></a>

## Function `limit`

Retern key at outermost position from search to either l or r


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_limit">limit</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, d: bool): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_limit">limit</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    d: bool, // Direction <b>to</b> search
): u64 {
    <b>if</b> (<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_empty">is_empty</a>&lt;V&gt;(b)) <b>return</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>; // Return <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a> flag <b>if</b> no keys
    <b>let</b> s_i = b.r; // Initialize search index <b>to</b> root node index
    // While there is another child <b>to</b> search for in given direction
    <b>loop</b> {
        // Get index of next node in given direction
        <b>let</b> next = <b>if</b> (d == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_LEFT">LEFT</a>) <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>&lt;V&gt;(b, s_i) <b>else</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>&lt;V&gt;(b, s_i);
        <b>if</b> (next == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) <b>break</b>;
        s_i = next;
    };
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_k">get_k</a>&lt;V&gt;(b, s_i) // Return key of final node from search
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_min"></a>

## Function `min`

Return minimum key in BST <code>b</code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <b>min</b>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <b>min</b>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;
): u64 {
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_limit">limit</a>&lt;V&gt;(b, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_LEFT">LEFT</a>)
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_max"></a>

## Function `max`

Return maximum key in BST <code>b</code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_max">max</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_max">max</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;
): u64 {
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_limit">limit</a>&lt;V&gt;(b, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_RIGHT">RIGHT</a>)
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_i"></a>

## Function `get_i`

Return node vector index of key <code>k</code>, if is in BST <code>b</code>, otherwise
return NIL


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_i">get_i</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, k: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_i">get_i</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    k: u64
): u64 {
    // Assert key <b>to</b> search is not <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a> flag
    <b>assert</b>!(k != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>, <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_E_NIL_KEY_LOOKUP">E_NIL_KEY_LOOKUP</a>);
    <b>if</b> (<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_is_empty">is_empty</a>&lt;V&gt;(b)) <b>return</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>; // Return <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a> flag <b>if</b> no keys
    <b>let</b> s_i = b.r; // Initialize search index <b>to</b> root node index
    // While match not found, keep searching
    <b>loop</b> {
        <b>let</b> s_k = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_k">get_k</a>&lt;V&gt;(b, s_i); // Get key of search node
        // Return search index <b>if</b> node <b>has</b> same key <b>as</b> `k`
        <b>if</b> (k == s_k) <b>return</b> s_i;
        // If key less than key of searched node look <b>to</b> L, <b>else</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_R">R</a>
        s_i = <b>if</b> (k &lt; s_k) <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_l">get_l</a>&lt;V&gt;(b, s_i) <b>else</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_r">get_r</a>&lt;V&gt;(b, s_i);
        // Return <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a> <b>if</b> no next node <b>to</b> search
        <b>if</b> (s_i == <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>) <b>return</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>;
    }
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_ref"></a>

## Function `get_ref`

Return reference to value in key-value pair having key <code>k</code>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_ref">get_ref</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, k: u64): &V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_ref">get_ref</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    k: u64
): &V {
    <b>let</b> n_i = <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_i">get_i</a>&lt;V&gt;(b, k); // Get node index of key `k`
    &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_borrow">borrow</a>&lt;V&gt;(b, n_i).v // Return reference <b>to</b> node's `v` field
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_key"></a>

## Function `has_key`

Return true if BST <code>b</code> has a node with key <code>k</code>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_key">has_key</a>&lt;V&gt;(b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;V&gt;, k: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_has_key">has_key</a>&lt;V&gt;(
    b: &<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">BST</a>&lt;V&gt;,
    k: u64
): bool {
    // Return <b>true</b> <b>if</b> non-<a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a> index returned by search for key
    <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_get_i">get_i</a>&lt;V&gt;(b, k) != <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_NIL">NIL</a>
}
</code></pre>



</details>
