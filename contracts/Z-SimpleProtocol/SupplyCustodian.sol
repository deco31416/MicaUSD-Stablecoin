// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SupplyCustodian is Ownable, ReentrancyGuard, Pausable {
    address private tokenContract; // Dirección del contrato del token
    address private admin; // Dirección del administrador

    uint256 public mintingFeePercentage; // Porcentaje de tarifa de acuñación (0-100)
    uint256 public burningFeePercentage; // Porcentaje de tarifa de quema (0-100)

    uint256 public gasPrice = 95; // Precio del gas en wei (0.95 por defecto)
    uint256 public tokenPrice = 1; // Precio del token en wei (1 por defecto)

    event MintingFeeChanged(uint256 newFeePercentage);
    event BurningFeeChanged(uint256 newFeePercentage);

    constructor(address _tokenContract, address _admin)
        Ownable(msg.sender) // Pasar msg.sender como propietario inicial
    {
        require(_admin != address(0), "Invalid admin address");
        tokenContract = _tokenContract;
        admin = _admin;
        mintingFeePercentage = 1; // Por defecto, tarifa de acuñación del 1%
        burningFeePercentage = 1; // Por defecto, tarifa de quema del 1%
    }

    modifier onlyAdminOrOwner() {
        require(msg.sender == admin || msg.sender == owner(), "Not authorized");
        _;
    }

    function setAdmin(address _newAdmin) external onlyOwner {
        require(_newAdmin != address(0), "Invalid admin address");
        admin = _newAdmin;
    }

    function setTokenContract(address _tokenContract) external onlyOwner {
        tokenContract = _tokenContract;
    }

    function setMintingFeePercentage(uint256 _feePercentage)
        external
        onlyOwner
    {
        require(_feePercentage <= 100, "Fee percentage must be <= 100");
        mintingFeePercentage = _feePercentage;
        emit MintingFeeChanged(_feePercentage);
    }

    function setBurningFeePercentage(uint256 _feePercentage)
        external
        onlyOwner
    {
        require(_feePercentage <= 100, "Fee percentage must be <= 100");
        burningFeePercentage = _feePercentage;
        emit BurningFeeChanged(_feePercentage);
    }

    function setGasPrice(uint256 _gasPrice) external onlyOwner {
        gasPrice = _gasPrice;
    }

    function setTokenPrice(uint256 _tokenPrice) external onlyOwner {
        tokenPrice = _tokenPrice;
    }

    function mintTokens(address to, uint256 amount)
        external
        nonReentrant
        whenNotPaused
    {
        require(amount > 0, "Amount must be greater than 0");

        // Calcular la tarifa de acuñación en función del precio actual del gas y del token
        uint256 mintingFee = (amount * mintingFeePercentage * gasPrice) /
            (100 * tokenPrice);
        uint256 finalAmount = amount - mintingFee;

        // Transferir tokens desde el contrato de la billetera de suministro al contrato del token
        IERC20(tokenContract).transferFrom(owner(), address(this), mintingFee);
        IERC20(tokenContract).transfer(to, finalAmount);
    }

    function burnTokens(address from, uint256 amount)
        external
        nonReentrant
        whenNotPaused
    {
        require(amount > 0, "Amount must be greater than 0");

        // Calcular la tarifa de quema en función del precio actual del gas y del token
        uint256 burningFee = (amount * burningFeePercentage * gasPrice) /
            (100 * tokenPrice);

        // Transferir tokens desde la cuenta del usuario al contrato del token como tarifa de quema
        IERC20(tokenContract).transferFrom(from, address(this), amount);

        // Transferir la cantidad equivalente en gas desde el contrato al usuario
        (bool success, ) = msg.sender.call{value: burningFee}("");
        require(success, "Transfer of gas failed");
    }

    // Funciones de pausa
    function pause() public onlyAdminOrOwner {
        _pause();
    }

    // Funciones de UnPause
    function unpause() public onlyAdminOrOwner {
        _unpause();
    }

    function withdrawAllGas() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "There is no gas balance to withdraw");

        (bool success, ) = msg.sender.call{value: contractBalance}("");
        require(success, "Withdrawal failed");
    }

    function withdrawAllETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "There is no gas balance to withdraw");
        payable(owner()).transfer(balance);
    }

    function withdrawTokenToOwner(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "There are no tokens to withdraw");
        token.transfer(owner(), balance);
    }
}
