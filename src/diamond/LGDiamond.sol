// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IDiamondCut} from '../interfaces/IDiamondCut.sol';
import {LibContractOwner} from '../libraries/LibContractOwner.sol';
import {LibDiamond} from '../libraries/LibDiamond.sol';

/// @title LG Diamond
/// @notice Adapted from the Diamond 3 reference implementation by Nick Mudge:
/// @notice https://github.com/mudgen/diamond-3-hardhat
contract Diamond {
    error FunctionDoesNotExist(bytes4 methodSelector);
    error DiamondAlreadyInitialized();

    constructor(address diamondCutFacet) payable {
        initializeDiamond(diamondCutFacet);
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        /* solhint-disable no-inline-assembly */
        // get facet from function selector
        address facet = LibDiamond.diamondStorage().selectorToFacetAndPosition[msg.sig].facetAddress;
        if (facet == address(0)) revert FunctionDoesNotExist(msg.sig);
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
        /* solhint-enable no-inline-assembly */
    }

    /// @notice Initializes the diamond, by adding the `diamondCut` method and setting the owner.
    /// @dev This function is automatically called by the constructor.
    /// @dev The code is separated out to facilitate on-chain copying utilities.
    function initializeDiamond(address diamondCutFacet) public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (ds.initialized) revert DiamondAlreadyInitialized();

        // Attach the diamondCut function from the diamondCutFacet
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: diamondCutFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: new bytes4[](1)
        });
        cut[0].functionSelectors[0] = IDiamondCut.diamondCut.selector;

        LibDiamond.diamondCut(cut);

        //  When deployed from an EOA this will be the owner wallet,
        //  when deployed from the clone function, the copier contract will be the owner.
        LibContractOwner.setContractOwner(msg.sender);

        ds.initialized = true;
    }

    receive() external payable {}
}
