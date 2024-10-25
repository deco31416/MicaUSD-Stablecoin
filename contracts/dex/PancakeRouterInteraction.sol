// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract PancakeRouterInteraction is Ownable, ReentrancyGuard {
    address public immutable WETH; // Dirección de WETH en la BSC
    address public router; // Dirección del router de PancakeSwap
    address public factory; // Dirección de la fábrica de PancakeSwap

    event LiquidityAdded(
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
    event LiquidityRemoved(
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB
    );
    event TokensSwapped(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    constructor(address _router, address _WETH, address _factory) Ownable(msg.sender) {
        require(_router != address(0), "Invalid router address");
        require(_WETH != address(0), "Invalid WETH address");
        require(_factory != address(0), "Invalid factory address");

        router = _router;
        WETH = _WETH;
        factory = _factory;
    }

    // Función para añadir liquidez a PancakeSwap
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external nonReentrant returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

        IERC20(tokenA).approve(router, amountADesired);
        IERC20(tokenB).approve(router, amountBDesired);

        (amountA, amountB, liquidity) = IUniswapV2Router02(router).addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            deadline
        );

        emit LiquidityAdded(tokenA, tokenB, amountA, amountB, liquidity);
    }

    // Función para remover liquidez de PancakeSwap
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external nonReentrant returns (uint256 amountA, uint256 amountB) {
        IERC20 liquidityToken = IERC20(IUniswapV2Factory(factory).getPair(tokenA, tokenB));
        liquidityToken.transferFrom(msg.sender, address(this), liquidity);
        liquidityToken.approve(router, liquidity);

        (amountA, amountB) = IUniswapV2Router02(router).removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );

        emit LiquidityRemoved(tokenA, tokenB, amountA, amountB);
    }

    // Función para intercambiar tokens en PancakeSwap
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external nonReentrant returns (uint256[] memory amounts) {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).approve(router, amountIn);

        amounts = IUniswapV2Router02(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );

        emit TokensSwapped(path[0], path[path.length - 1], amountIn, amounts[amounts.length - 1]);
    }

    // Función para intercambiar tokens por ETH
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external nonReentrant returns (uint256[] memory amounts) {
        require(path[path.length - 1] == WETH, "Path must end with WETH");

        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).approve(router, amountIn);

        amounts = IUniswapV2Router02(router).swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );

        emit TokensSwapped(path[0], WETH, amountIn, amounts[amounts.length - 1]);
    }

    // Función para actualizar la dirección del router de PancakeSwap
    function updateRouter(address _router) external onlyOwner {
        require(_router != address(0), "Invalid router address");
        router = _router;
    }

    // Función para retirar tokens de emergencia
    function emergencyWithdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }

    // Función para recibir ETH
    receive() external payable {}
}
