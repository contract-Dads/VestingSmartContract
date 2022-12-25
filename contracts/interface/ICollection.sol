pragma solidity ^0.8.4;

interface ICollection {
    function safeMint(address owner, string memory tokenCID)
        external
        returns (uint256);
}
