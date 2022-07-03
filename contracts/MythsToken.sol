// SPDX-License-Identifier: GPL-3.0

/// @title The Myths ERC-721 token

/*
███╗░░░███╗██╗░░░██╗████████╗██╗░░██╗░██████╗
████╗░████║╚██╗░██╔╝╚══██╔══╝██║░░██║██╔════╝
██╔████╔██║░╚████╔╝░░░░██║░░░███████║╚█████╗░
██║╚██╔╝██║░░╚██╔╝░░░░░██║░░░██╔══██║░╚═══██╗
██║░╚═╝░██║░░░██║░░░░░░██║░░░██║░░██║██████╔╝
╚═╝░░░░░╚═╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░
*/

pragma solidity ^0.8.6;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721Checkpointable} from "./base/ERC721Checkpointable.sol";
import {IMythsDescriptor} from "./interfaces/IMythsDescriptor.sol";
import {IMythsSeeder} from "./interfaces/IMythsSeeder.sol";
import {IMythsToken} from "./interfaces/IMythsToken.sol";
import {ERC721} from "./base/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IProxyRegistry} from "./external/opensea/IProxyRegistry.sol";

contract MythsToken is IMythsToken, Ownable, ERC721Checkpointable {
    // The myths DAO address (creators org)
    address public mythsDAO;

    // An address who has permissions to mint Myths
    address public minter;

    // The Myths token URI descriptor
    IMythsDescriptor public descriptor;

    // The Myths token seeder
    IMythsSeeder public seeder;

    // Whether the minter can be updated
    bool public isMinterLocked;

    // Whether the descriptor can be updated
    bool public isDescriptorLocked;

    // Whether the seeder can be updated
    bool public isSeederLocked;

    // The myth seeds
    mapping(uint256 => IMythsSeeder.Seed) public seeds;

    // The internal myth ID tracker
    uint256 private _currentMythId;

    // IPFS content hash of contract-level metadata
    string private _contractURIHash =
        "QmZi1n79FqWt2tTLwCqiy6nLM6xLGRsEPQ5JmReJQKNNzX";

    // OpenSea's Proxy Registry
    IProxyRegistry public immutable proxyRegistry;

    /**
     * @notice Require that the minter has not been locked.
     */
    modifier whenMinterNotLocked() {
        require(!isMinterLocked, "Minter is locked");
        _;
    }

    /**
     * @notice Require that the descriptor has not been locked.
     */
    modifier whenDescriptorNotLocked() {
        require(!isDescriptorLocked, "Descriptor is locked");
        _;
    }

    /**
     * @notice Require that the seeder has not been locked.
     */
    modifier whenSeederNotLocked() {
        require(!isSeederLocked, "Seeder is locked");
        _;
    }

    /**
     * @notice Require that the sender is the myths DAO.
     */
    modifier onlyMythdersDAO() {
        require(msg.sender == mythsDAO, "Sender is not the myths DAO");
        _;
    }

    /**
     * @notice Require that the sender is the minter.
     */
    modifier onlyMinter() {
        require(msg.sender == minter, "Sender is not the minter");
        _;
    }

    constructor(
        address _mythsDAO,
        address _minter,
        IMythsDescriptor _descriptor,
        IMythsSeeder _seeder,
        IProxyRegistry _proxyRegistry
    ) ERC721("Myths", "MYTH") {
        mythsDAO = _mythsDAO;
        minter = _minter;
        descriptor = _descriptor;
        seeder = _seeder;
        proxyRegistry = _proxyRegistry;
    }

    /**
     * @notice The IPFS URI of contract-level metadata.
     */
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked("ipfs://", _contractURIHash));
    }

    /**
     * @notice Set the _contractURIHash.
     * @dev Only callable by the owner.
     */
    function setContractURIHash(string memory newContractURIHash)
        external
        onlyOwner
    {
        _contractURIHash = newContractURIHash;
    }

    /**
     * @notice Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        override(IERC721, ERC721)
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        if (proxyRegistry.proxies(owner) == operator) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }

    /**
     * @notice Mint a Myth to the minter, along with a possible myths reward
     * Myth. Mythders reward Myths are minted every 10 Myths, starting at 0,
     * until 183 myth Myths have been minted (5 years w/ 24 hour auctions).
     * @dev Call _mintTo with the to address(es).
     */
    function mint() public override onlyMinter returns (uint256) {
        if (_currentMythId <= 1820 && _currentMythId % 10 == 0) {
            _mintTo(mythsDAO, _currentMythId++);
        }
        return _mintTo(minter, _currentMythId++);
    }

    /**
     * @notice Burn a myth.
     */
    function burn(uint256 mythId) public override onlyMinter {
        _burn(mythId);
        emit MythBurned(mythId);
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "MythsToken: URI query for nonexistent token"
        );
        return descriptor.tokenURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Similar to `tokenURI`, but always serves a base64 encoded data URI
     * with the JSON contents directly inlined.
     */
    function dataURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "MythsToken: URI query for nonexistent token"
        );
        return descriptor.dataURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Set the myths DAO.
     * @dev Only callable by the myths DAO when not locked.
     */
    function setMythdersDAO(address _mythsDAO)
        external
        override
        onlyMythdersDAO
    {
        mythsDAO = _mythsDAO;

        emit MythdersDAOUpdated(_mythsDAO);
    }

    /**
     * @notice Set the token minter.
     * @dev Only callable by the owner when not locked.
     */
    function setMinter(address _minter)
        external
        override
        onlyOwner
        whenMinterNotLocked
    {
        minter = _minter;

        emit MinterUpdated(_minter);
    }

    /**
     * @notice Lock the minter.
     * @dev This cannot be reversed and is only callable by the owner when not locked.
     */
    function lockMinter() external override onlyOwner whenMinterNotLocked {
        isMinterLocked = true;

        emit MinterLocked();
    }

    /**
     * @notice Set the token URI descriptor.
     * @dev Only callable by the owner when not locked.
     */
    function setDescriptor(IMythsDescriptor _descriptor)
        external
        override
        onlyOwner
        whenDescriptorNotLocked
    {
        descriptor = _descriptor;

        emit DescriptorUpdated(_descriptor);
    }

    /**
     * @notice Lock the descriptor.
     * @dev This cannot be reversed and is only callable by the owner when not locked.
     */
    function lockDescriptor()
        external
        override
        onlyOwner
        whenDescriptorNotLocked
    {
        isDescriptorLocked = true;

        emit DescriptorLocked();
    }

    /**
     * @notice Set the token seeder.
     * @dev Only callable by the owner when not locked.
     */
    function setSeeder(IMythsSeeder _seeder)
        external
        override
        onlyOwner
        whenSeederNotLocked
    {
        seeder = _seeder;

        emit SeederUpdated(_seeder);
    }

    /**
     * @notice Lock the seeder.
     * @dev This cannot be reversed and is only callable by the owner when not locked.
     */
    function lockSeeder() external override onlyOwner whenSeederNotLocked {
        isSeederLocked = true;

        emit SeederLocked();
    }

    /**
     * @notice Mint a Myth with `mythId` to the provided `to` address.
     */
    function _mintTo(address to, uint256 mythId) internal returns (uint256) {
        IMythsSeeder.Seed memory seed = seeds[mythId] = seeder.generateSeed(
            mythId,
            descriptor
        );

        _mint(owner(), to, mythId);
        emit MythCreated(mythId, seed);

        return mythId;
    }
}
