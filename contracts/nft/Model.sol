pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

abstract contract Model is
    Initializable,
    UUPSUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    function initialize() public initializer {
        __UUPSUpgradeable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _onlyRole(bytes32 role) internal view {
        _checkRole(role, _msgSender());
    }

    modifier onlyPauser() {
        _onlyRole(DEFAULT_ADMIN_ROLE);
        _;
    }

    modifier onlyAdmin() {
        _onlyRole(DEFAULT_ADMIN_ROLE);
        _;
    }

    function _whenNotPaused() private view {
        require(!paused(), "Pausable: paused");
    }

    function pause() external onlyPauser {
        _pause();
    }

    function unPause() external onlyPauser {
        _unpause();
    }

    function _authorizeUpgrade(address) internal override onlyAdmin {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
