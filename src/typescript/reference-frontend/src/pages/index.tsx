import { Jost } from "next/font/google";
import Image from "next/image";

const jost = Jost({ subsets: ["latin"] });

export default function Home() {
  return (
    <main className={`h-screen bg-black ${jost.className}`}>
      <Image
        className="relative"
        alt="Econia Logo"
        src="/econia.svg"
        width={156}
        height={25}
        priority
      />
    </main>
  );
}
