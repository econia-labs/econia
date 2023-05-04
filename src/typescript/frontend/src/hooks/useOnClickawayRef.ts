import { useEffect, useRef } from "react";

export const useOnClickawayRef = (onClickaway: () => void) => {
  const ref = useRef<any>(null);
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (ref.current && !ref.current.contains(event.target)) {
        onClickaway();
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [ref]);
  return ref;
};
