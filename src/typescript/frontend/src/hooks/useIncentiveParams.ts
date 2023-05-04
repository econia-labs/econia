import { StructTag, u8str } from "@manahippo/move-to-ts";
import { useQuery } from "@tanstack/react-query";
import BigNumber from "bignumber.js";

import { ECONIA_ADDR } from "../constants";
import { useEconiaSDK } from "./useEconiaSDK";

export type IntegratorFeeStoreTierParameters = {
  fee_share_divisor: BigNumber;
  tier_activation_fee: BigNumber;
  withdrawal_fee: BigNumber;
};

export type IncentiveParams = {
  utilityCoinTypeTag: StructTag;
  marketRegistrationFee: BigNumber;
  underwriterRegistrationFee: BigNumber;
  custodianRegistrationFee: BigNumber;
  takerFeeDivisor: BigNumber;
  integratorFeeStoreTiers: IntegratorFeeStoreTierParameters[];
};

export const useIncentiveParams = () => {
  const { econia } = useEconiaSDK();

  return useQuery<IncentiveParams>({
    queryKey: ["useTakerFeeDivisor"],
    queryFn: async () => {
      const params = await econia.incentives.loadIncentiveParameters(
        ECONIA_ADDR
      );
      return {
        utilityCoinTypeTag: new StructTag(
          params.utility_coin_type_info.account_address,
          u8str(params.utility_coin_type_info.module_name),
          u8str(params.utility_coin_type_info.struct_name),
          []
        ),
        marketRegistrationFee: new BigNumber(
          params.market_registration_fee.toJsNumber()
        ),
        underwriterRegistrationFee: new BigNumber(
          params.underwriter_registration_fee.toJsNumber()
        ),
        custodianRegistrationFee: new BigNumber(
          params.custodian_registration_fee.toJsNumber()
        ),
        takerFeeDivisor: new BigNumber(params.taker_fee_divisor.toJsNumber()),
        integratorFeeStoreTiers: params.integrator_fee_store_tiers.map(
          (tier) => ({
            fee_share_divisor: new BigNumber(
              tier.fee_share_divisor.toJsNumber()
            ),
            tier_activation_fee: new BigNumber(
              tier.tier_activation_fee.toJsNumber()
            ),
            withdrawal_fee: new BigNumber(tier.withdrawal_fee.toJsNumber()),
          })
        ),
      };
    },
  });
};
