// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:oz-upgrades-from ERC20Token
contract ERC20TokenV2 is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    OwnableUpgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable,
    UUPSUpgradeable
{
    uint public totalSupplyToken;
    uint public perMint;
    uint public price;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _symbol,
        uint _totalSupply,
        uint _perMint,
        uint _price
    ) public initializer {
        require(totalSupply() == 0, "Already initialized");
        __ERC20_init("ERC20Token", _symbol);
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(msg.sender);
        __ERC20Permit_init("ERC20Token");
        __ERC20Votes_init();
        __UUPSUpgradeable_init();

        perMint = _perMint;
        totalSupplyToken = _totalSupply;
        price = _price;
    }

    function mint(address to) public payable {
        uint currentSupply = totalSupply(); // 获取当前代币供应量
        // 确保铸造后总供应量不超过最大供应量
        require(
            currentSupply + perMint <= totalSupplyToken,
            "Exceeds max total supply"
        );
        require(msg.value >= price, "Incorrect payment");
        _mint(to, perMint); // 实际铸造代币
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    )
        internal
        override(
            ERC20Upgradeable,
            ERC20PausableUpgradeable,
            ERC20VotesUpgradeable
        )
    {
        super._update(from, to, value);
    }

    function nonces(
        address owner
    )
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    /**
     * 提取合约中的所有 ETH 到合约拥有者地址
     */
    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
