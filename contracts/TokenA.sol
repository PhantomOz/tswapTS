// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// Import the ERC20 interface from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Define a contract for tokenA
contract TokenA is IERC20 {
    // Declare some state variables
    string public name = "FavourTK";
    string public symbol = "FTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Define a constructor that mints some initial tokens for the deployer
    constructor() {
        totalSupply = 1000000 * 10 ** decimals; // 1 million tokens with 18 decimals
        balanceOf[msg.sender] = totalSupply; // assign all tokens to the deployer
        emit Transfer(address(0), msg.sender, totalSupply); // emit a transfer event from the zero address to the deployer
    }

    // Define a function that transfers tokens from the caller to another address
    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(recipient != address(0), "Invalid recipient"); // check that the recipient is not the zero address
        require(balanceOf[msg.sender] >= amount, "Insufficient balance"); // check that the caller has enough balance

        balanceOf[msg.sender] -= amount; // deduct the amount from the caller's balance
        balanceOf[recipient] += amount; // add the amount to the recipient's balance
        emit Transfer(msg.sender, recipient, amount); // emit a transfer event
        return true; // return true to indicate success
    }

    // Define a function that approves another address to spend tokens on behalf of the caller
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        require(spender != address(0), "Invalid spender"); // check that the spender is not the zero address

        allowance[msg.sender][spender] = amount; // set the allowance for the spender
        emit Approval(msg.sender, spender, amount); // emit an approval event
        return true; // return true to indicate success
    }

    // Define a function that transfers tokens from one address to another, using the allowance mechanism
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(sender != address(0), "Invalid sender"); // check that the sender is not the zero address
        require(recipient != address(0), "Invalid recipient"); // check that the recipient is not the zero address
        require(balanceOf[sender] >= amount, "Insufficient balance"); // check that the sender has enough balance
        require(
            allowance[sender][msg.sender] >= amount,
            "Insufficient allowance"
        ); // check that the caller has enough allowance

        balanceOf[sender] -= amount; // deduct the amount from the sender's balance
        balanceOf[recipient] += amount; // add the amount to the recipient's balance
        allowance[sender][msg.sender] -= amount; // reduce the allowance of the caller by the amount transferred
        emit Transfer(sender, recipient, amount); // emit a transfer event
        return true; // return true to indicate success
    }

    // Define a function that mints new tokens and assigns them to an address
    function mint(address account, uint256 amount) external {
        require(account != address(0), "Invalid account"); // check that the account is not the zero address

        totalSupply += amount; // increase the total supply by the amount minted
        balanceOf[account] += amount; // increase the balance of the account by the amount minted
        emit Transfer(address(0), account, amount); // emit a transfer event from the zero address to the account
    }
}

// Define a contract for tokenB (similar to tokenA)
