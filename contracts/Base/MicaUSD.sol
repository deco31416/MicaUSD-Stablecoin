// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @custom:security-contact contacta@deco31416.com
/// @custom:website www.deco31416.com

contract MicaUSD is ERC20, Ownable, ReentrancyGuard, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /// Mappings para listas negra y blanca
    mapping(address => bool) public blacklist;
    mapping(address => bool) public whitelist;

    // Variables para seguimiento del total acuñado, quemado, en blacklist y whitelist
    uint256 public totalBurned;
    uint256 public totalMinted;

    uint256 public totalMintedByOwner;
    uint256 public totalBurnedByOwner;

    uint256 public totalMintedBySupplyManager;
    uint256 public totalBurnedBySupplyManager;

    uint256 public totalBlacklisted;
    uint256 public totalWhitelisted;

    // Dirección clave del SupplyManager
    address public SupplyManager; // Dirección del SupplyManager

    // Eventos
    event ContractPaused(address account);
    event ContractUnpaused(address account);
    event Blacklisted(address indexed account);
    event Whitelisted(address indexed account);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    // Constructor inicializa el suministro inicial y define el SupplyManager
    constructor(address _SupplyManager, uint256 _initialSupply)
        ERC20("MicaUSD-T", "MICA-T")
        Ownable(msg.sender)
    {
        // Acuñar el suministro inicial de tokens y asignarlos al SupplyManager
        _mint(_SupplyManager, _initialSupply * 10**uint256(decimals()));
        SupplyManager = _SupplyManager;
    }

    // Retorna el número de decimales que utiliza el token
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    // Modificador para limitar el acceso a funciones solo al SupplyManager o propietario
    modifier onlyMicaProtocole() {
        require(
            msg.sender == owner() || msg.sender == SupplyManager,
            "Not SupplyManager or Owner"
        );
        _;
    }

    //--------------------------------------------------//
    //           Configuración del Contrato             //
    //--------------------------------------------------//

    // Función para cambiar el SupplyManager
    function setSupplyManager(address newSupplyManager) public onlyOwner {
        SupplyManager = newSupplyManager;
    }

    // Función para pausar el contrato
    function pause() public onlyOwner {
        _pause();
        emit ContractPaused(msg.sender); // Emitir evento cuando el contrato es pausado
    }

    // Función para reactivar el contrato
    function unpause() public onlyOwner {
        _unpause();
        emit ContractUnpaused(msg.sender); // Emitir evento cuando el contrato es reactivado
    }

    // Consulta si el contrato está pausado
    function isPaused() public view returns (bool) {
        return paused();
    }

    //--------------------------------------------------//
    //           Lista Negra y lista Blanca             //
    //--------------------------------------------------//

    // Función para añadir una dirección a la lista negra
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

    // Función para eliminar una dirección de la lista negra
    function removeFromBlacklist(address account) public onlyOwner {
        require(blacklist[account], "Address is not blacklisted");
        blacklist[account] = false;
        totalBlacklisted--;
        whitelist[account] = true;
        totalWhitelisted++;
        emit Whitelisted(account);
    }

    // Función para añadir una dirección a la lista blanca
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

    // Función para eliminar una dirección de la lista blanca
    function removeFromWhitelist(address account) public onlyOwner {
        require(whitelist[account], "Address is not whitelisted");
        whitelist[account] = false;
        totalWhitelisted--;
        blacklist[account] = true;
        totalBlacklisted++;
        emit Blacklisted(account);
    }

    //--------------------------------------------------//
    //      Funcion de transferencia condicionada       //
    //--------------------------------------------------//

    // Sobrescribir la función de transferencia con restricciones de lista negra y pausa
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

    //--------------------------------------------------//
    //    Estadisticas de Lista Negra y lista Blanca    //
    //--------------------------------------------------//

    // Consulta si una cuenta está en la lista negra
    function isBlacklisted(address account) public view returns (bool) {
        return blacklist[account];
    }

    // Consulta el número de direcciones en la lista negra
    function WalletInBlacklisted() public view returns (uint256) {
        return totalBlacklisted;
    }

    // Consulta si una cuenta está en la lista blanca
    function isWhitelisted(address account) public view returns (bool) {
        return whitelist[account];
    }

    // Consulta el número de direcciones en la lista blanca
    function WalletInWhitelist() public view returns (uint256) {
        return totalWhitelisted;
    }

    //--------------------------------------------------//
    //         Funciones de minteo y Quema              //
    //--------------------------------------------------//

    // Función para acuñar tokens para un destinatario (solo dueño)
    function MintSupply(address to, uint256 amount)
        public
        onlyOwner
        nonReentrant
        whenNotPaused
    {
        require(!blacklist[to], "Cannot mint to blacklisted address");
        _mint(to, amount);
        totalMinted += amount;
        totalMintedByOwner += amount;
        emit TokensMinted(to, amount);
    }

    // Función para quemar tokens del remitente (solo el dueño)
    function BurnSupply(uint256 amount) public nonReentrant whenNotPaused {
        require(!blacklist[msg.sender], "Cannot burn from blacklisted address");
        _burn(msg.sender, amount);
        totalBurned += amount;
        totalBurnedByOwner += amount;
        emit TokensBurned(msg.sender, amount);
    }

    // Función para que el SupplyManager acuñe tokens
    function SupplyManagerMint(address to, uint256 amount)
        external
        onlyMicaProtocole
        nonReentrant
        whenNotPaused
    {
        require(!blacklist[to], "Cannot mint to blacklisted address");
        _mint(to, amount);
        totalMinted += amount;
        totalMintedBySupplyManager += amount;
        emit TokensMinted(to, amount);
    }

    // Función para que el SupplyManager queme tokens
    function SupplyManagerBurn(address from, uint256 amount)
        external
        onlyMicaProtocole
        nonReentrant
        whenNotPaused
    {
        require(!blacklist[from], "Cannot burn from blacklisted address");
        _burn(from, amount);
        totalBurned += amount;
        totalBurnedBySupplyManager += amount;
        emit TokensBurned(from, amount);
    }

    //--------------------------------------------------//
    //         Estaditicas de minteo y Quema            //
    //--------------------------------------------------//

    // Consulta el total de tokens acuñados
    function totalMintedTokensUser() public view returns (uint256) {
        return totalMinted;
    }

    // Consulta el total de tokens quemados
    function totalBurnedTokens() public view returns (uint256) {
        return totalBurned;
    }

    // Consulta el total de tokens acuñados por el propietario
    function totalMintedByOwnerTokens() public view returns (uint256) {
        return totalMintedByOwner;
    }

    // Consulta el total de tokens quemados por el propietario
    function totalBurnedByOwnerTokens() public view returns (uint256) {
        return totalBurnedByOwner;
    }

    // Consulta el total de tokens acuñados por el SupplyManager
    function totalMintedBySupplyManagerTokens() public view returns (uint256) {
        return totalMintedBySupplyManager;
    }

    // Consulta el total de tokens quemados por el SupplyManager
    function totalBurnedBySupplyManagerTokens() public view returns (uint256) {
        return totalBurnedBySupplyManager;
    }

    //--------------------------------------------------//
    //         Gestión de saldos del contrato           //
    //--------------------------------------------------//

    // Función para que el propietario retire tokens del contrato
    function withdrawTokenToOwner(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "There are no tokens to withdraw");
        token.transfer(owner(), balance);
    }
}
