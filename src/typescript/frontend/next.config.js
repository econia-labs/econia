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
    ];
  },
};

module.exports = nextConfig;
