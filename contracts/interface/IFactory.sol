pragma solidity ^0.8.4;

interface IFactory {
    function createCollection(
        string memory _name,
        string memory _sysbol,
        string memory _collectionCID
    ) external returns (address newCollection);
}
