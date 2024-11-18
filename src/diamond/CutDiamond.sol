// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DiamondFragment} from '../implementation/DiamondFragment.sol';
import {DiamondCutFragment} from '../implementation/DiamondCutFragment.sol';
import {DiamondLoupeFragment} from '../implementation/DiamondLoupeFragment.sol';
import {DiamondOwnerFragment} from '../implementation/DiamondOwnerFragment.sol';
import {DiamondProxyFragment} from '../implementation/DiamondProxyFragment.sol';
import {SupportsInterfaceFragment} from '../implementation/SupportsInterfaceFragment.sol';

/// @title Cut Diamond
/// @notice This is a dummy "implementation" contract for ERC-1967 compatibility,
/// @notice this interface is used by block explorers to generate the UI interface.
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
contract CutDiamond is
    DiamondFragment,
    DiamondCutFragment,
    DiamondLoupeFragment,
    DiamondOwnerFragment,
    DiamondProxyFragment,
    SupportsInterfaceFragment
{

}
