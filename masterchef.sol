// SPDX-License-Identifier: GPL-3.0-or-later Or MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Masterchef is Ownable {
  IERC20 public token;
  mapping(address => uint) public userStakesFor6mo;
  mapping(address => uint) public userStakesFor9mo;
  mapping(address => uint) public userStakesFor12mo;

  uint public totalStakesFor6mo;
  uint public totalStakesFor9mo;
  uint public totalStakesFor12mo;

  mapping(address => uint) public lastClaimTimeFor6mo;
  mapping(address => uint) public lastClaimTimeFor9mo;
  mapping(address => uint) public lastClaimTimeFor12mo;

  mapping(address => uint) public lastStakeTimeFor6mo;
  mapping(address => uint) public lastStakeTimeFor9mo;
  mapping(address => uint) public lastStakeTimeFor12mo;

  mapping(address => uint) internal userRewardFor6mo;
  mapping(address => uint) internal userRewardFor9mo;
  mapping(address => uint) internal userRewardFor12mo;

  uint public rewardRate6mo = 14;
  uint public rewardRate9mo = 20;
  uint public rewardRate12mo = 30;

  uint immutable _6MO = 182 days;
  uint immutable _9MO = 273 days;
  uint immutable _12MO = 365 days;

  constructor(IERC20 _token) {
    token = _token;
  }

  function setRewardRates(uint _rate6mo, uint _rate9mo, uint _rate12mo) external onlyOwner {
    rewardRate6mo = _rate6mo;
    rewardRate9mo = _rate9mo;
    rewardRate12mo = _rate12mo;
  }

  function pendingRewardFor6mo(address user) public view returns (uint) {
    return userRewardFor6mo[user] + userStakesFor6mo[user] * (block.timestamp - lastClaimTimeFor6mo[user]) * rewardRate6mo / (_12MO * 100);
  }

  function pendingRewardFor9mo(address user) public view returns (uint) {
    return userRewardFor9mo[user] + userStakesFor9mo[user] * (block.timestamp - lastClaimTimeFor9mo[user]) * rewardRate9mo / (_12MO * 100);
  }

  function pendingRewardFor12mo(address user) public view returns (uint) {
    return userRewardFor12mo[user] + userStakesFor12mo[user] * (block.timestamp - lastClaimTimeFor12mo[user]) * rewardRate12mo / (_12MO * 100);
  }

  function withdraw(address to, uint amount) external onlyOwner {
    token.transfer(to, amount);
  }

  // stake functions
  function stakeFor6mo(uint _amount) external {
    require (_amount > 0, "ERROR! Invalid amount!");

    if (userStakesFor6mo[msg.sender] == 0) {
      lastStakeTimeFor6mo[msg.sender] = block.timestamp;
    }

    token.transferFrom(msg.sender, address(this), _amount);
    userRewardFor6mo[msg.sender] = pendingRewardFor6mo(msg.sender);
    userStakesFor6mo[msg.sender] += _amount;
    lastClaimTimeFor6mo[msg.sender] = block.timestamp;
    totalStakesFor6mo += _amount;
  }

  function stakeFor9mo(uint _amount) external {
    require (_amount > 0, "ERROR! Invalid amount!");

    if (userStakesFor9mo[msg.sender] == 0) {
      lastStakeTimeFor9mo[msg.sender] = block.timestamp;
    }

    token.transferFrom(msg.sender, address(this), _amount);
    userRewardFor9mo[msg.sender] = pendingRewardFor9mo(msg.sender);
    userStakesFor9mo[msg.sender] += _amount;
    lastClaimTimeFor9mo[msg.sender] = block.timestamp;
    totalStakesFor9mo += _amount;
  }

  function stakeFor12mo(uint _amount) external {
    require (_amount > 0, "ERROR! Invalid amount!");

    if (userStakesFor12mo[msg.sender] == 0) {
      lastStakeTimeFor12mo[msg.sender] = block.timestamp;
    }

    token.transferFrom(msg.sender, address(this), _amount);
    userRewardFor12mo[msg.sender] = pendingRewardFor12mo(msg.sender);
    userStakesFor12mo[msg.sender] += _amount;
    lastClaimTimeFor12mo[msg.sender] = block.timestamp;
    totalStakesFor12mo += _amount;
  }

  // unstake functions
  function unstakeFor6mo(uint amount) external {
    require (userStakesFor6mo[msg.sender] > 0 && amount <= userStakesFor6mo[msg.sender], "ERROR! You have no deposit");
    require (block.timestamp > lastStakeTimeFor6mo[msg.sender] + _6MO, "ERROR! You can't claim yet");

    _claim6(msg.sender);
    token.transfer(msg.sender, amount);
    userStakesFor6mo[msg.sender] -= amount;
    totalStakesFor6mo -= amount;
  }

  function unstakeFor9mo(uint amount) external {
    require (userStakesFor9mo[msg.sender] > 0 && amount <= userStakesFor9mo[msg.sender], "ERROR! You have no deposit");
    require (block.timestamp > lastStakeTimeFor9mo[msg.sender] + _9MO, "ERROR! You can't claim yet");

    _claim6(msg.sender);
    token.transfer(msg.sender, amount);
    userStakesFor9mo[msg.sender] -= amount;
    totalStakesFor9mo -= amount;
  }

  function unstakeFor12mo(uint amount) external {
    require (userStakesFor12mo[msg.sender] > 0 && amount <= userStakesFor12mo[msg.sender], "ERROR! You have no deposit");
    require (block.timestamp > lastStakeTimeFor12mo[msg.sender] + _12MO, "ERROR! You can't claim yet");

    _claim6(msg.sender);
    token.transfer(msg.sender, amount);
    userStakesFor12mo[msg.sender] -= amount;
    totalStakesFor12mo -= amount;
  }

  // claim functions
  function _claim6(address user) internal {
    uint reward = pendingRewardFor6mo(user);

    if (reward > 0) {
      token.transfer(user, reward);
      userRewardFor6mo[user] = 0;
      lastClaimTimeFor6mo[user] = block.timestamp;
    }
  }

  function _claim9(address user) internal {
    uint reward = pendingRewardFor6mo(user);

    if (reward > 0) {
      token.transfer(user, reward);
      userRewardFor9mo[user] = 0;
      lastClaimTimeFor9mo[user] = block.timestamp;
    }
  }

  function _claim12(address user) internal {
    uint reward = pendingRewardFor6mo(user);

    if (reward > 0) {
      token.transfer(user, reward);
      userRewardFor12mo[user] = 0;
      lastClaimTimeFor12mo[user] = block.timestamp;
    }
  }

  function claimFor6mo() external {
    _claim6(msg.sender);
  }

  function claimFor9mo() external {
    _claim9(msg.sender);
  }

  function claimFor12mo() external {
    _claim12(msg.sender);
  }

  // emergency unstake (30% fee)
  function forceUnstakeFor6mo(uint amount) external {
    require (userStakesFor6mo[msg.sender] > 0, "ERROR! You have no deposit");
    require (userStakesFor6mo[msg.sender] >= amount, "ERROR! You have not enough deposit");

    _claim6(msg.sender);
    token.transfer(msg.sender, amount * 7 / 10);
    userStakesFor6mo[msg.sender] -= amount;
    totalStakesFor6mo -= amount;
  }

  function forceUnstakeFor9mo(uint amount) external {
    require (userStakesFor9mo[msg.sender] > 0, "ERROR! You have no deposit");
    require (userStakesFor9mo[msg.sender] >= amount, "ERROR! You have not enough deposit");

    _claim9(msg.sender);
    token.transfer(msg.sender, amount * 7 / 10);
    userStakesFor9mo[msg.sender] -= amount;
    totalStakesFor9mo -= amount;
  }

  function forceUnstakeFor12mo(uint amount) external {
    require (userStakesFor12mo[msg.sender] > 0, "ERROR! You have no deposit");
    require (userStakesFor12mo[msg.sender] >= amount, "ERROR! You have not enough deposit");

    _claim12(msg.sender);
    token.transfer(msg.sender, amount * 7 / 10);
    userStakesFor12mo[msg.sender] -= amount;
    totalStakesFor12mo -= amount;
  }
}