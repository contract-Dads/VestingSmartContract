pragma solidity ^0.8.4;

import "./BaseContract.sol";
import "./Advertiser.sol";

contract ManagerContract is BaseContract {
    using SafeERC20 for IERC20; 
    using SafeMath for uint256;

    struct AdViewer {
        address viewer;
        uint256 balance;
    }

    // struct Advertiser {
    //     address Advertiser;

    // }

    mapping(address => address) public Advertisers;
    mapping(address => AdViewer) public AdViewers;
    IERC20 private token;
    uint256 rateSwap;

    function setRateSwap(uint256 rate) onlyAdmin public {
        rateSwap = rate;
    }

    function setToken(address _token) onlyAdmin public {
        token = IERC20(_token);
    }

    function createAdvertiser(address _advertiser, address _token) public 
    {
        Advertiser advertiserContract = new Advertiser(
            _advertiser,
            _token,
            address(this)
        );
        address advertiserContractAddress = address(advertiserContract);
        Advertisers[_advertiser] = advertiserContractAddress;
    }

    function swaptoken(uint256 amount) public {

        uint256 balanceContract = token.balanceOf(address(this));
        require(balanceContract > amount, "not enough balance");
  //      address viewer = msg.sender;
        //AdViewer storage adviewer = Advertisers[msg.sender];
        // address abc = Advertisers[msg.sender].viewer;
        // if(adviewer.viewer != address(0)) {

        // }

        uint256 value = amount.mul(rateSwap);

        token.safeTransfer(msg.sender, value);

    }

    function withdrawtoken(uint256 amount) onlyAdmin public {
        token.safeTransfer(msg.sender, amount);
    }
}