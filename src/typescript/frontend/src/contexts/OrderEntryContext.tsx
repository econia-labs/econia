import {
  createContext,
  type Dispatch,
  type PropsWithChildren,
  type SetStateAction,
  useContext,
  useState,
} from "react";

export type OrderEntryContextState = {
  type: "buy" | "sell";
  setType: Dispatch<SetStateAction<"buy" | "sell">>;
  price: string;
  setPrice: Dispatch<SetStateAction<string>>;
};

export const OrderEntryContext = createContext<
  OrderEntryContextState | undefined
>(undefined);

export function OrderEntryContextProvider({ children }: PropsWithChildren) {
  const [type, setType] = useState<"buy" | "sell">("buy");
  const [price, setPrice] = useState<string>("");
  const value: OrderEntryContextState = {
    type,
    price,
    setType,
    setPrice,
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
