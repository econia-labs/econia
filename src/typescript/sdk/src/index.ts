import { type AptosAccount, AptosClient, type MaybeHexString } from "aptos";

import { EconiaTransactionBuilder } from "./tx-builder";

export * as events from "../types/events";
export * as order from "../types/order";

export class EconiaClient {
  public readonly econiaAddress: MaybeHexString;
  public readonly aptosClient: AptosClient;
  public readonly userAccount: AptosAccount;

  public constructor(
    nodeUrl: string,
    econiaAddress: MaybeHexString,
    userAccount: AptosAccount
  ) {
    this.econiaAddress = econiaAddress;
    this.aptosClient = new AptosClient(nodeUrl);
    this.userAccount = userAccount;
  }

  public createTx(): EconiaTransactionBuilder {
    return new EconiaTransactionBuilder(this);
  }
}
