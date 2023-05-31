script {
    use aptos_framework::aptos_coin::AptosCoin;
    use econia::incentives;

    // Incentive parameters.
    const MARKET_REGISTRATION_FEE: u64 =  187969924;
    const UNDERWRITER_REGISTRATION_FEE: u64 = 75187;
    const CUSTODIAN_REGISTRATION_FEE: u64 =   75187;
    const TAKER_FEE_DIVISOR: u64 =             2000;
    const FEE_SHARE_DIVISOR_0: u64 =          10000;
    const FEE_SHARE_DIVISOR_1: u64 =           8333;
    const FEE_SHARE_DIVISOR_2: u64 =           7692;
    const FEE_SHARE_DIVISOR_3: u64 =           7143;
    const FEE_SHARE_DIVISOR_4: u64 =           6667;
    const FEE_SHARE_DIVISOR_5: u64 =           6250;
    const FEE_SHARE_DIVISOR_6: u64 =           5882;
    const TIER_ACTIVATION_FEE_0: u64 =            0;
    const TIER_ACTIVATION_FEE_1: u64 =      1503759;
    const TIER_ACTIVATION_FEE_2: u64 =     22556390;
    const TIER_ACTIVATION_FEE_3: u64 =    300751879;
    const TIER_ACTIVATION_FEE_4: u64 =   3759398496;
    const TIER_ACTIVATION_FEE_5: u64 =  45112781954;
    const TIER_ACTIVATION_FEE_6: u64 = 526315789473;
    const WITHDRAWAL_FEE_0: u64 =           1503759;
    const WITHDRAWAL_FEE_1: u64 =           1428571;
    const WITHDRAWAL_FEE_2: u64 =           1353383;
    const WITHDRAWAL_FEE_3: u64 =           1278195;
    const WITHDRAWAL_FEE_4: u64 =           1203007;
    const WITHDRAWAL_FEE_5: u64 =           1127819;
    const WITHDRAWAL_FEE_6: u64 =           1052631;

    fun update_incentives(
        econia: &signer,
    ) {
        incentives::update_incentives<AptosCoin>(
            econia,
            MARKET_REGISTRATION_FEE,
            UNDERWRITER_REGISTRATION_FEE,
            CUSTODIAN_REGISTRATION_FEE,
            TAKER_FEE_DIVISOR,
            vector[
                vector[
                    FEE_SHARE_DIVISOR_0,
                    TIER_ACTIVATION_FEE_0,
                    WITHDRAWAL_FEE_0,
                ],
                vector[
                    FEE_SHARE_DIVISOR_1,
                    TIER_ACTIVATION_FEE_1,
                    WITHDRAWAL_FEE_1,
                ],
                vector[
                    FEE_SHARE_DIVISOR_2,
                    TIER_ACTIVATION_FEE_2,
                    WITHDRAWAL_FEE_2,
                ],
                vector[
                    FEE_SHARE_DIVISOR_3,
                    TIER_ACTIVATION_FEE_3,
                    WITHDRAWAL_FEE_3,
                ],
                vector[
                    FEE_SHARE_DIVISOR_4,
                    TIER_ACTIVATION_FEE_4,
                    WITHDRAWAL_FEE_4,
                ],
                vector[
                    FEE_SHARE_DIVISOR_5,
                    TIER_ACTIVATION_FEE_5,
                    WITHDRAWAL_FEE_5,
                ],
                vector[
                    FEE_SHARE_DIVISOR_6,
                    TIER_ACTIVATION_FEE_6,
                    WITHDRAWAL_FEE_6,
                ],
            ]
        );
    }
}