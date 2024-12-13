// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {console} from '../../lib/forge-std/src/console.sol';
import {Vm} from 'forge-std/Vm.sol';

import {Deployer} from '../../script/Deploy.s.sol';
import {LibDiamond} from '../../src/libraries/LibDiamond.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {DiamondCutFacet} from '../../src/diamond/DiamondCutFacet.sol';
import {DiamondLoupeFacet} from '../../src/diamond/DiamondLoupeFacet.sol';
import {DiamondOwnerFacet} from '../../src/diamond/DiamondOwnerFacet.sol';
import {DiamondProxyFacet} from '../../src/diamond/DiamondProxyFacet.sol';
import {SupportsInterfaceFacet} from '../../src/diamond/SupportsInterfaceFacet.sol';
import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';

// import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
// import {DiamondLoupeFacet} from '../../src/diamond/DiamondLoupeFacet.sol';
// import {LibDiamond} from '../../src/libraries/LibDiamond.sol';
// import {TestDiamondFactory} from './TestDiamondFactory.sol';
// import {CutDiamond} from '../../src/diamond/CutDiamond.sol';
// import {TestSnapshotFactory} from '../diamond/TestSnapshotFactory.t.sol';

// import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';

contract DeployerTest is Test {
    address private owner = makeAddr('owner'); // 0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
    Deployer private deployer;

    string private originalDiamondCutFacet;
    string private originalDiamondLoupeFacet;
    string private originalDiamondOwnerFacet;
    string private originalDiamondProxyFacet;
    string private originalSupportsInterfaceFacet;

    function setUp() public {
        // originalDiamondCutFacet = vm.envOr('DIAMOND_CUT_FACET', string(''));
        // originalDiamondLoupeFacet = vm.envOr('DIAMOND_LOUPE_FACET', string(''));
        // originalDiamondOwnerFacet = vm.envOr('DIAMOND_OWNER_FACET', string(''));
        // originalDiamondProxyFacet = vm.envOr('DIAMOND_PROXY_FACET', string(''));
        // originalSupportsInterfaceFacet = vm.envOr('SUPPORTS_INTERFACE_FACET', string(''));
        vm.prank(owner);

        deployer = new Deployer();
        console.log(string.concat('deployer script: ', vm.toString(address(deployer))));
    }

    function tearDown() public {
        // Restore the original value after each test
        // vm.setEnv('DIAMOND_CUT_FACET', originalDiamondCutFacet);
        // vm.setEnv('DIAMOND_LOUPE_FACET', originalDiamondLoupeFacet);
        // vm.setEnv('DIAMOND_OWNER_FACET', originalDiamondOwnerFacet);
        // vm.setEnv('DIAMOND_PROXY_FACET', originalDiamondProxyFacet);
        // vm.setEnv('SUPPORTS_INTERFACE_FACET', originalSupportsInterfaceFacet);
    }

    // function testdeployBlankDiamond() public {
    //     vm.startPrank(owner);
    //     vm.recordLogs();
    //     deployer.deployBlankDiamond();
    //     console.log(string.concat('owner: ', vm.toString(owner)));

    //     // address diamond = deployer.deployBlankDiamond();

    //     // uint256 codeSize;
    //     // assembly {
    //     //     codeSize := extcodesize(diamond)
    //     // }

    //     // assertNotEq(diamond, address(0), 'Diamond has no address');
    //     // assertGt(codeSize, 0, 'Diamond has no extcodesize');

    //     Vm.Log[] memory logs = vm.getRecordedLogs();

    //     for (uint256 i = 0; i < logs.length; i++) {
    //         // if (logs[i].topics[0] == LibDiamond.DiamondCut.selector) {
    //         //     (IDiamondCut.FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) = abi.decode(
    //         //         logs[i].data,
    //         //         (IDiamondCut.FacetCut[], address, bytes)
    //         //     );
    //         //     assertEq(_diamondCut.length, 1, 'Only one FacetCut allowed (diamondCut)');
    //         //     assertNotEq(_diamondCut[0].facetAddress, address(0), 'DiamondCut facet address must be non-zero');
    //         //     assertEq(uint(_diamondCut[0].action), uint(IDiamondCut.FacetCutAction.Add), 'Action must be `Add`');
    //         //     assertEq(
    //         //         bytes4(_diamondCut[0].functionSelectors[0]),
    //         //         bytes4(0x1f931c1c),
    //         //         'Function selector must be diamondCut'
    //         //     );
    //         //     assertEq(_init, address(0), 'No init address allowed');
    //         //     assertEq(_calldata, bytes(''), 'No init calldata allowed');
    //         // }

    //         if (logs[i].topics[0] == LibContractOwner.OwnershipTransferred.selector) {
    //             address previousOwner = address(uint160(uint256(logs[i].topics[1])));
    //             address newOwner = address(uint160(uint256(logs[i].topics[2])));

    //             console.log(
    //                 string.concat('OwnershipTransferred: ', vm.toString(previousOwner), ' -> ', vm.toString(newOwner))
    //             );

    //             assertEq(previousOwner, address(0), 'OwnershipTransferred previousOwner must be zero');
    //             assertEq(newOwner, owner, 'OwnershipTransferred newOwner must be owner');
    //         }
    //     }

    //     vm.stopPrank();
    // }

    // function testDeployDiamondCutFacet() public {
    //     // The deploy function shouldn't change the Deployer state
    //     assertEq(deployer.diamondCutFacet(), address(0));
    //     deployer.getOrDeployFacet();
    //     assertEq(deployer.diamondCutFacet(), address(0));

    //     // It does deploy a new contract
    //     address f = deployer.deployDiamondCutFacet();
    //     assertNotEq(f, address(0));
    //     assertEq(deployer.diamondCutFacet(), address(0));

    //     // Multipe calls should return new instances
    //     address g = deployer.deployDiamondCutFacet();
    //     assertNotEq(g, address(0));
    //     assertNotEq(f, g);
    //     assertEq(deployer.diamondCutFacet(), address(0));
    // }

    // function testDeployDiamondLoupeFacet() public {
    //     // The deploy function shouldn't change the Deployer state
    //     assertEq(deployer.diamondLoupeFacet(), address(0));
    //     deployer.deployDiamondLoupeFacet();
    //     assertEq(deployer.diamondLoupeFacet(), address(0));

    //     // It does deploy a new contract
    //     address f = deployer.deployDiamondLoupeFacet();
    //     assertNotEq(f, address(0));
    //     assertEq(deployer.diamondLoupeFacet(), address(0));

    //     // Multipe calls should return new instances
    //     address g = deployer.deployDiamondLoupeFacet();
    //     assertNotEq(g, address(0));
    //     assertNotEq(f, g);
    //     assertEq(deployer.diamondLoupeFacet(), address(0));
    // }

    // function testDeployDiamondOwnerFacet() public {
    //     // The deploy function shouldn't change the Deployer state
    //     assertEq(deployer.diamondOwnerFacet(), address(0));
    //     deployer.deployDiamondOwnerFacet();
    //     assertEq(deployer.diamondOwnerFacet(), address(0));

    //     // It does deploy a new contract
    //     address f = deployer.deployDiamondOwnerFacet();
    //     assertNotEq(f, address(0));
    //     assertEq(deployer.diamondOwnerFacet(), address(0));

    //     // Multipe calls should return new instances
    //     address g = deployer.deployDiamondOwnerFacet();
    //     assertNotEq(g, address(0));
    //     assertNotEq(f, g);
    //     assertEq(deployer.diamondOwnerFacet(), address(0));
    // }

    // function testDeployDiamondProxyFacet() public {
    //     // The deploy function shouldn't change the Deployer state
    //     assertEq(deployer.diamondProxyFacet(), address(0));
    //     deployer.deployDiamondProxyFacet();
    //     assertEq(deployer.diamondProxyFacet(), address(0));

    //     // It does deploy a new contract
    //     address f = deployer.deployDiamondProxyFacet();
    //     assertNotEq(f, address(0));
    //     assertEq(deployer.diamondProxyFacet(), address(0));

    //     // Multipe calls should return new instances
    //     address g = deployer.deployDiamondProxyFacet();
    //     assertNotEq(g, address(0));
    //     assertNotEq(f, g);
    //     assertEq(deployer.diamondProxyFacet(), address(0));
    // }

    // function testDeploySupportsInterfaceFacet() public {
    //     // The deploy function shouldn't change the Deployer state
    //     assertEq(deployer.supportsInterfaceFacet(), address(0));
    //     deployer.deploySupportsInterfaceFacet();
    //     assertEq(deployer.supportsInterfaceFacet(), address(0));

    //     // It does deploy a new contract
    //     address f = deployer.deploySupportsInterfaceFacet();
    //     assertNotEq(f, address(0));
    //     assertEq(deployer.supportsInterfaceFacet(), address(0));

    //     // Multipe calls should return new instances
    //     address g = deployer.deploySupportsInterfaceFacet();
    //     assertNotEq(g, address(0));
    //     assertNotEq(f, g);
    //     assertEq(deployer.supportsInterfaceFacet(), address(0));
    // }

    // function testGetOrDeployDiamondCutFacet() public {
    //     vm.setEnv('DIAMOND_CUT_FACET', ''); //  unset

    //     //  if no DiamondCutFacet deployed, deploy and return a new one
    //     Deployer d = new Deployer();
    //     assertEq(d.diamondCutFacet(), address(0));
    //     address facet = d.getOrDeployDiamondCutFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(d.diamondCutFacet(), facet);

    //     //  if a DiamondCutFacet is already in use, return it
    //     assertEq(d.diamondCutFacet(), facet);
    //     facet = d.getOrDeployDiamondCutFacet();
    //     assertEq(d.diamondCutFacet(), facet);

    //     //  Use the DIAMOND_CUT_FACET env var instead of deploying fresh
    //     address outsideFacet = address(new DiamondCutFacet());
    //     vm.setEnv('DIAMOND_CUT_FACET', vm.toString(outsideFacet));
    //     Deployer d2 = new Deployer();
    //     assertEq(d2.diamondCutFacet(), address(0));
    //     facet = d2.getOrDeployDiamondCutFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(facet, outsideFacet);
    //     assertEq(d2.diamondCutFacet(), facet);

    //     //  revert if DIAMOND_CUT_FACET is populated with an invalid address
    //     address badPresetAddress = makeAddr('foo');
    //     vm.setEnv('DIAMOND_CUT_FACET', vm.toString(badPresetAddress));
    //     Deployer d3 = new Deployer();
    //     assertEq(d3.diamondCutFacet(), address(0));
    //     vm.expectRevert(bytes(string.concat('DiamondCutFacet has no code: ', vm.toString(badPresetAddress))));
    //     facet = d3.getOrDeployDiamondCutFacet();
    //     assertEq(d3.diamondCutFacet(), address(0));
    // }

    // function testGetOrDeployDiamondLoupeFacet() public {
    //     vm.setEnv('DIAMOND_LOUPE_FACET', ''); //  unset

    //     //  if no DiamondLoupeFacet deployed, deploy and return a new one
    //     Deployer d = new Deployer();
    //     assertEq(d.diamondLoupeFacet(), address(0));
    //     address facet = d.getOrDeployDiamondLoupeFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(d.diamondLoupeFacet(), facet);

    //     //  if a DiamondLoupeFacet is already in use, return it
    //     assertEq(d.diamondLoupeFacet(), facet);
    //     facet = d.getOrDeployDiamondLoupeFacet();
    //     assertEq(d.diamondLoupeFacet(), facet);

    //     //  Use the DIAMOND_LOUPE_FACET env var instead of deploying fresh
    //     address outsideFacet = address(new DiamondLoupeFacet());
    //     vm.setEnv('DIAMOND_LOUPE_FACET', vm.toString(outsideFacet));
    //     Deployer d2 = new Deployer();
    //     assertEq(d2.diamondLoupeFacet(), address(0));
    //     facet = d2.getOrDeployDiamondLoupeFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(facet, outsideFacet);
    //     assertEq(d2.diamondLoupeFacet(), facet);

    //     //  revert if DIAMOND_LOUPE_FACET is populated with an invalid address
    //     address badPresetAddress = makeAddr('foo');
    //     vm.setEnv('DIAMOND_LOUPE_FACET', vm.toString(badPresetAddress));
    //     Deployer d3 = new Deployer();
    //     assertEq(d3.diamondLoupeFacet(), address(0));
    //     vm.expectRevert(bytes(string.concat('DiamondLoupeFacet has no code: ', vm.toString(badPresetAddress))));
    //     facet = d3.getOrDeployDiamondLoupeFacet();
    //     assertEq(d3.diamondLoupeFacet(), address(0));
    // }

    // function testGetOrDeployDiamondProxyFacet() public {
    //     vm.setEnv('DIAMOND_PROXY_FACET', ''); //  unset

    //     //  if no DiamondProxyFacet deployed, deploy and return a new one
    //     Deployer d = new Deployer();
    //     assertEq(d.diamondProxyFacet(), address(0));
    //     address facet = d.getOrDeployDiamondProxyFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(d.diamondProxyFacet(), facet);

    //     //  if a DiamondProxyFacet is already in use, return it
    //     assertEq(d.diamondProxyFacet(), facet);
    //     facet = d.getOrDeployDiamondProxyFacet();
    //     assertEq(d.diamondProxyFacet(), facet);

    //     //  Use the DIAMOND_PROXY_FACET env var instead of deploying fresh
    //     address outsideFacet = address(new DiamondProxyFacet());
    //     vm.setEnv('DIAMOND_PROXY_FACET', vm.toString(outsideFacet));
    //     Deployer d2 = new Deployer();
    //     assertEq(d2.diamondProxyFacet(), address(0));
    //     facet = d2.getOrDeployDiamondProxyFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(facet, outsideFacet);
    //     assertEq(d2.diamondProxyFacet(), facet);

    //     //  revert if DIAMOND_PROXY_FACET is populated with an invalid address
    //     address badPresetAddress = makeAddr('foo');
    //     vm.setEnv('DIAMOND_PROXY_FACET', vm.toString(badPresetAddress));
    //     Deployer d3 = new Deployer();
    //     assertEq(d3.diamondProxyFacet(), address(0));
    //     vm.expectRevert(bytes(string.concat('DiamondProxyFacet has no code: ', vm.toString(badPresetAddress))));
    //     facet = d3.getOrDeployDiamondProxyFacet();
    //     assertEq(d3.diamondProxyFacet(), address(0));
    // }

    // function testGetOrDeployDiamondOwnerFacet() public {
    //     vm.setEnv('DIAMOND_OWNER_FACET', ''); //  unset

    //     //  if no DiamondOwnerFacet deployed, deploy and return a new one
    //     Deployer d = new Deployer();
    //     assertEq(d.diamondOwnerFacet(), address(0));
    //     address facet = d.getOrDeployDiamondOwnerFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(d.diamondOwnerFacet(), facet);

    //     //  if a DiamondOwnerFacet is already in use, return it
    //     assertEq(d.diamondOwnerFacet(), facet);
    //     facet = d.getOrDeployDiamondOwnerFacet();
    //     assertEq(d.diamondOwnerFacet(), facet);

    //     //  Use the DIAMOND_OWNER_FACET env var instead of deploying fresh
    //     address outsideFacet = address(new DiamondOwnerFacet());
    //     vm.setEnv('DIAMOND_OWNER_FACET', vm.toString(outsideFacet));
    //     Deployer d2 = new Deployer();
    //     assertEq(d2.diamondOwnerFacet(), address(0));
    //     facet = d2.getOrDeployDiamondOwnerFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(facet, outsideFacet);
    //     assertEq(d2.diamondOwnerFacet(), facet);

    //     //  revert if DIAMOND_OWNER_FACET is populated with an invalid address
    //     address badPresetAddress = makeAddr('foo');
    //     vm.setEnv('DIAMOND_OWNER_FACET', vm.toString(badPresetAddress));
    //     Deployer d3 = new Deployer();
    //     assertEq(d3.diamondOwnerFacet(), address(0));
    //     vm.expectRevert(bytes(string.concat('DiamondOwnerFacet has no code: ', vm.toString(badPresetAddress))));
    //     facet = d3.getOrDeployDiamondOwnerFacet();
    //     assertEq(d3.diamondOwnerFacet(), address(0));
    // }

    // function testGetOrDeploySupportsInterfaceFacet() public {
    //     vm.setEnv('SUPPORTS_INTERFACE_FACET', ''); //  unset

    //     //  if no SupportsInterfaceFacet deployed, deploy and return a new one
    //     Deployer d = new Deployer();
    //     assertEq(d.supportsInterfaceFacet(), address(0));
    //     address facet = d.getOrDeploySupportsInterfaceFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(d.supportsInterfaceFacet(), facet);

    //     //  if a SupportsInterfaceFacet is already in use, return it
    //     assertEq(d.supportsInterfaceFacet(), facet);
    //     facet = d.getOrDeploySupportsInterfaceFacet();
    //     assertEq(d.supportsInterfaceFacet(), facet);

    //     //  Use the SUPPORTS_INTERFACE_FACET env var instead of deploying fresh
    //     address outsideFacet = address(new SupportsInterfaceFacet());
    //     vm.setEnv('SUPPORTS_INTERFACE_FACET', vm.toString(outsideFacet));
    //     Deployer d2 = new Deployer();
    //     assertEq(d2.supportsInterfaceFacet(), address(0));
    //     facet = d2.getOrDeploySupportsInterfaceFacet();
    //     assertNotEq(facet, address(0));
    //     assertEq(facet, outsideFacet);
    //     assertEq(d2.supportsInterfaceFacet(), facet);

    //     //  revert if SUPPORTS_INTERFACE_FACET is populated with an invalid address
    //     address badPresetAddress = makeAddr('foo');
    //     vm.setEnv('SUPPORTS_INTERFACE_FACET', vm.toString(badPresetAddress));
    //     Deployer d3 = new Deployer();
    //     assertEq(d3.supportsInterfaceFacet(), address(0));
    //     vm.expectRevert(bytes(string.concat('SupportsInterfaceFacet has no code: ', vm.toString(badPresetAddress))));
    //     facet = d3.getOrDeploySupportsInterfaceFacet();
    //     assertEq(d3.supportsInterfaceFacet(), address(0));
    // }
}
