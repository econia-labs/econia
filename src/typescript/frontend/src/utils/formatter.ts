export const getLang = () => {
  return typeof window === "undefined"
    ? "en"
    : navigator.language || navigator.languages[0];
};

export const plusMinus = (num: number | undefined): string => {
  if (!num) return "";
  // no need to return - as numbers will already have that
  return num >= 0 ? `+` : ``;
};

export const formatNumber = (
  num: number | undefined,
  digits: number,
  signDisplay: Intl.NumberFormatOptions["signDisplay"] = "never"
): string => {
  if (!num) return "-";
  const lang =
    typeof window === "undefined"
      ? "en"
      : navigator.language || navigator.languages[0];
  return num.toLocaleString(lang, {
    minimumFractionDigits: digits,
    maximumFractionDigits: digits,
    signDisplay,
  });
};

export const averageOrOther = (
  price1: number | undefined,
  price2: number | undefined
): number | undefined => {
  if (price1 !== undefined && price2 !== undefined) {
    return (price1 + price2) / 2;
  }
  if (price2 == undefined) {
    return price1;
  }
  if (price1 == undefined) {
    return price2;
  }
  // no prices (orderbook empty) maybe should get the last sale price then?
  return 0;
};
