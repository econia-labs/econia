import { ECONIA_ADDR } from "@/env";
import { type ApiCoin } from "@/types/api";
import { type MovePrimitive } from "@/types/move";

export class TypeTag {
  constructor(
    public addr: string,
    public module: string,
    public name: string
  ) {}

  static fromApiCoin(apiCoin: ApiCoin) {
    return new TypeTag(
      apiCoin.account_address,
      apiCoin.module_name,
      apiCoin.struct_name
    );
  }

  static fromTablistNode(tablistNode: {
    key: MovePrimitive;
    value: string | TypeTag;
  }) {
    return new TypeTag(
      ECONIA_ADDR,
      "tablist",
      `Node<${tablistNode.key},${tablistNode.value.toString()}>`
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
