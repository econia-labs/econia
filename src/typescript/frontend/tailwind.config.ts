import { type Config } from "tailwindcss";
import { fontFamily } from "tailwindcss/defaultTheme";
import colors from "tailwindcss/colors";

const config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        jost: ["var(--font-jost)", ...fontFamily.sans],
        "roboto-mono": ["var(--font-roboto-mono)", ...fontFamily.sans],
      },
    },
    colors: {
      ...colors,
      purple: "#8c3dd8",
      blue: "#62c6f8",
      green: "#6ed5a3",
      yellow: "#eef081",
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
