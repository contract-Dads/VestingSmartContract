pragma solidity ^0.8.4;

import "./Model.sol";
import "../interface/IFactory.sol";

contract Factory is IFactory, Model {
    function createCollection(
        string memory _name,
        string memory _sysbol,
        string memory _collectionCID
    ) external virtual override returns (address newCollection) {
        return msg.sender;
    }
}
