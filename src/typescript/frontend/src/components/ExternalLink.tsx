import React from "react";

export const ExternalLink: React.FC<
  React.DetailedHTMLProps<
    React.AnchorHTMLAttributes<HTMLAnchorElement>,
    HTMLAnchorElement
  >
> = (props) => {
  return <a target="_blank" rel="noopener noreferrer" {...props} />;
};
