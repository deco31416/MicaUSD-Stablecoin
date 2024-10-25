// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Governance is Ownable, ReentrancyGuard {
    address public earningVault;
    address public treasuryVault;
    address public supplyManager;
    address public APIHandlerFiat;

    // Eventos para cuando se actualicen las direcciones de los contratos
    event VaultsUpdated(address indexed earningVault, address indexed treasuryVault);
    event SupplyManagerUpdated(address indexed supplyManager);
    event APIHandlerFiatUpdated(address indexed APIHandlerFiat);

    // Constructor para inicializar el contrato de gobernanza
    constructor(
        address _earningVault,
        address _treasuryVault,
        address _supplyManager,
        address _APIHandlerFiat,
        address initialOwner  // Aquí agregamos el propietario inicial
    ) Ownable(initialOwner) { // Pasamos el propietario inicial al constructor de Ownable
        require(_earningVault != address(0), "Invalid EarningVault address");
        require(_treasuryVault != address(0), "Invalid TreasuryVault address");
        require(_supplyManager != address(0), "Invalid SupplyManager address");
        require(_APIHandlerFiat != address(0), "Invalid APIHandlerFiat address");

        earningVault = _earningVault;
        treasuryVault = _treasuryVault;
        supplyManager = _supplyManager;
        APIHandlerFiat = _APIHandlerFiat;
    }

    // Modificador para restringir ciertas acciones a la gobernanza
    modifier onlyGovernance() {
        require(msg.sender == owner(), "Not authorized: Only governance can execute");
        _;
    }

    // Función para actualizar las direcciones de los vaults
    function updateVaults(address _earningVault, address _treasuryVault) external onlyGovernance {
        require(_earningVault != address(0), "Invalid EarningVault address");
        require(_treasuryVault != address(0), "Invalid TreasuryVault address");

        earningVault = _earningVault;
        treasuryVault = _treasuryVault;
        emit VaultsUpdated(_earningVault, _treasuryVault);
    }

    // Función para actualizar la dirección del SupplyManager
    function updateSupplyManager(address _supplyManager) external onlyGovernance {
        require(_supplyManager != address(0), "Invalid SupplyManager address");
        supplyManager = _supplyManager;
        emit SupplyManagerUpdated(_supplyManager);
    }

    // Función para actualizar la dirección del APIHandlerFiat
    function updateAPIHandlerFiat(address _APIHandlerFiat) external onlyGovernance {
        require(_APIHandlerFiat != address(0), "Invalid APIHandlerFiat address");
        APIHandlerFiat = _APIHandlerFiat;
        emit APIHandlerFiatUpdated(_APIHandlerFiat);
    }

    // Función para pausar cualquier contrato que esté bajo el control de la gobernanza
    function pauseContract(address contractAddress) external onlyGovernance {
        IPausableContract(contractAddress).pause();
    }

    // Función para despausar cualquier contrato que esté bajo el control de la gobernanza
    function unpauseContract(address contractAddress) external onlyGovernance {
        IPausableContract(contractAddress).unpause();
    }
}

interface IPausableContract {
    function pause() external;
    function unpause() external;
}
