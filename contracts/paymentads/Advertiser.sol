pragma solidity ^0.8.4;

import "./BaseContract.sol";


contract Advertiser {
    using SafeERC20 for IERC20;
    address advertiser;
    IERC20 private token;
    uint256 amountTotalDeposit;
    address operator;
    
    constructor(address _advertiser, address _token, address _operator){
        advertiser = _advertiser;
        token = IERC20(_token);
        operator = _operator;
    }

    function depositToken(uint256 _amount) public {
        require(msg.sender == advertiser, "the depositor must be an advertiser of contract");
        amountTotalDeposit = amountTotalDeposit + _amount;
    }

    function checkbalanceAmount(uint256 amountUse) public view returns(uint256)
    {
        require(amountUse <= amountTotalDeposit , "exceed the amount deposited");
         uint256 remainingAmount = amountTotalDeposit - amountUse;

        return remainingAmount;
    }

    function withDraw(uint256 amount , uint256 amountUse)  public {
        require(msg.sender == operator, "is not operator");
        uint256 remainingAmount = checkbalanceAmount(amountUse);
        require(amount <= remainingAmount);
        token.safeTransfer(advertiser, amount);
        
    }
}