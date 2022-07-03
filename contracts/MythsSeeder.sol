// SPDX-License-Identifier: GPL-3.0

/// @title The MythsToken pseudo-random seed generator

/*
███╗░░░███╗██╗░░░██╗████████╗██╗░░██╗░██████╗
████╗░████║╚██╗░██╔╝╚══██╔══╝██║░░██║██╔════╝
██╔████╔██║░╚████╔╝░░░░██║░░░███████║╚█████╗░
██║╚██╔╝██║░░╚██╔╝░░░░░██║░░░██╔══██║░╚═══██╗
██║░╚═╝░██║░░░██║░░░░░░██║░░░██║░░██║██████╔╝
╚═╝░░░░░╚═╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░
*/

pragma solidity ^0.8.6;

import {IMythsSeeder} from "./interfaces/IMythsSeeder.sol";
import {IMythsDescriptor} from "./interfaces/IMythsDescriptor.sol";

contract MythsSeeder is IMythsSeeder {
    /**
     * @notice Generate a pseudo-random Myth seed using the previous blockhash and myth ID.
     */
    // prettier-ignore
    function generateSeed(uint256 mythId, IMythsDescriptor descriptor) external view override returns (Seed memory) {
        uint256 pseudorandomness = uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), mythId))
        );

        uint256 backgroundCount = descriptor.backgroundCount();
        uint256 bodyCount = descriptor.bodyCount();
        uint256 accessoryCount = descriptor.accessoryCount();
        uint256 headCount = descriptor.headCount();
        uint256 glassesCount = descriptor.glassesCount();

        return Seed({
            background: uint48(
                uint48(pseudorandomness) % backgroundCount
            ),
            body: uint48(
                uint48(pseudorandomness >> 48) % bodyCount
            ),
            accessory: uint48(
                uint48(pseudorandomness >> 96) % accessoryCount
            ),
            head: uint48(
                uint48(pseudorandomness >> 144) % headCount
            ),
            glasses: uint48(
                uint48(pseudorandomness >> 192) % glassesCount
            )
        });
    }
}
