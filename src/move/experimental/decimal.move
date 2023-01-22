/// quote = base * price * tick_size
/// price = quote / (base * tick_size)
///                  ^ need an inner u128 temp cast for digits > 1 ?
/// base = quote / (price * tick_size)
/// Alternatively could have `BaseTenPower` tick size.
module econia::decimal {

    const BASE: u64 = 10;

    struct SignedInteger has drop, store {
        is_nonnegative: bool,
        amount: u8
    }

    /// $d * 10 ^ p$.
    struct Decimal has drop, store {
        /// $d$.
        digits: u64,
        /// $p$.
        power: SignedInteger
    }

    public fun new_signed_integer(
        is_nonnegative: bool,
        amount: u8
    ): SignedInteger {
        SignedInteger{is_nonnegative, amount}
    }

    public fun new_decimal(
        digits: u64,
        power_is_nonnegative: bool,
        power_amount: u8
    ): Decimal {
        let power = new_signed_integer(power_is_nonnegative, power_amount);
        Decimal{digits, power}
    }

    public fun base_ten_power(
        power: u8
    ): u64 {
        let result = 1;
        while (power > 0) {
            result = result * BASE;
            power = power - 1;
        };
        result
    }

    /// Multiple `scalar` by `decimal`, return as `Decimal`.
    public fun scalar_product(
        scalar: u64,
        decimal: Decimal
    ): Decimal {
        decimal.digits = decimal.digits * scalar;
        decimal
    }

    /// Multiply `scalar` by `decimal` then resolve to `u64`.
    public fun scalar_product_resolved(
        scalar: u64,
        decimal: Decimal
    ): u64 {
        let digits_product = (scalar as u128) * (decimal.digits as u128);
        let base_ten_power = (base_ten_power(decimal.power.amount) as u128);
        if (decimal.power.is_nonnegative)
            (digits_product * base_ten_power as u64) else
            (digits_product / base_ten_power as u64)
    }

    /// Divide `scalar` by `decimal` then resolve to `u64`.
    public fun scalar_quotient_resolved(
        scalar: u64,
        decimal: Decimal
    ): u64 {
        let numerator = (scalar as u128);
        let denominator = (decimal.digits as u128);
        let base_ten_power = (base_ten_power(decimal.power.amount) as u128);
        if (decimal.power.is_nonnegative) {
            denominator = denominator * base_ten_power;
        } else {
            numerator = numerator * base_ten_power;
        };
        ((numerator / denominator) as u64)
    }

    #[test]
    fun test_base_ten_power() {
        assert!(base_ten_power(0) == 1, 0);
        assert!(base_ten_power(1) == 10, 0);
        assert!(base_ten_power(2) == 100, 0);
        assert!(base_ten_power(3) == 1000, 0);
    }

    #[test]
    fun test_scalar_product() {
        let decimal = new_decimal(123, true, 1);
        decimal = scalar_product(2, decimal);
        assert!(decimal.digits == 246, 0);
        assert!(decimal.power.is_nonnegative, 0);
        assert!(decimal.power.amount == 1, 0);
    }

    #[test]
    fun test_scalar_product_resolved() {
        assert!(scalar_product_resolved(2  , new_decimal(123, true , 0))
                == 246, 0);
        assert!(scalar_product_resolved(4  , new_decimal(15 , true , 1))
                == 600, 0);
        assert!(scalar_product_resolved(20 , new_decimal(35 , true , 2))
                == 70000, 0);
        assert!(scalar_product_resolved(3  , new_decimal(2  , true , 3))
                == 6000, 0);
        assert!(scalar_product_resolved(5  , new_decimal(2  , false, 1))
                == 1, 0);
        assert!(scalar_product_resolved(401, new_decimal(25 , false, 4))
                == 1, 0);
        assert!(scalar_product_resolved(35 , new_decimal(34 , false, 2))
                == 11, 0);
    }

    #[test]
    fun test_scalar_quotient_resolved() {
        assert!(scalar_quotient_resolved(120, new_decimal(6  , true , 1))
                == 2, 0);
        assert!(scalar_quotient_resolved(120, new_decimal(4  , true , 0))
                == 30, 0);
        assert!(scalar_quotient_resolved(12 , new_decimal(3  , false, 1))
                == 40, 0);
        assert!(scalar_quotient_resolved(12 , new_decimal(2  , false, 2))
                == 600, 0);
        assert!(scalar_quotient_resolved(120, new_decimal(458, false, 3))
                == 262, 0);
    }
}