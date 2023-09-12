// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TokenSwap {
    using SafeMath for uint256;

    // The tokens to be swapped
    IERC20 public tokenA;
    IERC20 public tokenB;

    // The total supply of liquidity tokens
    uint256 public totalSupply;

    // The balance of liquidity tokens for each address
    mapping(address => uint256) public balanceOf;

    // The balance of tokenA and tokenB in the pool
    uint256 public reserveA;
    uint256 public reserveB;

    // The constant product invariant
    uint256 public k;

    // The fee rate for each swap (0.3%)
    uint256 public constant feeRate = 30;
    uint256 public constant feeBase = 10000;

    // Events
    event Mint(address indexed sender, uint256 amount);
    event Burn(address indexed sender, uint256 amount);
    event Swap(
        address indexed sender,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    // Constructor
    constructor(IERC20 _tokenA, IERC20 _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // Provide liquidity to the pool and receive liquidity tokens
    function mint(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Invalid amounts");
        uint256 liquidity;
        if (totalSupply == 0) {
            // If the pool is empty, use the geometric mean of the amounts as the initial liquidity
            liquidity = sqrt(amountA.mul(amountB));
            k = liquidity.mul(liquidity);
        } else {
            // Otherwise, use the proportion of the smallest amount to the corresponding reserve as the liquidity
            uint256 amountAAdjusted = amountA.mul(feeBase.sub(feeRate));
            uint256 amountBAdjusted = amountB.mul(feeBase.sub(feeRate));
            if (
                amountAAdjusted.mul(reserveB) <= amountBAdjusted.mul(reserveA)
            ) {
                liquidity = amountAAdjusted.mul(totalSupply).div(
                    reserveA.mul(feeBase.sub(feeRate))
                );
            } else {
                liquidity = amountBAdjusted.mul(totalSupply).div(
                    reserveB.mul(feeBase.sub(feeRate))
                );
            }
            // Check that the invariant is not violated
            require(
                k <= reserveA.add(amountA).mul(reserveB.add(amountB)),
                "Invariant violated"
            );
        }
        require(liquidity > 0, "Insufficient liquidity");
        // Transfer the tokens to the pool
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
        // Update the reserves and the total supply
        reserveA = reserveA.add(amountA);
        reserveB = reserveB.add(amountB);
        totalSupply = totalSupply.add(liquidity);
        // Mint the liquidity tokens to the sender
        balanceOf[msg.sender] = balanceOf[msg.sender].add(liquidity);
        emit Mint(msg.sender, liquidity);
    }

    // Return liquidity tokens and receive tokenA and tokenB from the pool
    function burn(uint256 liquidity) external {
        require(
            liquidity > 0 && balanceOf[msg.sender] >= liquidity,
            "Invalid liquidity"
        );
        // Calculate the amount of tokens to return based on the proportion of liquidity to the total supply
        uint256 amountA = liquidity.mul(reserveA).div(totalSupply);
        uint256 amountB = liquidity.mul(reserveB).div(totalSupply);
        require(amountA > 0 && amountB > 0, "Insufficient amounts");
        // Transfer the tokens from the pool to the sender
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);
        // Update the reserves and the total supply
        reserveA = reserveA.sub(amountA);
        reserveB = reserveB.sub(amountB);
        totalSupply = totalSupply.sub(liquidity);
        // Burn the liquidity tokens from the sender
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(liquidity);
        emit Burn(msg.sender, liquidity);
    }

    // Swap tokenA for tokenB or vice versa
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external {
        require(
            tokenIn == address(tokenA) || tokenIn == address(tokenB),
            "Invalid tokenIn"
        );
        require(
            tokenOut == address(tokenA) || tokenOut == address(tokenB),
            "Invalid tokenOut"
        );
        require(tokenIn != tokenOut, "Identical tokens");
        require(amountIn > 0, "Invalid amountIn");
        // Transfer the input token from the sender to the pool
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        // Calculate the output amount using the constant product formula
        uint256 amountOut;
        uint256 fee = amountIn.mul(feeRate).div(feeBase);
        if (tokenIn == address(tokenA)) {
            amountOut = reserveB.sub(
                reserveA.mul(reserveB).div(reserveA.add(amountIn.sub(fee)))
            );
            // Transfer the output token from the pool to the sender
            tokenB.transfer(msg.sender, amountOut);
            // Update the reserves
            reserveA = reserveA.add(amountIn);
            reserveB = reserveB.sub(amountOut);
        } else {
            amountOut = reserveA.sub(
                reserveB.mul(reserveA).div(reserveB.add(amountIn.sub(fee)))
            );
            // Transfer the output token from the pool to the sender
            tokenA.transfer(msg.sender, amountOut);
            // Update the reserves
            reserveB = reserveB.add(amountIn);
            reserveA = reserveA.sub(amountOut);
        }
        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    // View functions

    // Get the price of tokenA in terms of tokenB
    function getPriceA() external view returns (uint256) {
        return reserveB.mul(1e18).div(reserveA); // 1e18 is used to add 18 decimals of precision
    }

    // Get the price of tokenB in terms of tokenA
    function getPriceB() external view returns (uint256) {
        return reserveA.mul(1e18).div(reserveB); // 1e18 is used to add 18 decimals of precision
    }

    // Get the amount of output token for a given amount of input token
    function getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256) {
        require(
            tokenIn == address(tokenA) || tokenIn == address(tokenB),
            "Invalid tokenIn"
        );
        require(
            tokenOut == address(tokenA) || tokenOut == address(tokenB),
            "Invalid tokenOut"
        );
        require(tokenIn != tokenOut, "Identical tokens");
        require(amountIn > 0, "Invalid amountIn");
        uint256 amountOut;
        uint256 fee = amountIn.mul(feeRate).div(feeBase);
        if (tokenIn == address(tokenA)) {
            amountOut = reserveB.sub(
                reserveA.mul(reserveB).div(reserveA.add(amountIn.sub(fee)))
            );
        } else {
            amountOut = reserveA.sub(
                reserveB.mul(reserveA).div(reserveB.add(amountIn.sub(fee)))
            );
        }
        return amountOut;
    }

    // Get the amount of input token for a given amount of output token
    function getAmountIn(
        address tokenIn,
        address tokenOut,
        uint256 amountOut
    ) external view returns (uint256) {
        require(
            tokenIn == address(tokenA) || tokenIn == address(tokenB),
            "Invalid tokenIn"
        );
        require(
            tokenOut == address(tokenA) || tokenOut == address(tokenB),
            "Invalid tokenOut"
        );
        require(tokenIn != tokenOut, "Identical tokens");
        require(amountOut > 0, "Invalid amountOut");
        uint256 amountIn;
        if (tokenIn == address(tokenA)) {
            uint256 numerator = reserveA.mul(amountOut).mul(feeBase);
            uint256 denominator = reserveB.sub(amountOut).mul(
                feeBase.sub(feeRate)
            );
            amountIn = numerator.div(denominator).add(1); // Add 1 to round up
        } else {
            uint256 numerator = reserveB.mul(amountOut).mul(feeBase);
            uint256 denominator = reserveA.sub(amountOut).mul(
                feeBase.sub(feeRate)
            );
            amountIn = numerator.div(denominator).add(1); // Add 1 to round up
        }
        return amountIn;
    }

    // Helper function to calculate the square root using the Babylonian method
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = x / 2 + 1;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}
