import React, {
  createContext,
  type PropsWithChildren,
  useContext,
  useMemo,
} from "react";

import { MOBILE_MAX_WIDTH } from "../constants";

interface IIsMobileContext {
  isMobile: boolean;
}

export const IsMobileContext = createContext<IIsMobileContext | undefined>(
  undefined
);

export const IsMobileContextProvider: React.FC<PropsWithChildren> = (props) => {
  const isMobile = useMemo(() => {
    return window.innerWidth <= MOBILE_MAX_WIDTH;
  }, [window.innerWidth]);
  return (
    <>
      <IsMobileContext.Provider
        value={{
          isMobile,
        }}
      >
        {props.children}
      </IsMobileContext.Provider>
    </>
  );
};

export const useIsMobile = () => {
  const context = useContext(IsMobileContext);
  if (!context) {
    throw new Error(
      "useIsMobile must be used within an IsMobileContextProvider"
    );
  }
  return context;
};
