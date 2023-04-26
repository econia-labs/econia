/** @type {import('prettier').Config} */
const config = {
  semi: true,
  tabWidth: 2,
  useTabs: false,
  singleQuote: false,
  trailingComma: "es5",
  printWidth: 80,
  arrowParens: "always",
  plugins: [require("prettier-plugin-tailwindcss")],
};

module.exports = config;
