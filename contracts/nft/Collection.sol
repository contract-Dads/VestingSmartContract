pragma solidity ^0.8.4;

import "./Model.sol";
import "../interface/ICollection.sol";

contract Collection is ICollection, Model {
    function safeMint(address owner, string memory tokenCID)
        external
        override
        returns (uint256)
    {
        return 1;
    }
}
