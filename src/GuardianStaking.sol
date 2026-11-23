// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GuardianStaking
 * @notice Aave-style Safety Module. Users stake BSC to provide a 
 *         first-loss backstop. Funds are subject to a cooldown.
 */
contract GuardianStaking is ReentrancyGuard, Ownable {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;
    
    uint256 public cooldownPeriod = 10 days;
    
    struct Staker {
        uint256 amount;
        uint256 cooldownStart;
        uint256 pendingWithdrawal;
    }
    
    mapping(address => Staker) public stakers;
    
    event Staked(address indexed user, uint256 amount);
    event WithdrawalRequested(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Slashed(address indexed user, uint256 amount);

    constructor(address _stakingToken, address _rewardToken) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }
    
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");
        Staker storage s = stakers[msg.sender];
        
        // Reset cooldown if they stake again
        if (s.cooldownStart > 0) {
            s.cooldownStart = 0;
            s.pendingWithdrawal = 0;
        }
        
        s.amount += amount;
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        emit Staked(msg.sender, amount);
    }
    
    function requestWithdrawal() external {
        Staker storage s = stakers[msg.sender];
        require(s.amount > 0, "No stake");
        s.cooldownStart = block.timestamp;
        s.pendingWithdrawal = s.amount;
        emit WithdrawalRequested(msg.sender, s.amount);
    }
    
    function withdraw() external nonReentrant {
        Staker storage s = stakers[msg.sender];
        require(s.cooldownStart > 0, "Cooldown not started");
        require(block.timestamp >= s.cooldownStart + cooldownPeriod, "Cooldown active");
        
        uint256 amount = s.pendingWithdrawal;
        s.amount -= amount;
        s.cooldownStart = 0;
        s.pendingWithdrawal = 0;
        
        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }
    
    // Only callable by the Safety Module in a shortfall
    function slash(address staker, uint256 amount) external onlyOwner {
        Staker storage s = stakers[staker];
        require(s.amount >= amount, "Slash amount exceeds stake");
        s.amount -= amount;
        
        // In a real scenario, this might transfer to the protocol treasury
        emit Slashed(staker, amount);
    }
}
