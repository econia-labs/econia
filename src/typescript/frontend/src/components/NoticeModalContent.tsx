// type NoticeModalContentProps = {};

export const NoticeModalContent: React.FC = () => {
  return (
    <div className="flex w-full flex-col items-center gap-6 py-8">
      <p className="font-jost text-3xl font-bold text-white">Notice</p>
      <p className="">
        This is a testnet interface. All coins are used for testing purposes and
        have no real value. If you are connecting a wallet, make sure it is
        connected to Aptos testnet.
      </p>
    </div>
  );
};
