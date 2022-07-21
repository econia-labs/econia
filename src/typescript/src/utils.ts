import { StructTag, getTypeTagFullname, parseTypeTagOrThrow, TypeTag, u8str, strToU8 } from "@manahippo/move-to-ts";
import { AptosAccount, AptosClient, HexString, Types } from "aptos";
import * as AptosFramework from "./generated/AptosFramework";
import * as fs from "fs";
import * as yaml from "yaml";
import { Command } from "commander";


export function typeInfoToTypeTag(typeInfo: AptosFramework.TypeInfo.TypeInfo) {
  const fullname =  `${typeInfo.account_address.hex()}::${u8str(typeInfo.module_name)}::${u8str(typeInfo.struct_name)}`;
  return parseTypeTagOrThrow(fullname);
}

export function typeTagToTypeInfo(tag: TypeTag): AptosFramework.TypeInfo.TypeInfo {
  const fullname = getTypeTagFullname(tag);
  const [addr, modName, structName] = fullname.split("::");
  return new AptosFramework.TypeInfo.TypeInfo({
    account_address: new HexString(addr),
    module_name: strToU8(modName),
    struct_name: strToU8(structName),
  }, new StructTag(AptosFramework.TypeInfo.moduleAddress, AptosFramework.TypeInfo.moduleName, AptosFramework.TypeInfo.TypeInfo.structName, []))
}

export function isTypeInfoSame(ti1: AptosFramework.TypeInfo.TypeInfo, ti2: AptosFramework.TypeInfo.TypeInfo) {
  return ti1.account_address.toShortString() === ti2.account_address.toShortString() &&
    u8str(ti1.module_name) === u8str(ti2.module_name) && 
    u8str(ti1.struct_name) === u8str(ti2.struct_name);
}

export const readConfig = (program: Command) => {
  const {config, profile} = program.opts();
  const ymlContent = fs.readFileSync(config, {encoding: "utf-8"});
  const result = yaml.parse(ymlContent);
  //console.log(result);
  if (!result.profiles) {
    throw new Error("Expect a profiles to be present in yaml config");
  }
  if (!result.profiles[profile]) {
    throw new Error(`Expect a ${profile} profile to be present in yaml config`);
  }
  const url = result.profiles[profile].rest_url;
  const privateKeyStr = result.profiles[profile].private_key;
  if (!url) {
    throw new Error(`Expect rest_url to be present in ${profile} profile`);
  }
  if (!privateKeyStr) {
    throw new Error(`Expect private_key to be present in ${profile} profile`);
  }
  const privateKey = new HexString(privateKeyStr);
  const client = new AptosClient(result.profiles[profile].rest_url);
  const account = new AptosAccount(privateKey.toUint8Array());
  console.log(`Using address ${account.address().hex()}`);
  return {client, account};
}

export async function sendPayloadTx(
  client: AptosClient, 
  account: AptosAccount, 
  payload: Types.TransactionPayload, 
  max_gas=1000
){
  const txnRequest = await client.generateTransaction(account.address(), payload, {max_gas_amount: `${max_gas}`});
  const signedTxn = await client.signTransaction(account, txnRequest);
  const txnResult = await client.submitTransaction(signedTxn);
  await client.waitForTransaction(txnResult.hash);
  const txDetails = (await client.getTransaction(txnResult.hash)) as Types.UserTransaction;
  console.log(txDetails);
}
