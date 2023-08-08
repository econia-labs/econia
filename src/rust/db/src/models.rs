use bigdecimal::{
    num_bigint::{BigInt, ToBigInt},
    BigDecimal, FromPrimitive, ToPrimitive,
};
use diesel::associations::HasTable;

pub mod bar;
pub mod coin;
pub mod market;
pub mod order;

pub trait ToInsertable: HasTable {
    type Insertable<'a>: diesel::Insertable<<Self as HasTable>::Table>
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
