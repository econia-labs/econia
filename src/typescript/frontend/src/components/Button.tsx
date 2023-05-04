import styled from "@emotion/styled";

export const Button = styled.button<{
  size: "sm" | "md" | "lg";
  variant: "primary" | "secondary" | "outline";
}>`
  background-color: ${({ variant, theme }) =>
    variant === "primary"
      ? theme.colors.grey[100]
      : variant === "secondary"
      ? theme.colors.grey[700]
      : theme.colors.grey[800]}; // outline
  color: ${({ variant, theme }) =>
    variant === "primary" ? theme.colors.grey[700] : theme.colors.grey[100]};
  padding: ${({ size }) =>
    size === "sm"
      ? "12px 16px"
      : size === "md"
      ? "20px 28px 18px"
      : "28px 56px 26px"};
  font-size: ${({ size }) =>
    size === "sm" ? "16px" : size === "md" ? "18px" : "20px"};
  text-transform: uppercase;
  font-weight: 500;
  font-family: var(--font-roboto-mono);
  border: none;
  outline: ${({ variant, theme }) =>
    variant === "outline" ? `1px solid ${theme.colors.grey[600]}` : "none"};
  cursor: pointer;
  transition: background-color 300ms ease, transform 300ms ease,
    color 300ms ease, -webkit-transform 300ms ease;
  :hover {
    transform: translate3d(0px, -3px, 0.01px);
    outline: ${({ variant, theme }) =>
      variant === "outline"
        ? `1px solid ${theme.colors.purple.primary}`
        : "none"};
  }
`;
