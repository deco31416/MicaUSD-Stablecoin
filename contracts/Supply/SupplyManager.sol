// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact contacta@deco31416.com
/// @custom:website www.deco31416.com

contract SupplyManager is Ownable, ReentrancyGuard, Pausable {
    address private governance; 
    address public micaToken; 
    address public treasuryVault; 
    address public earningVault; 

    uint256 public mintingFeePercentage; // Porcentaje de tarifa de acuñación (0-100)
    uint256 public burningFeePercentage; // Porcentaje de tarifa de quema (0-100)

    // Lista de tokens admitidos
    mapping(address => bool) public allowedTokens; 

    event TokenAdded(address token);
    event TokenRemoved(address token);
    event MintingFeeChanged(uint256 newFeePercentage);
    event BurningFeeChanged(uint256 newFeePercentage);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    constructor(
        address _micaToken,
        address _governance,
        address _treasuryVault, 
        address _earningVault 
    )
        Ownable(msg.sender) 
    {
        require(_governance != address(0), "Invalid governance address");
        require(_micaToken != address(0), "Invalid MICA token address");
        require(_treasuryVault != address(0), "Invalid treasuryVault address");
        require(_earningVault != address(0), "Invalid earningVault address");

        micaToken = _micaToken;
        governance = _governance;
        treasuryVault = _treasuryVault;
        earningVault = _earningVault;

        mintingFeePercentage = 1; // Por defecto, tarifa de acuñación del 1%
        burningFeePercentage = 1; // Por defecto, tarifa de quema del 1%
    }

    // Modificador para limitar el acceso a funciones solo al SupplyManager o propietario
    modifier onlyMicaProtocole() {
        require(
            msg.sender == owner() || msg.sender == governance,
            "Not Owner or Governance"
        );
        _;
    }

    // Función para acuñar tokens MICA cuando se depositan tokens admitidos
    function mintMica(address token, uint256 amount)
        external
        nonReentrant
        whenNotPaused
    {
        require(allowedTokens[token], "Token not allowed");
        require(amount > 0, "Amount must be greater than 0");

        require(
            treasuryVault != address(0),
            "TreasuryVault address is not set"
        );
        require(earningVault != address(0), "EarningVault address is not set");

        // Calcular la tarifa de acuñación (en porcentaje)
        uint256 mintingFee = (amount * mintingFeePercentage) / 100;
        uint256 finalAmount = amount - mintingFee;

        // Transferir los tokens admitidos al treasuryVault (bóveda de reservas de liquidez)
        require(
            IERC20(token).transferFrom(msg.sender, treasuryVault, finalAmount),
            "Transfer to treasuryVault failed"
        );

        // Transferir la tarifa de acuñación a EarningVault (bóveda de ganancias de acuñamiento)
        require(
            IERC20(token).transferFrom(msg.sender, earningVault, mintingFee),
            "Transfer to earningVault failed"
        );

        // Llamar al contrato MICA para acuñar tokens MICA y transferirlos al usuario
        MICAUSDT(micaToken).SupplyManagerMint(msg.sender, finalAmount);

        // Emitir evento para notificar al usuario que se han acuñado tokens MICA
        emit TokensMinted(msg.sender, finalAmount);
    }

    // Función interna para verificar si TreasuryVault tiene suficientes tokens admitidos
    function _validateTreasuryBalance(address token, uint256 requiredAmount)
        internal
        view
    {
        uint256 treasuryBalance = ITreasuryVault(treasuryVault).balanceOf(
            token
        );
        require(
            treasuryBalance >= requiredAmount,
            "Insufficient tokens in treasuryVault"
        );
    }

    function burnMica(address token, uint256 micaAmount)
        external
        nonReentrant
        whenNotPaused
    {
        require(allowedTokens[token], "Token not allowed");
        require(micaAmount > 0, "Amount must be greater than 0");

        require(
            treasuryVault != address(0),
            "TreasuryVault address is not set"
        );
        require(earningVault != address(0), "EarningVault address is not set");

        // Verificar si TreasuryVault tiene suficientes tokens admitidos
        _validateTreasuryBalance(token, micaAmount);

        // Transferir los tokens MICA desde el usuario al contrato
        require(
            IERC20(micaToken).transferFrom(
                msg.sender,
                address(this),
                micaAmount
            ),
            "Transfer of MICA failed"
        );

        // Llamar al contrato MICA para quemar los tokens MICA
        MICAUSDT(micaToken).SupplyManagerBurn(address(this), micaAmount);

        // Calcular la tarifa de quema aplicada sobre los tokens admitidos que se van a devolver
        uint256 burningFee = (micaAmount * burningFeePercentage) / 100;
        uint256 finalAmount = micaAmount - burningFee;

        // Transferir la tarifa de quema a EarningVault (dirección)
        require(
            IERC20(token).transfer(earningVault, burningFee),
            "Transfer of burning fee to earningVault failed"
        );

        // Transferir los tokens admitidos restantes desde TreasuryVault al usuario
        ITreasuryVault(treasuryVault).withdraw(token, msg.sender, finalAmount);

        // Emitir evento para notificar al usuario que se han quemado los tokens MICA
        emit TokensBurned(token, micaAmount);
    }

    // Funciones de pausa y reactivación
    function pause() public onlyMicaProtocole {
        _pause();
    }

    function unpause() public onlyMicaProtocole {
        _unpause();
    }

    function withdrawToken(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token balance to withdraw");
        token.transfer(owner(), balance);
    }
}

interface MICAUSDT {
    function SupplyManagerMint(address to, uint256 amount) external;

    function SupplyManagerBurn(address from, uint256 amount) external;
}

interface ITreasuryVault {
    // Función que devuelve el balance de tokens en TreasuryVault
    function balanceOf(address token) external view returns (uint256);

    // Función para retirar tokens del TreasuryVault
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external;
}
