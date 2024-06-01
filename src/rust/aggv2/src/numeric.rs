use std::fmt::Display;

use bigdecimal::BigDecimal;

macro_rules! make_numeric_type {
    ($name:ident) => {
        #[derive(Hash, PartialEq, Eq, PartialOrd, Ord, Clone)]
        pub struct $name(pub BigDecimal);

        impl std::fmt::Debug for $name {
            fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                write!(f, "{}({})", stringify!($name), self.0)
            }
        }

        impl std::fmt::Display for $name {
            fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                write!(f, "{}", self.0)
            }
        }

        impl $name {
            pub fn new(value: impl Into<BigDecimal>) -> Self {
                Self(value.into())
            }

            pub fn inner(self) -> BigDecimal {
                self.0
            }
        }

        impl std::ops::Add for $name {
            type Output = Self;
            fn add(self, rhs: Self) -> Self::Output {
                $name(self.0 + rhs.0)
            }
        }

        impl std::ops::Sub for $name {
            type Output = Self;
            fn sub(self, rhs: Self) -> Self::Output {
                $name(self.0 - rhs.0)
            }
        }

        impl std::ops::Add<u64> for $name {
            type Output = Self;
            fn add(self, rhs: u64) -> Self::Output {
                $name(self.0 + bigdecimal::BigDecimal::from(rhs))
            }
        }

        impl std::ops::Sub<u64> for $name {
            type Output = Self;
            fn sub(self, rhs: u64) -> Self::Output {
                $name(self.0 - bigdecimal::BigDecimal::from(rhs))
            }
        }

        impl std::ops::AddAssign for $name {
            fn add_assign(&mut self, rhs: Self) {
                self.0 += rhs.0;
            }
        }

        impl std::ops::SubAssign for $name {
            fn sub_assign(&mut self, rhs: Self) {
                self.0 -= rhs.0;
            }
        }

        impl std::ops::AddAssign<u64> for $name {
            fn add_assign(&mut self, rhs: u64) {
                self.0 += bigdecimal::BigDecimal::from(rhs);
            }
        }

        impl std::ops::SubAssign<u64> for $name {
            fn sub_assign(&mut self, rhs: u64) {
                self.0 -= bigdecimal::BigDecimal::from(rhs);
            }
        }

        impl std::ops::Mul for $name {
            type Output = Self;
            fn mul(self, rhs: Self) -> Self::Output {
                $name(self.0 * rhs.0)
            }
        }

        impl std::ops::Div for $name {
            type Output = Self;
            fn div(self, rhs: Self) -> Self::Output {
                $name(self.0 / rhs.0)
            }
        }

        impl std::ops::Mul<u64> for $name {
            type Output = Self;
            fn mul(self, rhs: u64) -> Self::Output {
                $name(self.0 * bigdecimal::BigDecimal::from(rhs))
            }
        }

        impl std::ops::Div<u64> for $name {
            type Output = Self;
            fn div(self, rhs: u64) -> Self::Output {
                $name(self.0 / bigdecimal::BigDecimal::from(rhs))
            }
        }

        impl std::ops::MulAssign for $name {
            fn mul_assign(&mut self, rhs: Self) {
                self.0 *= rhs.0;
            }
        }

        impl std::ops::DivAssign for $name {
            fn div_assign(&mut self, rhs: Self) {
                self.0 = &self.0 / rhs.0;
            }
        }

        impl std::ops::MulAssign<u64> for $name {
            fn mul_assign(&mut self, rhs: u64) {
                self.0 *= bigdecimal::BigDecimal::from(rhs);
            }
        }

        impl std::ops::DivAssign<u64> for $name {
            fn div_assign(&mut self, rhs: u64) {
                self.0 = &self.0 / bigdecimal::BigDecimal::from(rhs);
            }
        }
    };
}

make_numeric_type!(MarketId);
make_numeric_type!(OrderId);
make_numeric_type!(TransactionVersion);
make_numeric_type!(EventIndex);
make_numeric_type!(Lot);
make_numeric_type!(Tick);
make_numeric_type!(BaseSubunit);
make_numeric_type!(QuoteSubunit);
make_numeric_type!(Price);

#[derive(Hash, PartialEq, Eq, PartialOrd, Ord, Clone)]
pub struct BlockStamp(TransactionVersion, EventIndex);

impl Display for BlockStamp {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}({})", self.0, self.1)
    }
}

impl std::fmt::Debug for BlockStamp {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}({:?})", self.0, self.1)
    }
}

impl BlockStamp {
    pub fn from_raw_parts(transaction_version: impl Into<TransactionVersion>, event_id: impl Into<EventIndex>) -> Self {
        BlockStamp(transaction_version.into(), event_id.into())
    }

    pub fn from_transaction_version(transaction_version: TransactionVersion) -> Self {
        BlockStamp(transaction_version, EventIndex::new(0))
    }

    pub fn bump_version(&mut self) {
        self.0 += 1;
        self.1 = EventIndex::new(0);
    }

    pub fn bump_event(&mut self) {
        self.1 += 1;
    }

    pub fn transaction_version(&self) -> &TransactionVersion {
        &self.0
    }

    pub fn event_index(&self) -> &EventIndex {
        &self.1
    }
}

impl std::ops::Mul<Price> for Lot {
    type Output = Tick;
    fn mul(self, rhs: Price) -> Self::Output {
        Tick(self.0 * rhs.0)
    }
}

impl std::ops::Mul<&Price> for &Lot {
    type Output = Tick;
    fn mul(self, rhs: &Price) -> Self::Output {
        Tick(&self.0 * &rhs.0)
    }
}

impl std::ops::Div<Price> for Tick {
    type Output = Lot;
    fn div(self, rhs: Price) -> Self::Output {
        Lot(self.0 / rhs.0)
    }
}

impl std::ops::Div<&Price> for &Tick {
    type Output = Lot;
    fn div(self, rhs: &Price) -> Self::Output {
        Lot(&self.0 / &rhs.0)
    }
}

impl Tick {
    pub fn to_subunits(self, tick_size: impl Into<BigDecimal>) -> QuoteSubunit {
        QuoteSubunit(self.0 * tick_size.into())
    }
}

impl Lot {
    pub fn to_subunits(self, lot_size: impl Into<BigDecimal>) -> BaseSubunit {
        BaseSubunit(self.0 * lot_size.into())
    }
}

