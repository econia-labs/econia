import {
  type AptosAccount,
  AptosClient,
  type MaybeHexString,
  type Types,
} from "aptos";

export * as entryFunctions from "./entry_functions";
export * as events from "./events";
export * as order from "./order";
export * as utils from "./utils";

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

  public async submitTx(
    entry: Types.EntryFunctionPayload
  ): Promise<Types.Transaction> {
    const tx = await this.aptosClient.generateTransaction(
      this.userAccount.address(),
      entry
    );
    const signedTx = await this.aptosClient.signTransaction(
      this.userAccount,
      tx
    );
    const pendingTx = await this.aptosClient.submitTransaction(signedTx);
    const result = await this.aptosClient.waitForTransactionWithResult(
      pendingTx.hash
    );
    return result;
  }
}
