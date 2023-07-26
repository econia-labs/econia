/** @type {import("eslint").Linter.Config} */
const config = {
  parser: "@typescript-eslint/parser",
  env: {
    browser: true,
    node: true,
  },
  extends: [
    "next/core-web-vitals",
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended",
  ],
  parserOptions: {
    ecmaVersion: "latest",
    sourceType: "module",
  },
  plugins: [
    "@typescript-eslint",
    "prettier",
    "tailwindcss",
    "simple-import-sort",
  ],
  rules: {
    "no-console": ["warn", { allow: ["warn", "error"] }],
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": [
      "warn",
      { argsIgnorePattern: "^_", destructuredArrayIgnorePattern: "^_" },
    ],
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/consistent-type-imports": [
      "warn",
      { prefer: "type-imports", fixStyle: "inline-type-imports" },
    ],
    "simple-import-sort/imports": "warn",
    "simple-import-sort/exports": "warn",
  },
};

module.exports = config;
