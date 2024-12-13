// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// forge-ignore: 5574

import {Script} from '../lib/forge-std/src/Script.sol';
import {console} from '../lib/forge-std/src/Console.sol';
import {Diamond} from '../src/diamond/LGDiamond.sol';
import {LibDeploy, Deploy} from './util/LibDeploy.s.sol';

/// @title Diamond Deployer
/// @notice Deploys and initializes the diamond
/// @dev For direct usage, such as unit tests, use the LibDeploy library directly
contract Deployer is Script {
    /// @notice Deploy and initialize a new Diamond contract
    /// @dev This function BROADCASTS the transactions to the blockchain!
    function run() public {
        deployFullDiamond();
    }

    /// @notice Deploy and configure a new Diamond contract with DiamondCutFacet,
    /// DiamondLoupeFacet, DiamondOwnerFacet, DiamondProxyFacet, and SupportsInterfaceFacet.
    /// @dev Diamond owner will be the deployer wallet.
    /// @return deployment The deploy object
    function deployFullDiamond() public returns (Deploy memory deployment) {
        vm.startBroadcast();
        deployment = LibDeploy.deployFullDiamond();
        vm.stopBroadcast();
        return deployment;
    }

    /// @notice Deploy a new Diamond contract with DiamondCutFacet. No other facets are deployed.
    /// @dev Diamond owner will be the deployer wallet.
    /// @return deployment The deploy object
    function deployBlankDiamond() public returns (Deploy memory deployment) {
        vm.startBroadcast();
        deployment = LibDeploy.deployBlankDiamond();
        vm.stopBroadcast();
        return deployment;
    }

    /// @notice Deploy and attach utility facets to a naked Diamond contract.
    /// @dev Only the Diamond owner can call this function.
    /// @dev A Diamond contract needs to be deployed upstream, or specified in the DIAMOND env variable
    /// @return deployment The deploy object
    function upgradeBlankDiamondToFullDiamond() public returns (Deploy memory deployment) {
        vm.startBroadcast();
        deployment.diamond = LibDeploy.getDiamondFromEnvironment();
        deployment = LibDeploy.upgradeBlankDiamondToFullDiamond(deployment);
        deployment = LibDeploy.initializeSupportedInterfaces(deployment);
        deployment = LibDeploy.deployCutDiamondImplementation(deployment);
        vm.stopBroadcast();
        return deployment;
    }

    // add this to be excluded from coverage report
    function test() public {}
}
