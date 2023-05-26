import { type ApiCoin } from "./api";

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

  static fromString(typeTag: string) {
    const [addr, module, name] = typeTag.split("::");
    return new TypeTag(addr, module, name);
  }

  toString() {
    return `${this.addr}::${this.module}::${this.name}`;
  }
}
