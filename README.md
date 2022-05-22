# marketplace-contracts

## Notice

- paymentWithRPC(from, to, amount, burnRate, feeRate):
    - balanceBefore = RPC.balanceOf(RPCRouter);
    - RPC.spend(from, RPCRouter, amount, burnRate);
    - balanceAfter = RPC.balanceOf(RPCRouter);
    - routerReceived = balanceAfter - balanceBefore;
    - applicationFee = routerReceived * feeRate;
    - RPC.transfer(to, routerReceived - applicationFee);

## deployments

### rinkeby

```
{
  PlatwinMEMEWithMetaData: '0x4b2b1f6f2accf4bcdd53fc65e1e4a4ef2b289399',
  TestERC20: '0x37e8a25c96c05243007b1f3124c7bb65cf48852c',
  DealRouter: '0xf7C44f215F85453D888A069a1c543D7c488606B6',
  MarketWithoutRPC: '0x1443D92E71eFADE956Aa0198F7EC5eeb6d5f2E0F',
  MarketProxyWithoutRPC: '0x7eBADFBe8679f63313080f36460369714106F834',
  PlatwinMEME2WithoutRPC: '0x12DafDC77B0c754481395783Fa2e59024e92C2eF'
  DAORegistry: '0x6CEc4160f0Bf0Be55b9AB4Ba48fe019019Df9C48'
}
```

## TODO
