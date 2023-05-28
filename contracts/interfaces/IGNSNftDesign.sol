// SPDX-License-Identifier: MIT
import '../interfaces/IGToken.sol';

pragma solidity 0.8.17;

interface IGNSNftDesign{
    function buildTokenURI(uint nftType, uint tokenId) external pure returns (string memory);
}
