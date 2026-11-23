// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GuardianStaking.sol";

/**
 * @title GuardianSafetyModule
 * @notice Orchestrates the slashing of the staking pool when the 
 *         CoinEngine reports an uncovered bad debt event.
 */
contract GuardianSafetyModule {
    GuardianStaking public immutable stakingPool;
    address public immutable coinEngine;
    
    event ShortfallCovered(uint256 amount);

    constructor(address _stakingPool, address _coinEngine) {
        stakingPool = GuardianStaking(_stakingPool);
        coinEngine = _coinEngine;
    }
    
    /**
     * @notice Called by the CoinEngine when it has a shortfall.
     * @param amount The amount of bad debt to cover.
     */
    function coverShortfall(uint256 amount) external {
        require(msg.sender == coinEngine, "Only CoinEngine can call");
        
        // In a full implementation, we would loop through stakers or use a 
        // global index to slash pro-rata. For now, this acts as the trigger.
        
        // stakingPool.slash(...);
        
        emit ShortfallCovered(amount);
    }
}
