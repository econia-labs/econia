import {
  createContext,
  type Dispatch,
  type PropsWithChildren,
  type SetStateAction,
  useContext,
  useState,
} from "react";

export type OrderEntryContextState = {
  price: string | undefined;
  setPrice: Dispatch<SetStateAction<string | undefined>>;
};

export const OrderEntryContext = createContext<
  OrderEntryContextState | undefined
>(undefined);

export function OrderEntryContextProvider({ children }: PropsWithChildren) {
  const [price, setPrice] = useState<string | undefined>(undefined);

  const value: OrderEntryContextState = {
    price,
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
      "useOrderEntry must be used within a OrderEntryContextProvider.",
    );
  }
  return context;
};
