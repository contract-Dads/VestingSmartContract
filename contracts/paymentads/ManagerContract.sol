pragma solidity ^0.8.4;

import "./BaseContract.sol";
import "./Advertiser.sol";

contract ManagerContract is BaseContract {
    // struct AdViewer {
    //     address Viewer;
    //     uint256 balance;
    // }

    // struct Advertiser {
    //     address Advertiser;

    // }

    mapping(address => address) public Advertisers;
    mapping(address => uint256) public AdViewers;

    function createAdvertiser(address advertiser,address token) public 
    {
        Advertiser advertiserContract = new Advertiser(
            advertiser,
            token,
            address(this)
        );
        address advertiserContractAddress = address(advertiserContract);
        Advertisers[advertiser] = advertiserContractAddress;
    }

    function swaptoken(uint256 amount) public {
        
    }

    function withdrawtoken(uint256 amount) public {

    }
}