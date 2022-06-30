// SPDX-License-Identifier: GPL-3.0

/// @title Interface for MythsToken

/*
███╗░░░███╗██╗░░░██╗████████╗██╗░░██╗░██████╗
████╗░████║╚██╗░██╔╝╚══██╔══╝██║░░██║██╔════╝
██╔████╔██║░╚████╔╝░░░░██║░░░███████║╚█████╗░
██║╚██╔╝██║░░╚██╔╝░░░░░██║░░░██╔══██║░╚═══██╗
██║░╚═╝░██║░░░██║░░░░░░██║░░░██║░░██║██████╔╝
╚═╝░░░░░╚═╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░
*/

pragma solidity ^0.8.6;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IMythsDescriptor} from "./IMythsDescriptor.sol";
import {IMythsSeeder} from "./IMythsSeeder.sol";

interface IMythsToken is IERC721 {
    event MythCreated(uint256 indexed tokenId, IMythsSeeder.Seed seed);

    event MythBurned(uint256 indexed tokenId);

    event MythdersDAOUpdated(address mythsDAO);

    event MinterUpdated(address minter);

    event MinterLocked();

    event DescriptorUpdated(IMythsDescriptor descriptor);

    event DescriptorLocked();

    event SeederUpdated(IMythsSeeder seeder);

    event SeederLocked();

    function mint() external returns (uint256);

    function burn(uint256 tokenId) external;

    function dataURI(uint256 tokenId) external returns (string memory);

    function setMythdersDAO(address mythsDAO) external;

    function setMinter(address minter) external;

    function lockMinter() external;

    function setDescriptor(IMythsDescriptor descriptor) external;

    function lockDescriptor() external;

    function setSeeder(IMythsSeeder seeder) external;

    function lockSeeder() external;
}
