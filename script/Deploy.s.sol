// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
// forge-ignore: 5574

import {Script} from '../lib/forge-std/src/Script.sol';
import {console} from '../lib/forge-std/src/Console.sol';

import {Diamond} from '../src/diamond/LGDiamond.sol';
import {CutDiamond} from '../src/diamond/CutDiamond.sol';
import {DiamondCutFacet} from '../src/diamond/DiamondCutFacet.sol';
import {DiamondLoupeFacet} from '../src/diamond/DiamondLoupeFacet.sol';
import {DiamondOwnerFacet} from '../src/diamond/DiamondOwnerFacet.sol';
import {DiamondProxyFacet} from '../src/diamond/DiamondProxyFacet.sol';
import {SupportsInterfaceFacet} from '../src/diamond/SupportsInterfaceFacet.sol';
import {LibDeploy} from './LibDeploy.s.sol';
import {DiamondCutFacetUtil} from './DiamondCutFacetUtil.s.sol';
import {DiamondLoupeFacetUtil} from './DiamondLoupeFacetUtil.s.sol';
import {DiamondOwnerFacetUtil} from './DiamondOwnerFacetUtil.s.sol';
import {DiamondProxyFacetUtil} from './DiamondProxyFacetUtil.s.sol';
import {SupportsInterfaceFacetUtil} from './SupportsInterfaceFacetUtil.s.sol';
import {IDiamondCut} from '../src/interfaces/IDiamondCut.sol';
import {IDiamondLoupe} from '../src/interfaces/IDiamondLoupe.sol';
import {IERC165} from '../src/interfaces/IERC165.sol';
import {IERC173} from '../src/interfaces/IERC173.sol';
import {EIP5313} from '../src/interfaces/IERC173.sol';

