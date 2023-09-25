export const CopyIcon: React.FC<React.SVGProps<SVGSVGElement>> = ({
  className,
  id,
  onClick,
}) => {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="18"
      height="19"
      viewBox="0 0 18 19"
      fill="none"
      className={className}
      id={id}
      onClick={onClick}
    >
      <path
        fillRule="evenodd"
        clipRule="evenodd"
        d="M12.1266 1.81006H1.61206V12.3246H5.20147V6.72963V5.72963H6.20147H12.1266V1.81006ZM13.1266 5.72963V1.81006V0.810059H12.1266H1.61206H0.612061V1.81006V12.3246V13.3246H1.61206H5.20147V17.2442V18.2442H6.20147H16.716H17.716V17.2442V6.72963V5.72963H16.716H13.1266ZM6.20147 6.72963H16.716V17.2442H6.20147V6.72963Z"
        fill="#565656"
      />
    </svg>
  );
};
