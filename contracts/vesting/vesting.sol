pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Vesting is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    enum TypeOfVestingWithTGE {
        PUBLICSALE,
        OTHERTYPE,
        NONE
    }
    struct VestingSchedule {
        bool initialized;
        address beneficiary;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 slicePeriodSeconds;
        bool revocable;
        uint256 amountTotal;
        uint256 released;
        bool revoked;
        TypeOfVestingWithTGE typeOfVestingWithTGE;
        bool claimTGE;
    }

   
    bytes32[] private vestingSchedulesIds;
    mapping(bytes32 => VestingSchedule) private vestingSchedules;
    uint256 private vestingSchedulesTotalAmount;
    mapping(address => uint256) private holdersVestingCount;
    uint256 timeTGE;

    IERC20 private immutable _token;
    event eventVestingSchedule(VestingSchedule vestingSchedule);

    modifier onlyIfVestingScheduleNotRevoked(bytes32 vestingScheduleId) {
        require(vestingSchedules[vestingScheduleId].initialized == true);
        require(vestingSchedules[vestingScheduleId].revoked == false);
        _;
    }

    constructor(address token_) {
        require(token_ != address(0x0));
        _token = IERC20(token_);
    }

    receive() external payable {}

    fallback() external payable {}

    function getVestingSchedulesCountByBeneficiary(address _beneficiary)
        external
        view
        returns (uint256)
    {
        return holdersVestingCount[_beneficiary];
    }

    function getVestingIdAtIndex(uint256 index)
        external
        view
        returns (bytes32)
    {
        require(
            index < getVestingSchedulesCount(),
            "index out of bounds"
        );
        return vestingSchedulesIds[index];
    }

    function getVestingScheduleByAddressAndIndex(address holder, uint256 index)
        external
        view
        returns (VestingSchedule memory)
    {
        return
            getVestingSchedule(
                computeVestingScheduleIdForAddressAndIndex(holder, index)
            );
    }

    function getVestingSchedulesTotalAmount() external view returns (uint256) {
        return vestingSchedulesTotalAmount;
    }

    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        bool _revocable,
        uint256 _amount,
        TypeOfVestingWithTGE _typeOfVesting
    ) public onlyOwner {
        require(
            this.getWithdrawableAmount() >= _amount,
            "cannot create vesting schedule because not sufficient tokens"
        );
        require(_duration > 0, "duration must be > 0");
        require(_amount > 0, "amount must be > 0");
        require(_slicePeriodSeconds >= 1, "slicePeriodSeconds must be >= 1");
        require(_start >= 1, "start must be >= 1");

        bytes32 vestingScheduleId = this.computeNextVestingScheduleIdForHolder(
            _beneficiary
        );
        uint256 cliff = _start.add(_cliff);
        vestingSchedules[vestingScheduleId] = VestingSchedule(
            true,
            _beneficiary,
            cliff,
            _start,
            _duration,
            _slicePeriodSeconds,
            _revocable,
            _amount,
            0,
            false,
            _typeOfVesting,
            false
        );
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.add(_amount);
        vestingSchedulesIds.push(vestingScheduleId);
        uint256 currentVestingCount = holdersVestingCount[_beneficiary];
        holdersVestingCount[_beneficiary] = currentVestingCount.add(1);

        emit eventVestingSchedule(vestingSchedules[vestingScheduleId]);
    }

    function revoke(bytes32 vestingScheduleId)
        public
        onlyOwner
        onlyIfVestingScheduleNotRevoked(vestingScheduleId)
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[
            vestingScheduleId
        ];
        require(vestingSchedule.revocable == true, "vesting is not revocable");
        uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
        if (vestedAmount > 0) {
            release(vestingScheduleId);
        }
        uint256 unreleased = vestingSchedule.amountTotal.sub(
            vestingSchedule.released
        );
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.sub(
            unreleased
        );
        vestingSchedule.revoked = true;
        emit eventVestingSchedule(vestingSchedule);
    }

    function withdraw(uint256 amount) public nonReentrant onlyOwner {
        require(
            this.getWithdrawableAmount() >= amount,
            "not enough withdrawable funds"
        );
        _token.safeTransfer(msg.sender, amount);
    }

    function release(bytes32 vestingScheduleId)
        public
        nonReentrant
        onlyIfVestingScheduleNotRevoked(vestingScheduleId)
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[
            vestingScheduleId
        ];
        bool isBeneficiary = msg.sender == vestingSchedule.beneficiary;
        bool isOwner = msg.sender == owner();
        require(
            isBeneficiary || isOwner,
            "only beneficiary can release vested tokens"
        );

        uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
        vestingSchedule.released = vestingSchedule.released.add(vestedAmount);
        address payable beneficiaryPayable = payable(
            vestingSchedule.beneficiary
        );
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.sub(
            vestedAmount
        );
        _token.safeTransfer(beneficiaryPayable, vestedAmount);

        emit eventVestingSchedule(vestingSchedule);
    }

    function setTimeTGE(uint256 _timeTGE) public onlyOwner {
        require(_timeTGE > 0, "timeTGE must be > 0");
        timeTGE = _timeTGE;
    }

    function getTimeTGE() public view returns (uint256) {
        return timeTGE;
    }

    function getVestingSchedulesCount() public view returns (uint256) {
        return vestingSchedulesIds.length;
    }

    function computeReleasableAmount(bytes32 vestingScheduleId)
        public
        view
        onlyIfVestingScheduleNotRevoked(vestingScheduleId)
        returns (uint256)
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[
            vestingScheduleId
        ];
        return _computeReleasableAmount(vestingSchedule);
    }

    function getVestingSchedule(bytes32 vestingScheduleId)
        public
        view
        returns (VestingSchedule memory)
    {
        return vestingSchedules[vestingScheduleId];
    }

    function getWithdrawableAmount() public view returns (uint256) {
        return _token.balanceOf(address(this)).sub(vestingSchedulesTotalAmount);
    }

    function computeNextVestingScheduleIdForHolder(address holder)
        public
        view
        returns (bytes32)
    {
        return
            computeVestingScheduleIdForAddressAndIndex(
                holder,
                holdersVestingCount[holder]
            );
    }

    function getLastVestingScheduleForHolder(address holder)
        public
        view
        returns (VestingSchedule memory)
    {
        return
            vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(
                    holder,
                    holdersVestingCount[holder] - 1
                )
            ];
    }

    function computeVestingScheduleIdForAddressAndIndex(
        address holder,
        uint256 index
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function _computeReleasableAmount(VestingSchedule memory vestingSchedule)
        internal
        view
        returns (uint256)
    {
        uint256 currentTime = getCurrentTime();
        uint256 vestedAmount = 0;
        uint256 TGEAmount = 0;

        if (currentTime >= timeTGE) {
            if (vestingSchedule.claimTGE == false) {
                if (
                    vestingSchedule.typeOfVestingWithTGE ==
                    TypeOfVestingWithTGE.PUBLICSALE
                ) {
                    TGEAmount = vestingSchedule.amountTotal.mul(25).div(100);
                } else if (
                    vestingSchedule.typeOfVestingWithTGE ==
                    TypeOfVestingWithTGE.OTHERTYPE
                ) {
                    TGEAmount = vestingSchedule.amountTotal.mul(5).div(100);
                } else {
                    TGEAmount = 0;
                }
                vestingSchedule.claimTGE = true;
            }
        }

        if (
            (currentTime < vestingSchedule.cliff) ||
            vestingSchedule.revoked == true
        ) {
            return 0;
        } else if (
            currentTime >=
            vestingSchedule.cliff.add(
                vestingSchedule.duration.mul(vestingSchedule.slicePeriodSeconds)
            )
        ) {
            return vestingSchedule.amountTotal.sub(vestingSchedule.released);
        } else {
            if (
                vestingSchedule.typeOfVestingWithTGE ==
                TypeOfVestingWithTGE.NONE
            ) {
                uint256 timeFromStart = currentTime.sub(vestingSchedule.cliff);
                uint256 vestedSlicePeriods = timeFromStart.div(
                    vestingSchedule.slicePeriodSeconds
                );
                vestedAmount = vestingSchedule
                    .amountTotal
                    .mul(vestedSlicePeriods)
                    .div(vestingSchedule.duration);
            } else if (
                vestingSchedule.typeOfVestingWithTGE ==
                TypeOfVestingWithTGE.PUBLICSALE
            ) {
                uint256 timeFromStart = currentTime.sub(vestingSchedule.cliff);
                uint256 vestedSlicePeriods = timeFromStart.div(
                    vestingSchedule.slicePeriodSeconds
                );
                uint256 amountTGE = vestingSchedule.amountTotal.mul(25).div(
                    100
                );
                uint256 amountVestingWithDuration = vestingSchedule
                    .amountTotal
                    .sub(amountTGE);
                vestedAmount = amountVestingWithDuration
                    .mul(vestedSlicePeriods)
                    .div(vestingSchedule.duration);
            } else {
                uint256 timeFromStart = currentTime.sub(vestingSchedule.cliff);
                uint256 vestedSlicePeriods = timeFromStart.div(
                    vestingSchedule.slicePeriodSeconds
                );
                uint256 amountTGE = vestingSchedule.amountTotal.mul(5).div(100);
                uint256 amountVestingWithDuration = vestingSchedule
                    .amountTotal
                    .sub(amountTGE);
                vestedAmount = amountVestingWithDuration
                    .mul(vestedSlicePeriods)
                    .div(vestingSchedule.duration);
            }
        }

        return (TGEAmount.add(vestedAmount).sub(vestingSchedule.released));
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
