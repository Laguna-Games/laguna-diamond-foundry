//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IDiamondCut} from '../interfaces/IDiamondCut.sol';
import {LibContractOwner} from '../libraries/LibContractOwner.sol';
import {LibDiamond} from '../libraries/LibDiamond.sol';

/// @title LG extended DiamondCut Facet
/// @notice Adapted from the Diamond 3 reference implementation by Nick Mudge:
/// @notice https://github.com/mudgen/diamond-3-hardhat
contract DiamondCutFacet is IDiamondCut {
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @dev The LG implementation DOES NOT SUPPORT initializers!
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    /// @custom:selector 0x1f931c1c == bytes4(keccak256("diamondCut((address,uint8,bytes4[])[],address,bytes)"))
    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external override {
        (_init); // noop
        (_calldata); // noop
        LibDiamond.enforceIsContractOwner();
        LibDiamond.diamondCut(_diamondCut);
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @dev This is a convenience implementation of the above
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @custom:selector 0xe57e69c6 == bytes4(keccak256("diamondCut((address,uint8,bytes4[])[])"))
    function diamondCut(FacetCut[] calldata _diamondCut) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.diamondCut(_diamondCut);
    }

    /// @notice Removes one selector from the Diamond, using DiamondCut
    /// @param selector - The byte4 signature for a method selector to remove
    /// @custom:emits DiamondCut
    function cutSelector(bytes4 selector) external {
        LibContractOwner.enforceIsContractOwner();
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut);
    }

    /// @notice Removes one selector from the Diamond, using removeFunction()
    /// @param selector - The byte4 signature for a method selector to remove
    function deleteSelector(bytes4 selector) external {
        LibContractOwner.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.removeFunction(ds, ds.selectorToFacetAndPosition[selector].facetAddress, selector);
    }

    /// @notice Removes many selectors from the Diamond, using DiamondCut
    /// @param selectors - Array of byte4 signatures for method selectors to remove
    /// @custom:emits DiamondCut
    function cutSelectors(bytes4[] memory selectors) external {
        LibContractOwner.enforceIsContractOwner();
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: selectors
        });
        LibDiamond.diamondCut(cut);
    }

    /// @notice Removes many selectors from the Diamond, using removeFunctions()
    /// @param selectors - Array of byte4 signatures for method selectors to remove
    function deleteSelectors(bytes4[] memory selectors) external {
        LibContractOwner.enforceIsContractOwner();
        LibDiamond.removeFunctions(address(0), selectors);
    }

    /// @notice Removes any selectors from the Diamond that come from a target
    /// @notice contract address, using DiamondCut.
    /// @param facet - The address of the Facet smart contract to remove
    /// @custom:emits DiamondCut
    function cutFacet(address facet) external {
        LibContractOwner.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: ds.facetFunctionSelectors[facet].functionSelectors
        });
        LibDiamond.diamondCut(cut);
    }
}
