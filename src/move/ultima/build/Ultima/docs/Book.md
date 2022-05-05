
<a name="0x1d157846c6d7ac69cbbc60590c325683_Book"></a>

# Module `0x1d157846c6d7ac69cbbc60590c325683::Book`

Order book functionality


-  [Struct `Order`](#0x1d157846c6d7ac69cbbc60590c325683_Book_Order)
-  [Struct `Price`](#0x1d157846c6d7ac69cbbc60590c325683_Book_Price)
-  [Resource `Book`](#0x1d157846c6d7ac69cbbc60590c325683_Book_Book)
-  [Constants](#@Constants_0)
-  [Function `publish_book`](#0x1d157846c6d7ac69cbbc60590c325683_Book_publish_book)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Book_Order"></a>

## Struct `Order`

Represents a single unfilled ask or bid at a given price


<pre><code><b>struct</b> <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_Order">Order</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>user: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>unfilled: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Book_Price"></a>

## Struct `Price`

Represents a single price level for either asks or bids.
Implemented as a binary search tree node


<pre><code><b>struct</b> <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_Price">Price</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>orders: vector&lt;<a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_Order">Book::Order</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Book_Book"></a>

## Resource `Book`

Order book container


<pre><code><b>struct</b> <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book">Book</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>counter: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>bids: vector&lt;<a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_Price">Book::Price</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>asks: vector&lt;<a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_Price">Book::Price</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1d157846c6d7ac69cbbc60590c325683_Book_ASK"></a>



<pre><code><b>const</b> <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_ASK">ASK</a>: bool = <b>false</b>;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Book_BID"></a>



<pre><code><b>const</b> <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_BID">BID</a>: bool = <b>true</b>;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Book_E_INVALID_BOOK_INIT"></a>



<pre><code><b>const</b> <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_E_INVALID_BOOK_INIT">E_INVALID_BOOK_INIT</a>: u64 = 1;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Book_E_INVALID_PUBLISH"></a>



<pre><code><b>const</b> <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_E_INVALID_PUBLISH">E_INVALID_PUBLISH</a>: u64 = 0;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Book_publish_book"></a>

## Function `publish_book`

Publish an order book at the Ultima account


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_publish_book">publish_book</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_publish_book">publish_book</a>(
    account: &signer
) {
    <b>assert</b>!(<a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @Ultima, <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_E_INVALID_PUBLISH">E_INVALID_PUBLISH</a>);
    <b>move_to</b>(account, <a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book">Book</a>{
        counter: 0,
        bids: <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_Price">Price</a>&gt;(),
        asks: <a href="../../../build/MoveStdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;<a href="Book.md#0x1d157846c6d7ac69cbbc60590c325683_Book_Price">Price</a>&gt;()
    });
}
</code></pre>



</details>
