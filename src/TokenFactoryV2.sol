// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "./ERC20Token.sol";
import "./ERC20TokenV2.sol";

contract TokenFactoryV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    ERC20Token myToken;
    ERC1967Proxy proxy;
    address[] public deployedTokens;
    address public implementation;
    mapping(address => uint) public tokenPrices;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address initialOwner,
        address _implementation
    ) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        require(
            _implementation != address(0),
            "Invalid implementation address"
        );

        implementation = _implementation;
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
    ) public onlyOwner {
        console.log("deployInscription  msg.sender, address:", msg.sender);
        // 使用 Clones 库创建最小代理合约实例
        address proxyInstance = Clones.clone(implementation);
        ERC20TokenV2(proxyInstance).initialize(
            msg.sender,
            symbol,
            totalSupply,
            perMint,
            price
        );

        deployedTokens.push(proxyInstance);
        tokenPrices[proxyInstance] = price;
    }

    /**
     * 铸造 ERC20 代币
     * @param tokenAddr 代币地址
     */
    function mintInscription(address tokenAddr) public payable {
        ERC20TokenV2 token = ERC20TokenV2(tokenAddr);
        uint price = tokenPrices[tokenAddr];
        require(msg.value == price, "Incorrect payment");
        token.mint(msg.sender);
    }

    function size() public view returns (uint) {
        return deployedTokens.length;
    }
}
