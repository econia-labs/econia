import styled from "@emotion/styled";

export const DropdownMenu = styled.div<{ show: boolean }>`
  display: ${({ show }) => (show ? "block" : "none")};
  position: absolute;
  z-index: 3;
  margin-top: 2px;
  .menu-item {
    background-color: ${({ theme }) => theme.colors.grey[800]};
    border-bottom: 1px solid ${({ theme }) => theme.colors.grey[600]};
    transition: background-color 300ms ease, transform 300ms ease,
      color 300ms ease, -webkit-transform 300ms ease;
    cursor: pointer;
    :last-of-type {
      border-bottom: none;
    }
    :hover {
      color: ${({ theme }) => theme.colors.purple.primary};
      outline: 1px solid ${({ theme }) => theme.colors.purple.primary};
    }
  }
`;
