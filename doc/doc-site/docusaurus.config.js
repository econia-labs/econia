const lightCodeTheme = require("prism-react-renderer/themes/github");
const darkCodeTheme = require("prism-react-renderer/themes/dracula");

const math = require('remark-math');
const katex = require('rehype-katex');

module.exports = {
  title: "Econia Docs",
  tagline: "Documentation for the Econia protocol",
  url: "https://econia.dev",
  baseUrl: "/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.png",

  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  presets: [
    [
      'redocusaurus',
      {
        // Plugin Options for loading OpenAPI files
        specs: [
          {
            id: "dss-rest-api",
            spec: 'openapi.json',
            route: '/api/',
          },
        ],
        debugger: true,
        // Theme Options for modifying how redoc renders them
        theme: {
          // Change with your site colors
          primaryColor: '#1890ff',
        },
      },
    ],
    [
      "classic",
      ({
        docs: {
          sidebarPath: require.resolve("./sidebar.js"),
          sidebarCollapsible: false,
          sidebarCollapsed: false,
          routeBasePath: "/",
          editUrl: "https://github.com/econia-labs/econia/tree/main/doc/doc-site/",
          breadcrumbs: false,
          showLastUpdateAuthor: false,
          showLastUpdateTime: false,
          remarkPlugins: [math],
          rehypePlugins: [katex],
        },
        blog: false,
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
      }),
    ],
  ],

  markdown: {
    mermaid: true,
  },

  plugins: ["@docusaurus/theme-mermaid"],

  themes: [
    [
      require.resolve("@easyops-cn/docusaurus-search-local"),
      {
        hashed: true,
        docsRouteBasePath: "/",
      },
    ],
  ],

  stylesheets: [
    "https://fonts.googleapis.com/css2?family=Jost:wght@300;400;500;600;700;800&family=Roboto+Mono:wght@300;400;500;600;700&display=swap",
    { // KaTeX, for typesetting equations.
      href: "https://cdn.jsdelivr.net/npm/katex@0.13.24/dist/katex.min.css",
      type: "text/css",
      integrity: "sha384-odtC+0UGzzFL/6PNoE8rX/SPcQDXBJ+uRepguP4QkPCm2LBxH3FA3y+fKSiJ+AmM",
      crossorigin: "anonymous",
    }
  ],

  themeConfig:
    ({
      metadata: [
        { name: "twitter:card", content: "summary" },
        { name: "og:image:width", content: "1200" },
        { name: "og:image:height", content: "630" }
      ],
      image: "img/EconiaPreview.jpeg",
      navbar: {
        logo: {
          alt: "Econia Logo",
          src: "img/EconiaHeader.svg",
          width: "156px",
          height: "24px",
        },
        items: [],
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
      colorMode: {
        defaultMode: "dark",
        disableSwitch: true,
      },
    }),
};