/// @title Diamond Deployer
/// @notice Deploys and initializes the diamond
contract Deployer is Script {
    address public deployer;

    DiamondCutFacetUtil diamondCutFacetUtil = new DiamondCutFacetUtil();
    DiamondLoupeFacetUtil diamondLoupeFacetUtil = new DiamondLoupeFacetUtil();
    DiamondOwnerFacetUtil diamondOwnerFacetUtil = new DiamondOwnerFacetUtil();
    DiamondProxyFacetUtil diamondProxyFacetUtil = new DiamondProxyFacetUtil();
    SupportsInterfaceFacetUtil supportsInterfaceFacetUtil = new SupportsInterfaceFacetUtil();

    address public diamondOwner;
    address public diamond;
    address public diamondCutFacet;
    address public diamondLoupeFacet;
    address public diamondOwnerFacet;
    address public diamondProxyFacet;
    address public supportsInterfaceFacet;

    address public implementation;

    // function setUp() public {}

    function run() public {
        vm.startBroadcast();
        deployFullDiamond();
        vm.stopBroadcast();
    }

    /// @notice Deploy and configure a new Diamond contract with DiamondCutFacet,
    /// DiamondLoupeFacet, DiamondOwnerFacet, DiamondProxyFacet, and SupportsInterfaceFacet.
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Diamond owner will be the deployer wallet.
    /// @return The address of the deployed Diamond
    function deployFullDiamond() public returns (address) {
        diamond = deployBlankDiamond();
        upgradeBlankDiamondToFullDiamond();
        initializeSupportedInterfaces();
        return diamond;
    }

    /// @notice Deploy a new Diamond contract with DiamondCutFacet. No other facets are deployed.
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Diamond owner will be the deployer wallet.
    /// @return The address of the deployed Diamond
    function deployBlankDiamond() public returns (address) {
        diamondCutFacet = diamondCutFacetUtil.getOrDeployFacet();
        diamond = address(new Diamond(diamondCutFacet));
        console.log(string.concat('Deployed new Diamond at: ', vm.toString(diamond)));
        return diamond;
    }

    /// @notice Deploy and attach utility facets to a naked Diamond contract.
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Only the Diamond owner can call this function.
    /// @dev A Diamond contract needs to be deployed upstream, or specified in the DIAMOND env variable
    function upgradeBlankDiamondToFullDiamond() public {
        if (diamond == address(0)) LibDeploy.getDiamondFromEnvironment();

        diamondCutFacet = diamondCutFacetUtil.getOrDeployFacet();
        diamondLoupeFacet = diamondLoupeFacetUtil.getOrDeployFacet();
        diamondOwnerFacet = diamondOwnerFacetUtil.getOrDeployFacet();
        diamondProxyFacet = diamondProxyFacetUtil.getOrDeployFacet();
        supportsInterfaceFacet = supportsInterfaceFacetUtil.getOrDeployFacet();

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](5);
        cuts[0] = diamondCutFacetUtil.generateCut(diamondCutFacet);
        cuts[1] = diamondLoupeFacetUtil.generateCut(diamondLoupeFacet);
        cuts[2] = diamondOwnerFacetUtil.generateCut(diamondOwnerFacet);
        cuts[3] = diamondProxyFacetUtil.generateCut(diamondProxyFacet);
        cuts[4] = supportsInterfaceFacetUtil.generateCut(supportsInterfaceFacet);

        //  There's a chance this blows up if the Diamond has a different owner than the deployer,
        //  but we can't check for this until the DiamondOwnerFacet is attached so...
        console.log(string.concat('Attaching facets to Diamond: ', vm.toString(diamond)));
        IDiamondCut(diamond).diamondCut(cuts, address(0), '');
    }

    /// @notice Initialize the SupportsInterfaceFacet with the default diamond interfaces
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Only the Diamond owner can call this function.
    /// @dev A Diamond contract needs to be deployed upstream, or specified in the DIAMOND env variable
    function initializeSupportedInterfaces() public {
        if (diamond == address(0)) LibDeploy.getDiamondFromEnvironment();

        bytes4[] memory interfaceIds = new bytes4[](5);
        interfaceIds[0] = type(IERC165).interfaceId; // 0x01ffc9a7
        interfaceIds[1] = type(IDiamondCut).interfaceId; // 0x1f931c1c
        interfaceIds[2] = type(IDiamondLoupe).interfaceId; // 0x48e2b093
        interfaceIds[3] = type(IERC173).interfaceId; // 0x7f5828d0
        interfaceIds[4] = type(EIP5313).interfaceId; // 0x8da5cb5b

        console.logString('Setting supportsInterface selectors...');
        SupportsInterfaceFacet(diamond).setSupportsInterfaces(interfaceIds, true);
    }

    /// @notice Deploy a new "CutDiamond" contract to act as a unified interface (ERC-1967) for the Diamond
    /// @dev This function needs to be wrapped in a vm.startBroadcast() and vm.stopBroadcast() call
    /// @dev Only the Diamond owner can call this function.
    /// @dev Specify the Implementation address in the IMPLEMENTATION_CONTRACT env var
    /// @dev A Diamond contract needs to be deployed upstream, or specified in the DIAMOND env variable
    /// @return implementation The address of the deployed CutDiamond interface contract
    function deployCutDiamondImplementation() public returns (address) {
        if (diamond == address(0)) LibDeploy.getDiamondFromEnvironment();
        if (implementation == address(0)) implementation = vm.envOr('IMPLEMENTATION_CONTRACT', address(0));
        if (implementation == address(0)) {
            implementation = address(new CutDiamond());
            console.log(string.concat('Deployed CutDiamond interface at: ', vm.toString(implementation)));
        } else if (implementation.code.length == 0) {
            revert(string.concat('IMPLEMENTATION_CONTRACT has no code: ', vm.toString(implementation)));
        } else {
            console.log(
                string.concat('Using pre-deployed CutDiamond interface contract: ', vm.toString(implementation))
            );
        }

        console.log('Setting CutDiamond implementation...');
        CutDiamond(diamond).setImplementation(implementation);
    }
}
