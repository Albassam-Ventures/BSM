// SPDX-License-Identifier: GPL-3.0-or-later Or MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BSM is ERC20("Albassam Token", "BSM"), Ownable {
    bool private transferring = false;
    uint public transferFee = 25; // transfer fee percents multiplied by 100

    address[] public feeAddresses;

    mapping(address => bool) public whitelisted;

    constructor() {
      _mint(msg.sender, 300_000_000 ether);
    }

    modifier notFeeTransfer() {
        require(!transferring);
        transferring = true;
        _;
        transferring = false;
    }

    function setTransferFee(uint _fee) external onlyOwner {
      require (_fee <= 1000, "Invalid fee amount!");
      transferFee = _fee;
    }

    function setFeeAddresses(address[] memory _addresses) external onlyOwner {
      require (_addresses.length <= 2, "To many fee addresses!");
      feeAddresses = _addresses;
    }

    function setWhitelisted(address _user, bool _whitelisted) external onlyOwner {
      whitelisted[_user] = _whitelisted;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override notFeeTransfer {
        uint feeAmount = amount * transferFee / 10000 ;
        uint totalFee = 0;

        if (feeAddresses.length > 0 && !whitelisted[to] && !whitelisted[from]) {
          for (uint i = 0; i < feeAddresses.length; i++) {
            ERC20._transfer(from, feeAddresses[i], feeAmount);
            totalFee += feeAmount;
          }
        }

        ERC20._transfer(from, to, amount - totalFee);
    }
}