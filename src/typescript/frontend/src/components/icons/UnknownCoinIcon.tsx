import React from "react";

export const UnknownCoinIcon: React.FC<{
  className?: string;
  width?: number;
  height?: number;
  fill?: string;
}> = ({ className, width, height }) => {
  return (
    <svg
      className={className}
      width={width ?? 32}
      height={height ?? 32}
      viewBox="0 0 32 32"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <circle
        cx="16.3604"
        cy="16.3955"
        r="14.9756"
        stroke="#565656"
        strokeDasharray="4 4"
      />
    </svg>
  );
};
