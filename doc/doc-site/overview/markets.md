# Market structure

## Trading pairs

Assets in Econia are represented as `AptosFramework::Coin::Coin<phantom CoinType>`, thus having a `u64` value and associated `CoinInfo` metadata, including `decimals` and `symbol` fields.
Using terminology inherited from Forex markets, a "trading pair" is thus defined as a "base coin" denominated in terms of a "quote coin", for instance `FOO/BAR` denoting `FOO` denominated in `BAR`:
A `FOO/BAR` "price" of `12.34` means that one `FOO` costs 12.34 `BAR`.

## Scaling

Notably, in the above example values are listed as decimal amounts, which is what a user would probably see on a front-end web interface, but in Move, `Coin` types are ultimately represented as integers.
More specifically, if a front-end user were to trade 1 `FOO` for 12.34 `BAR`, they would actually be trading a `Coin<FOO>` of `value` 1000 for a `Coin<BAR>` of `value` 1234000000, or perhaps a `Coin<FOO>` of `value` 1000000000 for a `Coin<BAR>` of `value` 123400, depending on the actual `decimals` field defined in each `Coin`'s respective `CoinInfo`.

Since Econia's matching engine operates on the underlying integer values, not decimals, granularity problems can arise when a trading pair involves two assets with disparate valuations relative to one another, because the matching engine similarly denotes price as an integer.
The [`Econia::Registry`](../../../src/move/econia/build/Econia/docs/Registry.md) module documentation contains a more detailed explanation of the problem, omitted here in the interest of brevity.

Econia thus implements a "scaled price", formally defined as the number of indivisible quote coin subunits (`Coin<BAR>.value`) per `SF` base coin indivisible subunits (`Coin<FOO>.value`), with `SF` denoting scale factor.
Again, the above reference contains a more detailed description of scaled price with corresponding mathematical equations, but the following practical examples are provided here instead:

* Scale factor of 100
    * A user submits a bid to buy a `Coin<FOO>` of `value` 1200 at a scaled price of 34.
    * The scaled size of the order is 12 (`1200 / 100 = 12`), and it takes a `Coin<BAR>` of `value` 408 (`12 * 34 = 408`) to fill the order

* Scale factor of 1
    * A user submits a bid to buy a `Coin<FOO>` of `value` 123 at a scaled price of 4.
    * The scaled size of the order is 123 (`123 / 1 = 123`), and it takes a `Coin<BAR>` of `value` 492 (`123 * 4 = 492`) to fill the order.

Alternatively, consider the scale factor as denoting the number of indivisible subunits in a "parcel" of base coins, with scaled price denoting the number of quote coin subunits per parcel:
At a scale factor of 100, a user can only transact in parcels of 100 base coin (`Coin<FOO>.value = 100`), and multiplying the number of parcels by scaled price yields the number of quote coins (`Coin<BAR>.value`) on the other side of the trade:

* Scale factor of 10
    * A user submits a bid to buy a `Coin<FOO>` of `value` 120 at a price of 3.
    * The "scaled size" of the order (number of parcels) is 12 (`120 / 10 = 12`), and it takes a `Coin<BAR>` of `value` 36 (`12 * 3 = 36`) to fill the order
    * The order is stored in memory with a scaled price of 3 and a scaled size 12

## Market