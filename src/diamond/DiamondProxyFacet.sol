// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibContractOwner} from '../libraries/LibContractOwner.sol';
import {LibProxyImplementation} from '../libraries/LibProxyImplementation.sol';

/// @title LG partial implementation of ERC-1967 Proxy Implementation
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @author rsampson@laguna.games
contract DiamondProxyFacet {
    /// @notice Sets the "implementation" contract address
    /// @param _implementation The new implementation contract
    /// @custom:emits Upgraded
    function setImplementation(address _implementation) external {
        LibContractOwner.enforceIsContractOwner();
        LibProxyImplementation.setImplementation(_implementation);
    }

    /// @notice Get the dummy "implementation" contract address
    /// @return The dummy "implementation" contract address
    function implementation() external view returns (address) {
        return LibProxyImplementation.getImplementation();
    }
}
