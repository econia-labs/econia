import React from "react";

import { AddIcon } from "@/components/icons/AddIcon";

export const XIcon: React.FC<{
  className?: string;
  width?: number;
  height?: number;
  fill?: string;
}> = ({ className, width, height }) => {
  return (
    <AddIcon
      className={`[&>svg]:-rotate-45 ` + (className ? className : "")}
      width={width}
      height={height}
    />
  );
};
