import { type Config } from "tailwindcss";
import colors from "tailwindcss/colors";
import { fontFamily } from "tailwindcss/defaultTheme";

const config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/contexts/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        jost: ["var(--font-jost)", ...fontFamily.sans],
        "roboto-mono": ["var(--font-roboto-mono)", ...fontFamily.sans],
      },
      screens: {
        tall: { raw: "(min-height: 960px)" },
      },
    },
    colors: {
      ...colors,
      purple: "#8c3dd8",
      blue: "#086cd9",
      "light-blue": "#62c6f8",
      green: "#6ed5a3",
      yellow: "#eef081",
      red: "#d56e6e",
      neutral: {
        100: "#FFFFFF",
        200: "#F9F9F9",
        300: "#F1F1F1",
        400: "#DADADA",
        500: "#AAAAAA",
        600: "#565656",
        700: "#161616",
        800: "#020202",
      },
    },
  },
  plugins: [require("@headlessui/tailwindcss")],
} satisfies Config;

export default config;
