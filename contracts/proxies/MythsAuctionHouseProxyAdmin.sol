// SPDX-License-Identifier: GPL-3.0

/// @title The Myths DAO auction house proxy admin

/*
███╗░░░███╗██╗░░░██╗████████╗██╗░░██╗░██████╗
████╗░████║╚██╗░██╔╝╚══██╔══╝██║░░██║██╔════╝
██╔████╔██║░╚████╔╝░░░░██║░░░███████║╚█████╗░
██║╚██╔╝██║░░╚██╔╝░░░░░██║░░░██╔══██║░╚═══██╗
██║░╚═╝░██║░░░██║░░░░░░██║░░░██║░░██║██████╔╝
╚═╝░░░░░╚═╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░
*/

pragma solidity ^0.8.6;

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

// prettier-ignore
contract MythsAuctionHouseProxyAdmin is ProxyAdmin {}
