# marketplace-contracts

## Notice

- payment(from, to, amount, burnRate, feeRate):
    - balanceBefore = RPC.balanceOf(RPCRouter);
    - RPC.spend(from, RPCRouter, amount, burnRate);
    - balanceAfter = RPC.balanceOf(RPCRouter);
    - routerReceived = balanceAfter - balanceBefore;
    - applicationFee = routerReceived * feeRate;
    - RPC.transfer(to, routerReceived - applicationFee);

## deployments

### Mumbai

```
{
  MockRPC: '0x6a3Db86Aca0758f549106A68C1dcb7B090c7D645',
  RPCRouter: '0x804200939BfD6a510a9D40Fac4Ab64f59c7240fe',
  PlatwinMEME: '0xf155D842Eb243b9e1835a9D69941Ad8ED4E6B57A',
  PlatwinMEME2: '0x02c870254F8c803302bb093D7EE88263EcdC41fB',
  PlatwinBatchMeme: '0x478BC4C1876Cb0923F3Fe2d5e999F8C00e8Ddba1',
  Market: '0x7819d3afcA81A18cE5c8372451E5a85b741b6776',
  MarketProxy: '0x42D1Fb433ADB40EbAd5b1300E0D5BB6Ca1bb6697'
}
```
