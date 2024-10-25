// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @custom:security-contact contact@deco31416.com
/// @custom:website www.deco31416.com

contract EarningVault is Ownable, ReentrancyGuard {
    address public supplyManager;
    address public governance;
    address public APIHandler;

    // Eventos para el depósito y retiro de fees
    event FeeDeposited(address indexed token, uint256 amount);
    event FeeWithdrawn(
        address indexed token,
        uint256 amount,
        address indexed to
    );

    constructor(
        address _supplyManager,
        address _governance,
        address _APIHandler
    ) Ownable(msg.sender) {
        require(_supplyManager != address(0), "Invalid supplyManager address");
        require(_governance != address(0), "Invalid governance address");
        require(_APIHandler != address(0), "Invalid APIHandler address");

        supplyManager = _supplyManager;
        governance = _governance;
        APIHandler = _APIHandler;
    }

    // Modificador para restringir acceso solo al SupplyManager, Governance, APIHandler o Owner
    modifier onlyMicaProtocole() {
        require(
            msg.sender == supplyManager ||
                msg.sender == governance ||
                msg.sender == APIHandler ||
                msg.sender == owner(),
            "Not authorized"
        );
        _;
    }

    // Modificador para restringir acceso solo al APIHandler
    modifier onlyAPIHandler() {
        require(
            msg.sender == APIHandler,
            "Not authorized: Only APIHandler can access"
        );
        _;
    }

    // Función para verificar y actualizar el balance
    function checkAndUpdateBalance(address token)
        public
        onlyMicaProtocole
        onlyAPIHandler
    {
        uint256 newBalance = IERC20(token).balanceOf(address(this));
        emit FeeDeposited(token, newBalance);
    }

    // Función para depositar fees en la bóveda
    function depositFee(address token, uint256 amount)
        external
        nonReentrant
        onlyMicaProtocole
    {
        require(amount > 0, "Amount must be greater than 0");
        require(token != address(0), "Invalid token address");

        // Transferir los tokens a este contrato
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Emitir evento de depósito
        emit FeeDeposited(token, amount);
    }

    // Función para retirar fees de la bóveda
    function withdrawFee(
        address token,
        uint256 amount,
        address to
    ) external nonReentrant onlyMicaProtocole {
        require(amount > 0, "Amount must be greater than 0");
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");

        // Verificar el balance del contrato
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient balance");

        // Transferir los tokens al destinatario
        IERC20(token).transfer(to, amount);

        // Emitir evento de retiro
        emit FeeWithdrawn(token, amount, to);
    }

    // Función pública para consultar el balance de tokens admitidos en la bóveda
    function balanceOf(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    // Función de emergencia para que el propietario retire los tokens si es necesario
    function emergencyWithdraw(address token, uint256 amount)
        external
        onlyOwner
        nonReentrant
    {
        require(amount > 0, "Amount must be greater than 0");
        IERC20(token).transfer(owner(), amount);
    }
}
