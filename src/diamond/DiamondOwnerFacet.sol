// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibContractOwner} from '../libraries/LibContractOwner.sol';
import {IERC173} from '../interfaces/IERC173.sol';

/// @title LG implementation of ERC-173 Contract Ownership Standard
/// @author rsampson@laguna.games
contract DiamondOwnerFacet is IERC173 {
    /// @notice Get the address of the owner
    /// @return The address of the owner.
    function owner() external view returns (address) {
        return LibContractOwner.contractOwner();
    }

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    /// @custom:emits OwnershipTransferred
    /// @custom:emits AdminChanged
    function transferOwnership(address _newOwner) external {
        LibContractOwner.enforceIsContractOwner();
        LibContractOwner.setContractOwner(_newOwner);
    }
}
