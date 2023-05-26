import React from "react";

export const AddIcon: React.FC<{
  className?: string;
  width?: number;
  height?: number;
  fill?: string;
}> = ({ className, width, height }) => {
  return (
    <svg
      className={className}
      width={width ?? 50}
      height={height ?? 50}
      viewBox="0 0 50 50"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M15.2422 15.585L33.5704 33.9132"
        stroke="white"
        strokeWidth="3"
        strokeLinecap="square"
      />
      <path
        d="M15.2422 33.9131L33.5704 15.5849"
        stroke="white"
        strokeWidth="3"
        strokeLinecap="square"
      />
    </svg>
  );
};
