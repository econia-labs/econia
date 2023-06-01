import Image, { type ImageProps } from "next/image";
import { useEffect, useState } from "react";

// copy paste from statsbar, think about making a unified component later
const DEFAULT_TOKEN_ICON = "/tokenImages/default.png";
type MarketIconPairProps = {
  baseAssetIcon?: string;
  quoteAssetIcon?: string;
};
export const MarketIconPair = ({
  baseAssetIcon = DEFAULT_TOKEN_ICON,
  quoteAssetIcon = DEFAULT_TOKEN_ICON,
}: MarketIconPairProps) => {
  interface ImageWithFallbackProps extends ImageProps {
    fallback?: string;
    alt: string;
    src: string;
    // [key: string]: any; // allow any other props
  }

  const ImageWithFallback: React.FC<ImageWithFallbackProps> = ({
    fallback = "/tokenImages/default.png",
    alt,
    src,
    ...props
  }) => {
    const [error, setError] = useState<Error | null>(null);

    useEffect(() => {
      setError(null);
    }, [src]);

    return (
      <Image
        alt={alt}
        onError={() => setError(new Error("Failed to load image"))}
        src={error ? fallback : src}
        {...props}
      />
    );
  };

  return (
    <div className="relative flex">
      {/* height width props required */}
      <ImageWithFallback
        src={baseAssetIcon}
        alt="market-icon-pair"
        width={40}
        height={40}
        className="z-20 aspect-square  w-[30px] min-w-[30px] md:min-w-[40px]"
      ></ImageWithFallback>
      <ImageWithFallback
        src={quoteAssetIcon}
        alt="market-icon-pair"
        width={40}
        height={40}
        className="absolute z-10 aspect-square w-[30px] min-w-[30px] translate-x-1/2 md:min-w-[40px]"
      ></ImageWithFallback>
    </div>
  );
};
