import { type Config } from "tailwindcss";
import { fontFamily } from "tailwindcss/defaultTheme";

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
  },
  plugins: [],
} satisfies Config;

export default config;
