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
  MockRPC: '0xB85d419189279edD1b83451130FFa8de635A5390',
  RPCRouter: '0x8382CF93dEbe0AA5cDE3358ECE074422Ab7D34C1',
  PlatwinMEME: '0x5c5F28A854757a87546320f15878a386aC0C3545',
  PlatwinMEME2: '0x14A6393F14D1CafBc7CbAe132C78b9C4736dd306',
  PlatwinBatchMeme: '0x37d8C9D867C5AD117f5bD18e8aE67Ea392F0ec88',
  Market: '0x45fA5251d4b2736953e6af7A222216d02B006399',
  MarketProxy: '0x980e575cE9C2a0A3Bd088e34c89d5E70a9Fab129'
}
```
