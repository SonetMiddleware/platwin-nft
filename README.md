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
  MockRPC: '0x75AD3a3D1a30af7Adf9D0ee8691F58D8B1f279b9',
  RPCRouter: '0x387077894f15070133177faD92Fb836fc5B52D1C',
  PlatwinMEME: '0xadDCa5C98b0fB6F8F9b4324D9f97F9Da55cbc3B2',
  PlatwinMEME2: '0x917be393EeF337f280eF2000430F16c1340CAcAd',
  PlatwinBatchMeme: '0x7c19f2eb9e4524D5Ef5114Eb646583bB0Bb6C8F8',
  Market: '0x0F81a06bc1d22F6807501E78808E26eF6B9bd7Bc',
  MarketProxy: '0x0b9fE698176eE725CcaD7d2dbD9F71d977284476'
}
```
