use bigdecimal::{BigDecimal, num_bigint::{BigInt, ToBigInt}, FromPrimitive, ToPrimitive};

pub mod bar;
pub mod coin;
pub mod events;
pub mod fill;
pub mod market;
pub mod order;

pub trait ToInsertable {
    type Insertable<'a>
    where
        Self: 'a;

    fn to_insertable(&self) -> Self::Insertable<'_>;
}

// The current implementation is broken in BigDecimal
pub fn bigdecimal_from_u128(n: u128) -> Option<BigDecimal> {
    BigInt::from_u128(n).map(|n| BigDecimal::new(n, 0))
}

// The current implementation is broken in BigDecimal
pub fn bigdecimal_to_u128(n: &BigDecimal) -> Option<u128> {
    n.to_bigint().and_then(|n| n.to_u128())
}
