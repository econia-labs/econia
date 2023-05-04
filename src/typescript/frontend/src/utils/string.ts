export const hexToUtf8 = (hexStr: string): string => {
  if (hexStr.startsWith("0x")) hexStr = hexStr.slice(2);
  return Buffer.from(hexStr, "hex").toString("utf8");
};
