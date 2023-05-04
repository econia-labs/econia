import React from "react";

export const SearchIcon: React.FC<{
  className?: string;
  width?: number;
  height?: number;
}> = ({ className, width, height }) => {
  return (
    <svg
      className={className}
      width={width ?? 19}
      height={height ?? 19}
      viewBox="0 0 19 19"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <g clipPath="url(#clip0_4130_8587)">
        <path
          d="M8.70042 14.8861C12.3823 14.8861 15.3671 11.9013 15.3671 8.2194C15.3671 4.5375 12.3823 1.55273 8.70042 1.55273C5.01852 1.55273 2.03375 4.5375 2.03375 8.2194C2.03375 11.9013 5.01852 14.8861 8.70042 14.8861Z"
          stroke="#565656"
          strokeWidth="1.4"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d="M17.0336 16.5527L13.4086 12.9277"
          stroke="#565656"
          strokeWidth="1.4"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </g>
      <defs>
        <clipPath id="clip0_4130_8587">
          <rect
            width="18"
            height="18"
            fill="white"
            transform="translate(0.533691 0.322266)"
          />
        </clipPath>
      </defs>
    </svg>
  );
};
