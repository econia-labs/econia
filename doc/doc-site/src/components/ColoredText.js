import React from 'react';

export default function ColoredText({children, color}) {
  return (<span style={{color: color}}>{children}</span>);
}