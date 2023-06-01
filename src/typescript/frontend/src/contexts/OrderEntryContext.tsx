import {
  createContext,
  type Dispatch,
  type PropsWithChildren,
  type SetStateAction,
  useContext,
  useState,
  useEffect,
} from "react";

import { type Side } from "@/types/global";

type SetSideType = React.Dispatch<React.SetStateAction<Side>> | undefined;
export type OrderEntryContextState = {
  type: "buy" | "sell";
  setType: Dispatch<SetStateAction<"buy" | "sell">>;
  price: string;
  setPrice: Dispatch<SetStateAction<string>>;

  setSide: SetSideType;
  setSetSide: Dispatch<SetStateAction<SetSideType>>;
};

export const OrderEntryContext = createContext<
  OrderEntryContextState | undefined
>(undefined);

export function OrderEntryContextProvider({ children }: PropsWithChildren) {
  const [type, setType] = useState<"buy" | "sell">("buy");
  const [price, setPrice] = useState<string>("");

  const [setSide, setSetSide] =
    useState<React.Dispatch<React.SetStateAction<Side>>>();

  const value: OrderEntryContextState = {
    type,
    price,
    setType,
    setPrice,
    setSide,
    setSetSide,
  };
  return (
    <OrderEntryContext.Provider value={value}>
      {children}
    </OrderEntryContext.Provider>
  );
}

export const useOrderEntry = (): OrderEntryContextState => {
  const context = useContext(OrderEntryContext);
  if (context == null) {
    throw new Error(
      "useOrderEntry must be used within a OrderEntryContextProvider."
    );
  }
  return context;
};

export const useSetSide = (
  setSide: React.Dispatch<React.SetStateAction<Side>>
) => {
  const { setSetSide, setPrice } = useOrderEntry();
  useEffect(() => {
    console.log("useSetSide", setSide);
    setPrice("testing");
    setSetSide(setSide);
    // setSide("sell");
  }, [setSide, setSetSide, setPrice]);
};
