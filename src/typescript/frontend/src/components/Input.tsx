import styled from "@emotion/styled";

export const Input = styled.input`
  background-color: ${({ theme }) => theme.colors.grey[800]};
  border: ${({ theme }) => `1px solid ${theme.colors.grey[600]}`};
  color: ${({ theme }) => theme.colors.grey[100]};
  padding: 16px 0px 14px 23px;
  line-height: normal;
  outline: none;
  font-size: 16px;
  font-weight: 300;
  ::placeholder {
    font-family: "Roboto Mono", monospace;
    font-weight: 300;
    color: ${({ theme }) => theme.colors.grey[600]};
  }
`;
