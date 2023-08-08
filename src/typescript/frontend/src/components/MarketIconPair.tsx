import Image, { type ImageProps } from "next/image";

interface ImageWithFallbackProps extends ImageProps {
  fallback?: string;
  alt: string;
  src: string;
  // [key: string]: any; // allow any other props
}

export const ImageWithFallback: React.FC<ImageWithFallbackProps> = ({
  fallback = "/tokenImages/default.png",
  alt,
  src,
  ...props
}) => {
  return <Image alt={alt} src={src ?? fallback} {...props} />;
};

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
  return (
    <div className="md:w-15 relative flex w-12">
      {/* height width props required */}
      <ImageWithFallback
        src={baseAssetIcon}
        alt="market-icon-pair"
        width={28}
        height={28}
        className="z-20 aspect-square w-7"
      ></ImageWithFallback>
      <ImageWithFallback
        src={quoteAssetIcon}
        alt="market-icon-pair"
        width={28}
        height={28}
        className="absolute z-10 aspect-square w-7 translate-x-1/2"
      ></ImageWithFallback>
    </div>
  );
};
