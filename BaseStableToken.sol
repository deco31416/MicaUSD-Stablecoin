// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MICAUSDT is ERC20, Ownable, ReentrancyGuard, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => bool) private blacklist;
    mapping(address => bool) private whitelist;

    uint256 private totalBurned;
    uint256 private totalMinted;
    uint256 private totalBlacklisted;
    uint256 private totalWhitelisted;

    address private walletSupplyCustodian;
    address private supplyCustodian;

    event Blacklisted(address indexed account);
    event Whitelisted(address indexed account);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    constructor(address _walletSupplyCustodian, uint256 _initialSupply)
        ERC20("MICAUSDT", "MICAUSD-T")
        Ownable(msg.sender)
    {
        _mint(_walletSupplyCustodian, _initialSupply * 10**uint256(decimals()));
        walletSupplyCustodian = _walletSupplyCustodian;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == walletSupplyCustodian ||
                msg.sender == owner() ||
                msg.sender == supplyCustodian,
            "Not admin or owner"
        );
        _;
    }

    function setWalletSupplyCustodian(address newWalletsupplyCustodian)
        public
        onlyOwner
    {
        walletSupplyCustodian = newWalletsupplyCustodian;
    }

    function setSupplyCustodian(address newSupplyCustodian) public onlyOwner {
        supplyCustodian = newSupplyCustodian;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function isPaused() public view returns (bool) {
        return paused();
    }

    function addToBlacklist(address account) public onlyOwner {
        require(!blacklist[account], "Address is already blacklisted");

        if (whitelist[account]) {
            whitelist[account] = false;
            totalWhitelisted--;
            emit Whitelisted(account);
        }
        blacklist[account] = true;
        totalBlacklisted++;
        emit Blacklisted(account);
    }

    function removeFromBlacklist(address account) public onlyOwner {
        require(blacklist[account], "Address is not blacklisted");
        blacklist[account] = false;
        totalBlacklisted--;
        whitelist[account] = true;
        totalWhitelisted++;
        emit Whitelisted(account);
    }

    function addToWhitelist(address account) public onlyOwner {
        require(!whitelist[account], "Address is already whitelisted");

        if (blacklist[account]) {
            blacklist[account] = false;
            totalBlacklisted--;
            emit Blacklisted(account);
        }

        whitelist[account] = true;
        totalWhitelisted++;
        emit Whitelisted(account);
    }

    function removeFromWhitelist(address account) public onlyOwner {
        require(whitelist[account], "Address is not whitelisted");
        whitelist[account] = false;
        totalWhitelisted--;
        blacklist[account] = true;
        totalBlacklisted++;
        emit Blacklisted(account);
    }

    function MintSupply(address to, uint256 amount)
        public
        onlyOwner
        nonReentrant
        whenNotPaused
    {
        require(!blacklist[to], "Cannot mint to blacklisted address");
        _mint(to, amount);
        totalMinted += amount;
        emit TokensMinted(to, amount);
    }

    function BurnSupply(uint256 amount) public nonReentrant whenNotPaused {
        require(!blacklist[msg.sender], "Cannot burn from blacklisted address");
        _burn(msg.sender, amount);
        totalBurned += amount;
        emit TokensBurned(msg.sender, amount);
    }

    function CustodianMint(address to, uint256 amount)
        external
        onlyAdmin
        nonReentrant
        whenNotPaused
    {
        _mint(to, amount);
        totalMinted += amount;
        emit TokensMinted(to, amount);
    }

    function CustodianBurn(address from, uint256 amount)
        external
        onlyAdmin
        nonReentrant
        whenNotPaused
    {
        _burn(from, amount);
        totalBurned += amount;
        emit TokensBurned(from, amount);
    }

    function totalMintedTokensUser() public view returns (uint256) {
        return totalMinted;
    }

    function totalBurnedTokens() public view returns (uint256) {
        return totalBurned;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return blacklist[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(
            !blacklist[msg.sender] && !blacklist[recipient],
            "Token transfer blocked"
        );
        return super.transfer(recipient, amount);
    }

    function WalletInBlacklisted() public view returns (uint256) {
        return totalBlacklisted;
    }

    function WalletInWhitelist() public view returns (uint256) {
        return totalWhitelisted;
    }

    function withdrawTokenToOwner(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "There are no tokens to withdraw");
        token.transfer(owner(), balance);
    }
}
