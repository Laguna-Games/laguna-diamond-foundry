// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// forge-ignore: 5574

import {console} from '../../lib/forge-std/src/console.sol';
import {Vm} from 'forge-std/Vm.sol';

import {CutDiamondDeployLib} from './CutDiamondDeployLib.s.sol';
import {Diamond} from '../../src/diamond/LGDiamond.sol';
import {DiamondCutDeployLib} from './DiamondCutDeployLib.s.sol';
import {DiamondCutFragment} from '../../src/implementation/DiamondCutFragment.sol';
import {DiamondLoupeDeployLib} from './DiamondLoupeDeployLib.s.sol';
import {DiamondLoupeFragment} from '../../src/implementation/DiamondLoupeFragment.sol';
import {DiamondOwnerDeployLib} from './DiamondOwnerDeployLib.s.sol';
import {DiamondProxyDeployLib} from './DiamondProxyDeployLib.s.sol';
import {DiamondProxyFacet} from '../../src/diamond/DiamondProxyFacet.sol';
import {EIP5313} from '../../src/interfaces/IERC173.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {IDiamondLoupe} from '../../src/interfaces/IDiamondLoupe.sol';
import {IERC165} from '../../src/interfaces/IERC165.sol';
import {IERC173} from '../../src/interfaces/IERC173.sol';
import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';
import {SupportsInterfaceDeployLib} from './SupportsInterfaceDeployLib.s.sol';
import {SupportsInterfaceFacet} from '../../src/diamond/SupportsInterfaceFacet.sol';

/// @title Deploy Struct
/// @notice Struct for storing deployment information
struct Deploy {
    address diamond;
    address diamondOwner;
    address diamondCutFacet;
    address diamondLoupeFacet;
    address diamondOwnerFacet;
    address diamondProxyFacet;
    address supportsInterfaceFacet;
    address implementation;
}

