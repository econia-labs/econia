import { ECONIA_ADDR } from "@/env";
import { type ApiCoin } from "@/types/api";
import { type MovePrimitive, type MoveTypeInfo } from "@/types/move";

export class TypeTag {
  constructor(
    public addr: string,
    public module: string,
    public name: string,
  ) {}

  static fromApiCoin(apiCoin: ApiCoin) {
    return new TypeTag(
      apiCoin.account_address,
      apiCoin.module_name,
      apiCoin.struct_name,
    );
  }

  static fromMoveTypeInfo(moveTypeInfo: MoveTypeInfo) {
    function hexToString(hex: string) {
      if (hex.startsWith("0x")) {
        hex = hex.slice(2);
      }
      let str = "";
      for (let i = 0; i < hex.length; i += 2) {
        const charCode = parseInt(hex.substr(i, 2), 16);
        str += String.fromCharCode(charCode);
      }
      return str;
    }
    return new TypeTag(
      moveTypeInfo.account_address,
      hexToString(moveTypeInfo.module_name),
      hexToString(moveTypeInfo.struct_name),
    );
  }

  static fromTablistNode(tablistNode: {
    key: MovePrimitive;
    value: string | TypeTag;
  }) {
    return new TypeTag(
      ECONIA_ADDR,
      "tablist",
      `Node<${tablistNode.key},${tablistNode.value.toString()}>`,
    );
  }

  static fromString(typeTag: string) {
    const [addr, module, name] = typeTag.split("::");
    return new TypeTag(addr, module, name);
  }

  toString() {
    return `${this.addr}::${this.module}::${this.name}`;
  }
}
