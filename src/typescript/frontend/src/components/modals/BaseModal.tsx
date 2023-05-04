import { useTheme } from "@emotion/react";
import styled from "@emotion/styled";
import React, { type PropsWithChildren } from "react";
import Modal from "react-modal";

import { XIcon } from "@/components/icons/XIcon";

import { FlexRow } from "../FlexRow";

export const BaseModal: React.FC<Modal.Props & PropsWithChildren> = ({
  style,
  children,
  ...props
}) => {
  const [xHover, setXHover] = React.useState(false);

  let content = {};
  let overlay = {};
  let restStyle = {};
  if (style) {
    const {
      content: contentOverride,
      overlay: overlayOverride,
      ...restStyleOverride
    } = style;
    if (contentOverride) {
      content = contentOverride;
    }
    if (overlayOverride) {
      overlay = overlayOverride;
    }
    restStyle = restStyleOverride;
  }
  const theme = useTheme();
  return (
    <Modal
      {...props}
      style={{
        content: {
          backgroundColor: theme.colors.grey[800],
          background:
            "url(https://global-uploads.webflow.com/62fce47e1be865a7155ff71c/633467a79910d8300a274060_bg-noise.png)",
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          transition: "all 300ms ease",
          border: `1px solid ${
            xHover ? theme.colors.purple.primary : theme.colors.grey[600]
          }`,
          borderRadius: "0px",
          padding: "0px 72px",
          height: "fit-content",
          ...content,
        },
        overlay: {
          background: "none",
          backdropFilter: "blur(5px)",
          WebkitBackdropFilter: "blur(5px)",
          zIndex: 3,
          ...overlay,
        },
        ...restStyle,
      }}
    >
      <CloseButtonContainer
        onClick={(e) => {
          props.onRequestClose && props.onRequestClose(e);
          setXHover(false);
        }}
        onMouseEnter={() => setXHover(true)}
        onMouseLeave={() => setXHover(false)}
      >
        <XIcon />
      </CloseButtonContainer>
      {children}
    </Modal>
  );
};

const CloseButtonContainer = styled(FlexRow)`
  position: absolute;
  width: 71px;
  height: 71px;
  top: 0;
  right: 0;
  border-left: 1px solid ${({ theme }) => theme.colors.grey[600]};
  border-bottom: 1px solid ${({ theme }) => theme.colors.grey[600]};
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: background-color 300ms ease, transform 300ms ease,
    color 300ms ease, -webkit-transform 300ms ease;
  :hover {
    background: ${({ theme }) => theme.colors.purple.primary};
    border-left: 1px solid ${({ theme }) => theme.colors.purple.primary};
    border-bottom: 1px solid ${({ theme }) => theme.colors.purple.primary};
  }
`;
