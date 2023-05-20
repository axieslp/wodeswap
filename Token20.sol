// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "./Access.sol";

contract Token20 is ERC20Burnable, Access {
  TransferAop private transferAop;

  constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
    _mint(msg.sender, 21000000E18);
  }

  function _transfer(address from, address to, uint amount) internal override {
    if (address(transferAop) != address(0)) {
      uint fee = transferAop.feeCalculate(from, to, amount);
      if (fee > 0) {
        super._transfer(from, address(transferAop), fee);
        transferAop.feeReceive(from, to, fee);
        amount = amount - fee;
      }
    }
    super._transfer(from, to, amount);
  }

  function setTransferAop(TransferAop transferAop_) public onlyRole(1) {
    transferAop = transferAop_;
  }
}

interface TransferAop {
  function feeCalculate(address from, address to, uint amount) external returns (uint);

  function feeReceive(address from, address to, uint fee) external;
}
