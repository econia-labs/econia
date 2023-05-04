import React from "react";

export const ArrowRightIcon: React.FC<{
  className?: string;
  width?: number;
  height?: number;
  fill?: string;
}> = ({ className, width, height }) => {
  return (
    <svg
      className={className}
      width={width ?? 18}
      height={height ?? 18}
      viewBox="0 0 18 18"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <g clipPath="url(#clip0_4151_6937)">
        <path
          d="M9.35059 3.19043L15.4157 9.25558L9.35059 15.3207"
          stroke="white"
          strokeWidth="3"
          strokeLinecap="square"
        />
        <path
          d="M14.9133 9.25488L2.5127 9.25488"
          stroke="white"
          strokeWidth="3"
          strokeLinecap="square"
        />
      </g>
      <defs>
        <clipPath id="clip0_4151_6937">
          <rect
            width="17.2043"
            height="17.2043"
            fill="white"
            transform="translate(0.362305 0.65332)"
          />
        </clipPath>
      </defs>
    </svg>
  );
};
