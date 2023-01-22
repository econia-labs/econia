module econia::price {

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A power of ten, $10^x$.
    struct PowerOfTen has drop, store {
        /// Absolute value of exponent, $|x|$.
        exponent_absolute_value: u8,
        /// `true` if $x \geq 0$.
        exponent_is_nonnegative: bool
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Exponent absolute value is out of bounds.
    const E_EXPONENT_ABSOLUTE_VALUE_TOO_LARGE: u64 = 0;
    /// Price encodes too many digits.
    const E_PRICE_TOO_MANY_DIGITS: u64 = 1;
    /// Price indicated as zero.
    const E_NO_PRICE: u64 = 2;
    /// Base amount overflows a `u64`.
    const E_BASE_OVERFLOW: u64 = 3;
    /// Base amount indicated as zero.
    const E_NO_BASE: u64 = 4;
    /// Quote amount indicated as zero.
    const E_NO_QUOTE: u64 = 5;
    /// Quote amount overflows a `u64`.
    const E_QUOTE_OVERFLOW: u64 = 6;
    /// Exponent of zero is marked as negative.
    const E_NOT_NEGATIVE_ZERO_POWER: u64 = 7;
    /// Denominator is zero for division operation.
    const E_DENOMINATOR_ZERO: u64 = 8;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Base 10 used for decimal pricing.
    const BASE_10: u64 = 10;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// The maximum power of 10 that can fit in a `u64`. Generated in
    /// Python via `floor(log(2 ** 64, 10))`.
    const MAX_EXPONENT_ABSOLUTE_VALUE: u8 = 19;
    /// Maximum price, set to restrict number of significant digits.
    const MAX_PRICE: u64 = 999999999;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Get base amount from given `quote_amount`, `price`, and
    /// `tick_size`.
    ///
    /// `base_amount = quote_amount / (price * tick_size)`.
    ///
    /// # Parameters
    ///
    /// * `quote_amount`: Indivisible quote units.
    /// * `price`: Number of ticks.
    /// * `tick_size`: Tick size.
    ///
    /// # Returns
    ///
    /// * `u64`: Corresponding indivisible base units.
    ///
    /// # Aborts
    ///
    /// * `E_NO_QUOTE`: Quote amount indicated as zero.
    /// * `E_NO_PRICE`: Price indicated as zero.
    /// * `E_PRICE_TOO_MANY_DIGITS`: Price encodes too many digits.
    /// * `E_BASE_OVERFLOW`: Base amount overflows a `u64`.
    /// * `E_NO_BASE`: Base amount indicated as zero.
    public fun get_base_amount(
        quote_amount: u64,
        price: u64,
        tick_size: PowerOfTen
    ): u64 {
        // Assert nonzero quote amount.
        assert!(quote_amount != 0, E_NO_QUOTE);
        // Assert nonzero price.
        assert!(price != 0, E_NO_PRICE);
        // Assert price does not have too many significant digits.
        assert!(price <= MAX_PRICE, E_PRICE_TOO_MANY_DIGITS);
        let base_amount = divide_with_tick_size_in_divisor(
            quote_amount, price, tick_size);
        // Assert base amount does not overflow.
        assert!(base_amount <= (HI_64 as u128), E_BASE_OVERFLOW);
        // Assert nonzero base amount.
        assert!(base_amount != 0, E_NO_BASE);
        (base_amount as u64) // Return base amount.
    }

    /// Get price from given `base_amount`, `quote_amount`, and
    /// `tick_size`.
    ///
    /// `price = quote_amount / (base_amount * tick_size)`.
    ///
    /// # Parameters
    ///
    /// * `base_amount`: Indivisible base units.
    /// * `quote_amount`: Indivisible quote units.
    /// * `tick_size`: Tick size.
    ///
    /// # Returns
    ///
    /// * `u64`: Corresponding price.
    ///
    /// # Aborts
    ///
    /// * `E_NO_BASE`: Base amount indicated as zero.
    /// * `E_NO_QUOTE`: Quote amount indicated as zero.
    /// * `E_PRICE_TOO_MANY_DIGITS`: Price encodes too many digits.
    /// * `E_NO_PRICE`: Price indicated as zero.
    public fun get_price(
        base_amount: u64,
        quote_amount: u64,
        tick_size: PowerOfTen
    ): u64 {
        // Assert nonzero base amount.
        assert!(base_amount != 0, E_NO_BASE);
        // Assert nonzero quote amount.
        assert!(quote_amount != 0, E_NO_QUOTE);
        let price = divide_with_tick_size_in_divisor(
            quote_amount, base_amount, tick_size);
        // Assert price does not contain too many digits.
        assert!(price <= (MAX_PRICE as u128), E_PRICE_TOO_MANY_DIGITS);
        // Assert nonzero price.
        assert!(price != 0, E_NO_PRICE);
        (price as u64) // Return price.
    }

    /// Get quote amount from given `base_amount`, `price`, and
    /// `tick_size`.
    ///
    /// `quote_amount = base_amount * price * tick_size`.
    ///
    /// # Parameters
    ///
    /// * `base_amount`: Indivisible base units.
    /// * `price`: Number of ticks.
    /// * `tick_size`: Tick size.
    ///
    /// # Returns
    ///
    /// * `u64`: Corresponding indivisible quote units.
    ///
    /// # Aborts
    ///
    /// * `E_NO_BASE`: Base amount indicated as zero.
    /// * `E_NO_PRICE`: Price indicated as zero.
    /// * `E_PRICE_TOO_MANY_DIGITS`: Price encodes too many digits.
    /// * `E_QUOTE_OVERFLOW`: Quote amount overflows a `u64`.
    /// * `E_NO_QUOTE`: Quote amount indicated as zero.
    public fun get_quote_amount(
        base_amount: u64,
        price: u64,
        tick_size: PowerOfTen
    ): u64 {
        // Assert nonzero base amount.
        assert!(base_amount != 0, E_NO_BASE);
        // Assert nonzero price.
        assert!(price != 0, E_NO_PRICE);
        // Assert price does not have too many significant digits.
        assert!(price <= MAX_PRICE, E_PRICE_TOO_MANY_DIGITS);
        // Calculate product to either multiply or divide.
        let product = (base_amount as u128) * (price as u128);
        let power_of_ten = // Get power of ten to multiply or divide by.
            (ten_to_the(tick_size.exponent_absolute_value) as u128);
        // Get quote amount: if tick size is nonnegative, multiply.
        let quote_amount = if (tick_size.exponent_is_nonnegative)
            ((product * power_of_ten)) else
            ((product / power_of_ten)); // Else divide.
        // Assert quote does not overflow.
        assert!(quote_amount <= (HI_64 as u128), E_QUOTE_OVERFLOW);
        // Assert nonzero quote amount.
        assert!(quote_amount != 0, E_NO_QUOTE);
        (quote_amount as u64) // Return quote amount.
    }

    /// Return a new `PowerOfTen`.
    ///
    /// # Parameters
    ///
    /// * `exponent_absolute_value`:
    ///   `PowerOfTen.exponent_absolute_value`.
    /// * `exponent_is_nonnegative`:
    ///   `PowerOfTen.exponent_is_nonnegative`.
    ///
    /// # Returns
    ///
    /// * `PowerOfTen`: A `PowerOfTen` with indicated fields.
    ///
    /// # Aborts
    ///
    /// * `E_EXPONENT_ABSOLUTE_VALUE_TOO_LARGE`: Exponent absolute value
    ///   is out of bounds.
    /// * `E_NOT_NEGATIVE_ZERO_POWER`: Exponent of zero is marked as
    ///   negative.
    public fun new_power_of_ten(
        exponent_absolute_value: u8,
        exponent_is_nonnegative: bool
    ): PowerOfTen {
        // Assert exponent absolute value is in bounds.
        assert!(exponent_absolute_value <= MAX_EXPONENT_ABSOLUTE_VALUE,
                E_EXPONENT_ABSOLUTE_VALUE_TOO_LARGE);
        // If exponent absolute value is 0:
        if (exponent_absolute_value == 0)
            // Assert it is flagged as nonnegative.
            assert!(exponent_is_nonnegative, E_NOT_NEGATIVE_ZERO_POWER);
        PowerOfTen{exponent_absolute_value, exponent_is_nonnegative}
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Inner function for both `get_base_amount()` and `get_price()`,
    /// which perform similar division operations.
    ///
    /// Divide `numerator` by `denominator`, and divide by `tick_size`
    /// again, manipulating operation sequence based sign on `tick_size`
    /// exponent.
    ///
    /// # Parameters
    ///
    /// * `numerator`: Numerator for quotient.
    /// * `denominator`: Denominator for quotient.
    /// * `tick_size`: Tick size to divide by.
    ///
    /// # Returns
    ///
    /// * `u128`: Quotient cast to a `u128`.
    ///
    /// # Aborts
    ///
    /// * `E_DENOMINATOR_ZERO`: Denominator is zero.
    ///
    /// # Overflow commentary
    ///
    /// Since `numerator`, `denominator`, and `power_of_ten` terms are
    /// originally `u64` values, there is no way to overflow a `u128`
    /// via the product between any of these two terms.
    fun divide_with_tick_size_in_divisor(
        numerator: u64,
        denominator: u64,
        tick_size: PowerOfTen
    ): u128 {
        // Assert nonozero denominator.
        assert!(denominator != 0, E_DENOMINATOR_ZERO);
        // Cast numerator to u128.
        let numerator = (numerator as u128);
        // Cast denominator to u128.
        let denominator = (denominator as u128);
        let power_of_ten = // Get power of ten to multiply a term by.
            (ten_to_the(tick_size.exponent_absolute_value) as u128);
        // If tick size exponent is nonnegative:
        if (tick_size.exponent_is_nonnegative) {
            // Multiply denominator by the power of ten.
            denominator = denominator * power_of_ten;
        } else { // If tick size exponent is negative:
            // Multiply denominator by the power of ten.
            numerator = numerator * power_of_ten;
        };
        numerator / denominator // Return quotient.
    }

    /// Return result of ten raised to given `power`.
    ///
    /// # Parameters
    ///
    /// * `power`: Power to raise ten by.
    ///
    /// # Returns
    ///
    /// * `u64`: Ten raised to given `power`.
    ///
    /// # Aborts
    ///
    /// * `E_EXPONENT_ABSOLUTE_VALUE_TOO_LARGE`: Exponent absolute value
    ///   is out of bounds.
    ///
    /// # Testing
    ///
    /// * `test_ten_to_the`
    fun ten_to_the(
        power: u8
    ): u64 {
        // Assert exponent absolute value is in bounds.
        assert!(power <= MAX_EXPONENT_ABSOLUTE_VALUE,
                E_EXPONENT_ABSOLUTE_VALUE_TOO_LARGE);
        let result = 1; // Initialize result for zero power.
        while (power > 0) { // Loop over power variable:
            // Multiply by base.
            result = result * BASE_10;
            // Decrement power loop counter.
            power = power - 1;
        };
        result // Return result.
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    fun test_ten_to_the() {
        // Verify standard returns.
        assert!(ten_to_the(0) == 1, 0);
        assert!(ten_to_the(1) == 10, 0);
        assert!(ten_to_the(2) == 100, 0);
        // Get max power of ten.
        let max_power_of_ten = ten_to_the(MAX_EXPONENT_ABSOLUTE_VALUE);
        // Assert multiplying it by 10 overflows a u64.
        assert!((max_power_of_ten as u128) * 10 > (HI_64 as u128), 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}