/// @title DiamondCutFacet Utility
/// @notice Utility functions for working with the DiamondCutFacet
/// @author Rob Sampson
library LibDeploy {
    function deployFullDiamond() internal returns (Deploy memory deployment) {
        deployment = deployBlankDiamond();
        deployment = upgradeBlankDiamondToFullDiamond(deployment);
        deployment = initializeSupportedInterfaces(deployment);
        deployment = deployCutDiamondImplementation(deployment);
        return deployment;
    }

    /// @notice Deploy a new Diamond contract with DiamondCutFacet. No other facets are deployed.
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Diamond owner will be the deployer wallet.
    /// @return The address of the deployed Diamond
    function deployBlankDiamond() internal returns (Deploy memory) {
        Vm vm = getVM();
        Deploy memory deployment;
        deployment.diamondCutFacet = DiamondCutDeployLib.getInjectedOrNewFacetInstance();

        vm.recordLogs();
        deployment.diamond = address(new Diamond(deployment.diamondCutFacet));

        //  extract the `owner` field from the OwnershipTransferred event
        Vm.Log[] memory logs = vm.getRecordedLogs();
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == LibContractOwner.OwnershipTransferred.selector) {
                (address previousOwner, address newOwner) = abi.decode(
                    abi.encodePacked(logs[i].topics[1], logs[i].topics[2]),
                    (address, address)
                );
                (previousOwner); // noop
                deployment.diamondOwner = newOwner;
                break;
            }
        }

        console.log(string.concat('Deployed new Diamond at: ', vm.toString(deployment.diamond)));
        console.log(string.concat('Diamond owner: ', vm.toString(deployment.diamondOwner)));
        return deployment;
    }

    /// @notice Deploy and attach utility facets to a naked Diamond contract.
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Only the Diamond owner can call this function.
    /// @dev A Diamond contract needs to be deployed upstream, or specified in the DIAMOND env variable
    function upgradeBlankDiamondToFullDiamond(Deploy memory deployment) internal returns (Deploy memory) {
        Vm vm = getVM();
        if (deployment.diamond == address(0) || LibDeploy.codeSize(deployment.diamond) == 0) {
            revert('No Diamond contract found');
        }

        if (deployment.diamondCutFacet != address(0) || codeSize(deployment.diamondCutFacet) == 0) {
            //  only overwrite if not already set
            deployment.diamondCutFacet = DiamondCutDeployLib.getInjectedOrNewFacetInstance();
        }

        deployment.diamondLoupeFacet = DiamondLoupeDeployLib.getInjectedOrNewFacetInstance();
        deployment.diamondOwnerFacet = DiamondOwnerDeployLib.getInjectedOrNewFacetInstance();
        deployment.diamondProxyFacet = DiamondProxyDeployLib.getInjectedOrNewFacetInstance();
        deployment.supportsInterfaceFacet = SupportsInterfaceDeployLib.getInjectedOrNewFacetInstance();

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](5);
        cuts[0] = DiamondCutDeployLib.generateFacetCut(deployment.diamondCutFacet);
        cuts[1] = DiamondLoupeDeployLib.generateFacetCut(deployment.diamondLoupeFacet);
        cuts[2] = DiamondOwnerDeployLib.generateFacetCut(deployment.diamondOwnerFacet);
        cuts[3] = DiamondProxyDeployLib.generateFacetCut(deployment.diamondProxyFacet);
        cuts[4] = SupportsInterfaceDeployLib.generateFacetCut(deployment.supportsInterfaceFacet);

        //  There's a chance this blows up if the Diamond has a different owner than the deployer,
        //  but we can't check for this until the DiamondOwnerFacet is attached so...
        console.log(string.concat('Attaching facets to Diamond: ', vm.toString(deployment.diamond)));
        IDiamondCut(deployment.diamond).diamondCut(cuts, address(0), '');

        return deployment;
    }

    /// @notice Initialize the SupportsInterfaceFacet with the default diamond interfaces
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Only the Diamond owner can call this function.
    /// @dev A Diamond contract needs to be deployed upstream, or specified in the DIAMOND env variable
    function initializeSupportedInterfaces(Deploy memory deployment) internal returns (Deploy memory) {
        if (deployment.diamond == address(0) || LibDeploy.codeSize(deployment.diamond) == 0) {
            revert('No Diamond contract found');
        }

        bytes4[] memory interfaceIds = new bytes4[](5);
        interfaceIds[0] = type(IERC165).interfaceId; // 0x01ffc9a7
        interfaceIds[1] = type(IDiamondCut).interfaceId; // 0x1f931c1c
        interfaceIds[2] = type(IDiamondLoupe).interfaceId; // 0x48e2b093
        interfaceIds[3] = type(IERC173).interfaceId; // 0x7f5828d0
        interfaceIds[4] = type(EIP5313).interfaceId; // 0x8da5cb5b

        console.logString('Setting supportsInterface selectors...');
        SupportsInterfaceFacet(deployment.diamond).setSupportsInterfaces(interfaceIds, true);
        return deployment;
    }

    /// @notice Deploy a new "CutDiamond" contract to act as a unified interface (ERC-1967) for the Diamond
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Only the Diamond owner can call this function.
    /// @dev Specify the Implementation address in the IMPLEMENTATION_CONTRACT env var
    /// @dev A Diamond contract needs to be deployed upstream, or specified in the DIAMOND env variable
    /// @return implementation The address of the deployed CutDiamond interface contract
    function deployCutDiamondImplementation(Deploy memory deployment) internal returns (Deploy memory) {
        Vm vm = getVM();
        if (deployment.diamond == address(0) || LibDeploy.codeSize(deployment.diamond) == 0) {
            revert('No Diamond contract found');
        }

        deployment.implementation = CutDiamondDeployLib.getInjectedOrNewImplementationInstance();

        console.log(string.concat('Setting CutDiamond implementation to: ', vm.toString(deployment.implementation)));
        DiamondProxyFacet(deployment.diamond).setImplementation(deployment.implementation);
        return deployment;
    }

    /// @notice Get a stateless reference to the Foundry VM standard library
    /// @return vm A reference to the forge-std Vm interface
    function getVM() internal pure returns (Vm) {
        return Vm(address(uint160(uint256(keccak256('hevm cheat code'))))); //  hard reference to the Foundry VM
    }

    /// @notice Get the address of the diamond from the DIAMOND environment var
    /// @return diamond The address of the target diamond
    function getDiamondFromEnvironment() internal view returns (address diamond) {
        Vm vm = getVM();
        diamond = vm.envOr('DIAMOND', address(0));
        if (diamond == address(0)) revert('Missing DIAMOND env var');
        if (diamond.code.length == 0) revert(string.concat('DIAMOND address has no code: ', vm.toString(diamond)));
    }

    /// @notice Get an address specified in an environment variable
    /// @param varName The name of the environment variable
    /// @return addr The address, or address(0) if unset
    function getAddressFromENV(string memory varName) internal view returns (address addr) {
        Vm vm = getVM();
        addr = parseAddress(vm.envOr(varName, string('UNSET')));

        if (addr != address(0) && codeSize(addr) == 0) {
            revert(string.concat(varName, ' has no code: ', vm.toString(addr)));
        }
    }

    /// @notice Creates an .Add FacetCut object for attaching a facet to a Diamond
    /// @dev This is a helper to reduce copy-paste code in the DeployLibs
    /// @param facet The address of the facet to attach
    /// @param selectors List of selectors
    /// @return cut The `Add` FacetCut object
    function facetCutGenerator(
        address facet,
        bytes4[] memory selectors
    ) internal pure returns (IDiamondCut.FacetCut memory cut) {
        cut = IDiamondCut.FacetCut({
            facetAddress: facet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: selectors
        });
    }

    /// @notice Assemble and execute a FacetCut to attach a facet to a diamond
    /// @dev This is a helper to reduce copy-paste code in the DeployLibs
    /// @param facetName The name of the facet (for logging)
    /// @param cut The FacetCut object
    /// @param diamond The address of the target diamond
    function cutFacetOntoDiamond(string memory facetName, IDiamondCut.FacetCut memory cut, address diamond) internal {
        console.log(string.concat('Attaching ', facetName, ' to Diamond: ', getVM().toString(diamond)));
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = cut;
        IDiamondCut(diamond).diamondCut(cuts, address(0), '');
    }

    /// @notice Loop over a list of selectors and remove them (by facet) from a diamond
    /// @dev This is a helper to reduce copy-paste code in the DeployLibs
    /// @param facetName The name of the facet (for logging)
    /// @param selectors List of selectors
    /// @param diamond The address of the target diamond
    function cutFacetOffOfDiamond(string memory facetName, bytes4[] memory selectors, address diamond) internal {
        console.log(string.concat('Removing ', facetName, ' from Diamond: ', getVM().toString(diamond)));
        // NOTE: this is a greedy cleanup - for all selectors in the list, their entire facet will be removed
        // This helps when an older facet has extra deprecated endpoints, but it can cause issues if unexpected
        for (uint256 i = 0; i < selectors.length; i++) {
            removeFacetBySelector(diamond, selectors[i]);
        }
    }

    /// @notice Remove a function selector from a diamond, if it exists, and all
    /// other functions provided by the same facet contract.
    /// @dev Only the Diamond owner can call this function
    /// @dev The DiamondLoupeFacet must be attached to the target diamond
    /// @param diamond The address of the target diamond
    /// @param functionSelector A 4-byte function selector
    /// @return facetRemoved True if the facet was present on the diamond, and detached
    function removeFacetBySelector(address diamond, bytes4 functionSelector) internal returns (bool facetRemoved) {
        address facet = getFacetBySelector(diamond, functionSelector);
        if (facet != address(0)) {
            DiamondCutFragment dc = DiamondCutFragment(diamond);
            dc.cutFacet(facet);
            return true;
        }
        return false;
    }

    /// @notice Returns the contract supplying a given function selector, on a target diamond.
    /// @dev The DiamondLoupeFacet must be attached to the target diamond
    /// @param diamond The address of the target diamond
    /// @param functionSelector The function selector
    /// @return facet The address of the facet providing the function on the diamond
    function getFacetBySelector(address diamond, bytes4 functionSelector) internal view returns (address facet) {
        DiamondLoupeFragment loupe = DiamondLoupeFragment(diamond);
        facet = loupe.facetAddress(functionSelector);
    }

    /// @notice Detaches a list of selectors from a target diamond.
    /// @dev Only the Diamond owner can call this function
    /// @dev The DiamondCutFacet.
    function removeSelectors(address diamond, bytes4[] memory selectors) internal {
        for (uint256 i = 0; i < selectors.length; i++) {
            require(selectors[i] != 0x1f931c1c, 'Cannot remove IDiamondCut.diamondCut.selector!');
        }

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: selectors
        });

        DiamondCutFragment dc = DiamondCutFragment(diamond);
        dc.diamondCut(cut, address(0), '');
    }

    /// @notice Parse a string into an address
    /// @dev If the string is "", "UNSET", "0", "0x", "0x0", or "0x0000000000000000000000000000000000000000", returns address(0)
    /// @param rawString The string to parse
    /// @return addr The parsed address, or address(0) if unset
    function parseAddress(string memory rawString) internal pure returns (address addr) {
        if (
            strEqual(rawString, 'UNSET') ||
            strEqual(rawString, '') || // This doesn't work reliably!
            strEqual(rawString, '0') ||
            strEqual(rawString, '0x') ||
            strEqual(rawString, '0x0') ||
            strEqual(rawString, '0x0000000000000000000000000000000000000000')
        ) {
            return address(0);
        } else {
            return getVM().parseAddress(rawString);
        }
    }

    /// @notice Returns the bytecode size of a target address
    /// @param target The target address
    /// @return size The bytecode size
    function codeSize(address target) internal view returns (uint256 size) {
        assembly {
            size := extcodesize(target)
        }
    }

    /// @notice Returns true if two strings are equal
    /// @param str1 The first string
    /// @param str2 The second string
    /// @return equal True if the strings are equal
    function strEqual(string memory str1, string memory str2) internal pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }
}
