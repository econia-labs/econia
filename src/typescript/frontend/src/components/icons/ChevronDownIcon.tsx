import React from "react";

export const ChevronDownIcon: React.FC<{
  className?: string;
  width?: number;
  height?: number;
}> = ({ className, width, height }) => {
  return (
    <svg
      className={className}
      width={width ?? 15}
      height={height ?? 15}
      viewBox="0 0 15 15"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M3.42786 5.57422L7.51119 9.65755L11.5945 5.57422"
        stroke="white"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
};
