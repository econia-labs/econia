aptos move run \
  --function-id 0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_coin::initialize \
  --type-args 0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_usdc::TestUSDCoin \
  --args string:TestUSDCoin string:tUSDC u8:6 bool:false \
  --assume-yes

aptos move run \
  --function-id 0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_coin::initialize \
  --type-args 0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_eth::TestETHCoin \
  --args string:TestETHCoin string:tETH u8:8 bool:false \
  --assume-yes