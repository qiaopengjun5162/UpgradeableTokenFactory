# UpgradeableTokenFactory

在以太坊上用ERC20 模拟铭文铸造，创建可升级的工厂合约
⼀个可升级的工厂合约，工厂合约有两个方法：

1. deployInscription(string symbol, uint totalSupply, uint perMint) ，该方法用来创建 ERC20 token，（模拟铭文的 deploy）， symbol 表示 Token 的名称，totalSupply 表示可发行的数量，perMint 用来控制每次发行的数量，用于控制mintInscription函数每次发行的数量
2. mintInscription(address tokenAddr) 用来发行 ERC20 token，每次调用一次，发行perMint指定的数量。
实现说明：
• 合约的第⼀版本用普通的 new 的方式发行 ERC20 token 。
• 第⼆版本，deployInscription 加入一个价格参数 price  deployInscription(string symbol, uint totalSupply, uint perMint, uint price) , price 表示发行每个 token 需要支付的费用，并且 第⼆版本使用最小代理的方式以更节约 gas 的方式来创建 ERC20 token，需要同时修改 mintInscription 的实现以便收取每次发行的费用。
铭文是 BTC 上的 token，它需要先 deploy，然后 mint

## Reference

- [deploying-our-contract](https://book.getfoundry.sh/tutorials/solidity-scripting#deploying-our-contract)
- [ERC-1967: Proxy Storage Slots](https://eips.ethereum.org/EIPS/eip-1967)
- [openzeppelin-contracts-upgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable)
- [openzeppelin.com/contracts](https://www.openzeppelin.com/contracts)
- [OpenZeppelin Upgrades Core & CLI](https://docs.openzeppelin.com/upgrades-plugins/1.x/api-core)
# UpgradeableTokenFactory
