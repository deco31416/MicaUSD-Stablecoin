// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @custom:security-contact contacta@deco31416.com
/// @custom:website www.deco31416.com

contract TreasuryVault is Ownable, ReentrancyGuard {
    address public supplyManager;
    address public governance;
    address public APIHandler;

    // Mapeo para almacenar los balances de tokens admitidos por cada usuario
    mapping(address => mapping(address => uint256)) public tokenBalances;

    // Eventos para depositar y retirar tokens
    event TokenBalanceUpdated(address indexed token, uint256 newBalance);
    event TokenDeposited(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event TokenWithdrawn(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    constructor(
        address _supplyManager,
        address _governance,
        address _APIHandler
    ) Ownable(msg.sender) {
        require(_supplyManager != address(0), "Invalid supply manager address");
        require(_governance != address(0), "Invalid governance address");
        require(_APIHandler != address(0), "Invalid APIHandler address");
        supplyManager = _supplyManager;
        governance = _governance;
        APIHandler = _APIHandler;
        transferOwnership(msg.sender);
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
        emit TokenBalanceUpdated(token, newBalance);
    }

    // Función para que SupplyManager deposite tokens admitidos en la bóveda
    function deposit(address token, uint256 amount)
        external
        nonReentrant
        onlyMicaProtocole
    {
        require(amount > 0, "Amount must be greater than 0");
        require(token != address(0), "Invalid token address");

        // Transferir los tokens admitidos desde SupplyManager a este contrato
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Actualizar el balance del SupplyManager
        tokenBalances[token][msg.sender] += amount;

        emit TokenDeposited(msg.sender, token, amount);
    }

    // Función para que SupplyManager retire tokens admitidos y los transfiera al usuario
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external nonReentrant onlyMicaProtocole {
        require(amount > 0, "Amount must be greater than 0");
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");

        // Asegurarse de que el contrato tenga suficientes tokens para el retiro
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient balance in treasury");

        // Transferir los tokens al usuario
        IERC20(token).transfer(to, amount);

        emit TokenWithdrawn(to, token, amount);
    }

    // Función pública para consultar el balance de tokens admitidos en la bóveda
    function balanceOf(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    // Función de emergencia para que el propietario retire tokens si es necesario
    function emergencyWithdraw(address token, uint256 amount)
        external
        onlyOwner
        nonReentrant
    {
        require(amount > 0, "Amount must be greater than 0");

        // Transferir tokens desde el contrato al propietario
        IERC20(token).transfer(owner(), amount);
    }
}
