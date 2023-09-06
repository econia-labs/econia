export const NotRecognizedIcon: React.FC<React.SVGProps<SVGSVGElement>> = ({
  className,
}) => {
  return (
    <svg
      role="img"
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      <circle cx="11.6102" cy="12.2328" r="11.3778" fill="#565656" />
      <g clipPath="url(#clip0_5188_11744)">
        <path
          d="M7.17773 16.7328L16.1777 7.73279"
          stroke="#AAAAAA"
          strokeWidth="1.5"
          strokeLinecap="square"
        />
        <path
          d="M16.1777 16.7328L7.17773 7.73279"
          stroke="#AAAAAA"
          strokeWidth="1.5"
          strokeLinecap="square"
        />
      </g>
      <defs>
        <clipPath id="clip0_5188_11744">
          <rect
            width="12"
            height="12"
            fill="white"
            transform="translate(5.67773 6.23279)"
          />
        </clipPath>
      </defs>
    </svg>
  );
};
