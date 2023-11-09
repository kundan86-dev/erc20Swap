// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ERC20Swap {
    address public token1Address; // Address of the first ERC-20 token
    address public token2Address; // Address of the second ERC-20 token
    uint256 public totalLiquidityToken1; // Total liquidity of token1
    uint256 public totalLiquidityToken2; // Total liquidity of token2

    event SwapInitiated(address indexed user, uint256 amount, address indexed tokenFrom, address indexed tokenTo);

    constructor(address _token1Address, address _token2Address) {
        token1Address = _token1Address;
        token2Address = _token2Address;
    }

    function getExchangeRate() public view returns (uint256) {
        require(totalLiquidityToken1 > 0, "Insufficient liquidity for token1");
        return (totalLiquidityToken2 * 1e18) / totalLiquidityToken1; 
    }

    function addLiquidity(uint256 liquidityToken1, uint256 liquidityToken2) external {
        require(liquidityToken1 > 0 && liquidityToken2 > 0, "Invalid liquidity amounts");

        require(IERC20(token1Address).transferFrom(msg.sender, address(this), liquidityToken1), "Failed to transfer token1");
        require(IERC20(token2Address).transferFrom(msg.sender, address(this), liquidityToken2), "Failed to transfer token2");

        totalLiquidityToken1 += liquidityToken1;
        totalLiquidityToken2 += liquidityToken2;
    }

    function removeLiquidity(uint256 liquidityToken1, uint256 liquidityToken2) external {
        require(liquidityToken1 > 0 && liquidityToken2 > 0, "Invalid liquidity amounts");

        uint256 token1Amount = (liquidityToken1 * totalLiquidityToken1) / totalLiquidityToken2;
        uint256 token2Amount = (liquidityToken2 * totalLiquidityToken2) / totalLiquidityToken1;

        require(IERC20(token1Address).transfer(msg.sender, token1Amount), "Failed to transfer token1");
        require(IERC20(token2Address).transfer(msg.sender, token2Amount), "Failed to transfer token2");

        totalLiquidityToken1 -= liquidityToken1;
        totalLiquidityToken2 -= liquidityToken2;
    }

    function initiateSwap(uint256 amount) external {
        require(amount > 0, "Invalid amount");

        uint256 token2Amount = (amount * getExchangeRate()) / 1e18; // 1e18 is for decimal precision

        require(totalLiquidityToken2 >= token2Amount, "Insufficient liquidity for token2");

        require(IERC20(token1Address).transferFrom(msg.sender, address(this), amount), "Failed to transfer token1");
        require(IERC20(token2Address).transfer(msg.sender, token2Amount), "Failed to transfer token2");

        emit SwapInitiated(msg.sender, amount, token1Address, token2Address);
    }
}


//1-0x5D8045AE028cf5ffAc61Aed16837107a98C861e3
//2-0x0DB24a1c22daaAeAA06Fc65C6cB035696E3438B4
//0x4Bada227248Dde29C92355c94C38372234f767F7