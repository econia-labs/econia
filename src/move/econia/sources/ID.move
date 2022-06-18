/// # Bit structure
///
/// An order id is a 128-bit number, where the most-significant
/// ("first") 64 bits indicate the scaled integer price (see
/// `Econia::Registry`) of the order, regardless of whether it is an ask
/// or bid. The least-significant ("last") 64 bits indicate the Aptos
/// database version number at which the order was placed, unmodified in
/// the case of an ask, but with each bit flipped in the case of a bid.
///
/// ## Example ask
///
/// For a scaled integer price of `255` (`0b11111111`) and an Aptos
/// database version number of `170` (`0b10101010`), an ask would have
/// an order ID with the first 64 bits
/// `0000000000000000000000000000000000000000000000000000000011111111`
/// and the last 64 bits
/// `0000000000000000000000000000000000000000000000000000000010101010`,
/// corresponding to the base-10 integer `4703919738795935662250`
///
/// ## Example bid
///
/// For a scaled integer price of `15` (`0b1111`) and an Aptos database
/// version number of `63` (`0b111111`), a bid would have an order ID
/// with the first 64 bits
/// `0000000000000000000000000000000000000000000000000000000000001111`
/// and the last 64 bits
/// `1111111111111111111111111111111111111111111111111111111111000000`,
/// corresponding to the base-10 integer `295147905179352825792`
///
/// # Motivations
///
/// Positions in an order book are represented as outer nodes in an
/// `Econia::CritBit` tree, which allows for traversal across nodes
/// during the matching process.
///
/// ## Market buy example
///
/// In the case of a market buy, the matching engine first fills against
/// the oldest ask at the lowest price, then fills against the second
/// oldest ask at the lowest price (if there is one). The process
/// continues, prioritizing older positions, until the price level has
/// been exhausted, at which point the matching engine moves onto the
/// next-lowest price level, similarly filling against positions in
/// chronological priority.
///
/// Here, with the first 64 bits of the order ID corresponding to price
/// and the last 64 bits corresponding to Aptos database version number,
/// asks are automatically sorted, upon insertion to the tree, into the
/// order in which they should be filled: first ascending from lowest
/// price to highest price, then ascending from lowest version number to
/// highest version number within a price level. All the matching engine
/// must do is iterate through inorder successor traversals until the
/// market buy has been filled.
///
/// ## Market sell example
///
/// In the case of a market sell, the ordering of prices is reversed,
/// but the chronology of priority is not: first the matching engine
/// should fill against bids at the highest price level, starting with
/// the oldest position, then fill older positions first, before moving
/// onto the next price level. Hence, the final 64 bits of the order ID
/// are all flipped, because this allows the matching engine to simply
/// iterate through inorder predecessor traversals until the market buy
/// has been filled.
///
/// More specifically, by flipping the final 64 bits, order IDs from
/// lower version numbers are sorted above those from higher version
/// numbers, within a given price level: at a scaled integer price of
/// `1` (`0b1`), an order from version number `15` (`0b1111`) has order
/// ID with bits
/// `11111111111111111111111111111111111111111111111111111111111110000`,
/// corresponding to the base-10 integer `36893488147419103216`, while
/// an order at the same price from version number `63` (`0b111111`) has
/// order ID with bits
/// `11111111111111111111111111111111111111111111111111111111111000000`,
/// corresponding to the base-10 integer `36893488147419103168`. The
/// order from version number `63` thus has an order ID of lesser value
/// than that of the order from version number `15`, and as such, during
/// the matching engine's iterated inorder predecessor traversal, the
/// order from version number `63` will be filled second.
module Econia::ID {

}