export class TypeTag {
  constructor(
    public addr: string,
    public module: string,
    public name: string
  ) {}

  static fromString(typeTag: string) {
    const [addr, module, name] = typeTag.split("::");
    return new TypeTag(addr, module, name);
  }

  toString() {
    return `${this.addr}::${this.module}::${this.name}`;
  }
}
