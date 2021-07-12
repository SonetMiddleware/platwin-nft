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

### Ropsten

```
{
  MockRPC: '0xd2b529322505D4C7Fe14F804d99Ad96a0A064E59',
  RPCRouter: '0x16705E8170465ab0326cA934C585cA74F022a009',
  PlatwinMEME: '0x78E71132Da284CCe8c9dd08d137f451c190AB2B5',
  PlatwinBatchMeme: '0x0344255dd53675C41D24A0B5F4dd4CB4177EAb02',
  Market: '0xe9c804392e32fe2c72D70AB510B72Ff3a8124E77',
  MarketProxy: '0x5cb1468324F2F90c60aA1a6a0725Dbd70a8270a5'
}
```

### BSC Testnet

```
{
  MockRPC: '0xe0954E88D05C52C0D91d11AD897a1F58DFf93876',
  RPCRouter: '0xd2b529322505D4C7Fe14F804d99Ad96a0A064E59',
  PlatwinMEME: '0x16705E8170465ab0326cA934C585cA74F022a009',
  PlatwinMEME2: '0x78E71132Da284CCe8c9dd08d137f451c190AB2B5',
  PlatwinBatchMeme: '0x0344255dd53675C41D24A0B5F4dd4CB4177EAb02',
  Market: '0xe9c804392e32fe2c72D70AB510B72Ff3a8124E77',
  MarketProxy: '0x0042E4e79F0f0a2Ab1B641A0D3A09a6562B33836'
}
```
