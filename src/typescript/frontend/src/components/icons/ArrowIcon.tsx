export const ArrowIcon: React.FC<React.SVGProps<SVGSVGElement>> = ({
  className,
  id,
}) => {
  return (
    <svg
      width="13"
      height="13"
      viewBox="0 0 13 13"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      id={id}
    >
      <path
        d="M6.229 2.01317L10.6882 6.47241L6.229 10.9316"
        stroke="white"
        strokeWidth="2"
        strokeLinecap="square"
      />
      <path
        d="M10.3184 6.4724L1.20117 6.4724"
        stroke="white"
        strokeWidth="2"
        strokeLinecap="square"
      />
    </svg>
  );
};
