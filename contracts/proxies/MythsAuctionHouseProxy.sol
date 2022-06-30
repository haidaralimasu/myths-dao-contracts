// SPDX-License-Identifier: GPL-3.0

/// @title The Myths DAO auction house proxy

/*
███╗░░░███╗██╗░░░██╗████████╗██╗░░██╗░██████╗
████╗░████║╚██╗░██╔╝╚══██╔══╝██║░░██║██╔════╝
██╔████╔██║░╚████╔╝░░░░██║░░░███████║╚█████╗░
██║╚██╔╝██║░░╚██╔╝░░░░░██║░░░██╔══██║░╚═══██╗
██║░╚═╝░██║░░░██║░░░░░░██║░░░██║░░██║██████╔╝
╚═╝░░░░░╚═╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░
*/

pragma solidity ^0.8.6;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MythsAuctionHouseProxy is TransparentUpgradeableProxy {
    constructor(
        address logic,
        address admin,
        bytes memory data
    ) TransparentUpgradeableProxy(logic, admin, data) {}
}
