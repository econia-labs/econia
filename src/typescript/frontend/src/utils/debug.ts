export const debugLog = (...args: any[]) => {
  console.log(
    ...args.map((arg) => {
      if (typeof arg.toJsNumber === "function") return arg.toJsNumber();
      else if (typeof arg.getFullname === "function") return arg.getFullname();
      return arg.toString();
    })
  );
};
