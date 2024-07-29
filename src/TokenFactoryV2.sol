// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
// import "@optionality.io/clone-factory/contracts/CloneFactory.sol";
import "./ERC20Token.sol";

/// @custom:oz-upgrades-from TokenFactoryV1
contract TokenFactoryV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    address myToken;
    ERC1967Proxy proxy;
    address[] public deployedTokens;
    mapping(address => uint) public tokenPrices;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function setLibraryAddress(address _libraryAddress) public onlyOwner {
        myToken = _libraryAddress;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    /**
     * 部署新的 ERC20 代币合约
     * @param symbol symbol 表示 Token 的名称
     * @param totalSupply totalSupply 表示可发行的数量
     * @param perMint perMint 用来控制每次发行的数量，用于控制mintInscription函数每次发行的数量
     * @param price 每个代币的价格 price 表示发行每个 token 需要支付的费用
     */
    function deployInscription(
        string memory symbol,
        uint totalSupply,
        uint perMint,
        uint price
    ) public {
        // require(
        //     implementation != address(0),
        //     "Implementation address is not set"
        // );

        // 部署实现
        // ERC20Token implementation = new ERC20Token();

        console.log("deployInscription  msg.sender, address:", msg.sender);
        // 使用 Clones 库创建最小代理合约实例
        // address proxyInstance = Clones.clone(address(implementation));
        address newToken = Clones.clone(myToken);
        // address proxyInstance = createClone(implementation);

        ERC20Token(newToken).initialize(
            msg.sender,
            symbol,
            totalSupply,
            perMint
        );

        deployedTokens.push(newToken);
        tokenPrices[newToken] = price;
    }

    /**
     * 铸造 ERC20 代币
     * @param tokenAddr 代币地址
     */
    function mintInscription(address tokenAddr) public payable {
        ERC20Token token = ERC20Token(tokenAddr);
        uint price = tokenPrices[tokenAddr];
        require(msg.value >= price, "Incorrect payment");
        token.mint(msg.sender);
        // 将支付的以太币转账到合约所有者
        payable(owner()).transfer(msg.value);
    }

    /**
     * 提取合约余额
     */
    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }

    function size() public view returns (uint) {
        return deployedTokens.length;
    }
}
