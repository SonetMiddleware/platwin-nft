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
  PlatwinMEME2: '0x1563c7ea32c7900361d69d4a16b24f143689Ba99',
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

### Mumbai

```
{
  MockRPC: '0x3F542962fDD28cC9732425896cEedB0FAAF1cd7C',
  RPCRouter: '0xC44738c0918D6F02B50C3E4Dab8bC47b631ed99F',
  PlatwinMEME: '0xA4763C6A86bCC29F0ddaE6a907D1E60C67eF433A',
  PlatwinMEME2: '0xD0f6cfE75CFd0Fe9F771DeEC14F1838e1Fa14179',
  PlatwinBatchMeme: '0x9f55131F6Df3D9856349B57A4aA0Ac31a42490E9',
  Market: '0x14C127843Ab3B2734CeB0D82d1a43ae140A24E40',
  MarketProxy: '0xe0954E88D05C52C0D91d11AD897a1F58DFf93876'
}
```
