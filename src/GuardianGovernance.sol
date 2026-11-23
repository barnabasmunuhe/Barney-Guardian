// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title GuardianGovernance
 * @notice Manages protocol parameters via a Timelock, ensuring all
 *         critical changes are subject to a delay for security.
 */
contract GuardianGovernance is TimelockController {
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin)
        TimelockController(minDelay, proposers, executors, admin)
    {}
}
