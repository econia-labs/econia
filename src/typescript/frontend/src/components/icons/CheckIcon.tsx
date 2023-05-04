import React from "react";

export const CheckIcon: React.FC<{
  className?: string;
  width?: number;
  height?: number;
  fill?: string;
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
      <g clipPath="url(#clip0_4226_6591)">
        <path
          d="M1.48926 8.2531L4.76932 11.5332L12.9695 3.33301"
          stroke="white"
          strokeWidth="2"
          strokeLinecap="square"
        />
      </g>
      <defs>
        <clipPath id="clip0_4226_6591">
          <rect
            width="14"
            height="14"
            fill="white"
            transform="translate(0.229492 0.433105)"
          />
        </clipPath>
      </defs>
    </svg>
  );
};
