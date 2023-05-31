/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  async redirects() {
    return [
      {
        source: "/",
        destination: "/trade",
        permanent: false,
      },
      // TODO: Enable swap
      {
        source: "/swap",
        destination: process.env.NODE_ENV === "production" ? "/404" : "/swap",
        permanent: false,
      },
    ];
  },
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "raw.githubusercontent.com",
      },
    ],
  },
};

module.exports = nextConfig;
