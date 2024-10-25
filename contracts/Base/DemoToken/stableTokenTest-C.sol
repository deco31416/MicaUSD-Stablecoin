// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @custom:security-contact contacta@deco31416.com
/// @custom:website www.deco31416.com

contract StabletokenTest is ERC20 {
    constructor() ERC20("StableTest-B", "STT-B") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}