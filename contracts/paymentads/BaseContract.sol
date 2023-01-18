// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

abstract contract BaseContract is
    Initializable,
    UUPSUpgradeable,
    PausableUpgradeable,
    ERC165Upgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable
{

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    function __BaseContract_init() internal initializer {
        __BaseContract_init_unchained();
    }

    function __BaseContract_init_unchained() internal initializer {
        __UUPSUpgradeable_init();
        __Pausable_init();
    }

    modifier onlyAdmin() {
        _onlyRole(DEFAULT_ADMIN_ROLE);
        _;
    }

    modifier onlyOperator() {
        _onlyRole(OPERATOR_ROLE);
        _;
    }

    modifier whenContractNotPaused() {
        _whenNotPaused();
        _;
    }

    function _whenNotPaused() private view {
        require(!paused(), "Pausable: paused");
    }

    function _onlyRole(bytes32 role) internal view {
        _checkRole(role);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable,ERC165Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address) internal override onlyAdmin {}
}
