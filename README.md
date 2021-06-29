# marketplace-contracts

## TODO List

- use waffle `changeTokenBalance` to check cash balance change

## Notice

- payment(from, to, amount, burnRate, feeRate):
    - balanceBefore = RPC.balanceOf(RPCRouter);
    - RPC.spend(from, RPCRouter, amount, burnRate);
    - balanceAfter = RPC.balanceOf(RPCRouter);
    - routerReceived = balanceAfter - balanceBefore;
    - applicationFee = routerReceived * feeRate;
    - RPC.transfer(to, routerReceived - applicationFee);