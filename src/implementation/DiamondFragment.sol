// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Diamond Interface Fragment
/// @dev Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
contract DiamondFragment {
    error FunctionDoesNotExist(bytes4 methodSelector);
    error DiamondAlreadyInitialized();
}
