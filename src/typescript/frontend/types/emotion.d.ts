import "@emotion/react";

declare module "@emotion/react" {
  type Color = { primary: string } & Record<number, string>;
  export interface Theme {
    colors: {
      red: Color;
      purple: Color;
      blue: Color;
      green: Color;
      yellow: Color;
      grey: Color;
    };
  }
}
