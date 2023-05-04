import React, {
  createContext,
  type PropsWithChildren,
  useContext,
  useMemo,
} from "react";

import { App } from "../sdk/src";
import { useAptos } from "./useAptos";

export const EconiaSDKContext = createContext<App | undefined>(undefined);

export const EconiaSDKContextProvider: React.FC<PropsWithChildren> = (
  props
) => {
  const { aptosClient } = useAptos();
  const sdk = useMemo(() => new App(aptosClient), [aptosClient]);
  return (
    <EconiaSDKContext.Provider value={sdk}>
      {props.children}
    </EconiaSDKContext.Provider>
  );
};

export const useEconiaSDK = () => {
  const context = useContext(EconiaSDKContext);
  if (!context) {
    throw new Error("useAptos must be used within an EconiaSDKContextProvider");
  }
  return context;
};
