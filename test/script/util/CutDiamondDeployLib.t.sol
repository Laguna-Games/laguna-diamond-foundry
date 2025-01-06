// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../../lib/forge-std/src/Test.sol';
import {console} from '../../../lib/forge-std/src/console.sol';
import {Vm} from '../../../lib/forge-std/src/Vm.sol';

import {Diamond} from '../../../src/diamond/LGDiamond.sol';
import {DiamondCutFacet} from '../../../src/diamond/DiamondCutFacet.sol';
import {DiamondLoupeFacet} from '../../../src/diamond/DiamondLoupeFacet.sol';
import {DiamondProxyFacet} from '../../../src/diamond/DiamondProxyFacet.sol';
import {IDiamondCut} from '../../../src/interfaces/IDiamondCut.sol';

import {DiamondCutDeployLib} from '../../../script/util/DiamondCutDeployLib.s.sol';
import {DiamondLoupeDeployLib} from '../../../script/util/DiamondLoupeDeployLib.s.sol';
import {DiamondProxyDeployLib} from '../../../script/util/DiamondProxyDeployLib.s.sol';
import {CutDiamondDeployLib} from '../../../script/util/CutDiamondDeployLib.s.sol';
import {LibDeploy} from '../../../script/util/LibDeploy.s.sol';

contract CutDiamondDeployLibTest is Test {
    bool constant TEST_ENVIRONMENT_VARIABLES = false; // If tests are randomly crashing, set this to false

    // address private owner = makeAddr('owner');

    function setUp() public {}

    function tearDown() public {}

    /// NOTE: This messes with global state in the environment variables
    /// This has a good chance of messing up other tests when running in parallel...
    function testGetInjectedOrNewImplementationInstancePrefersEnv() public {
        vm.skip(!TEST_ENVIRONMENT_VARIABLES); //  skip to avoid race conditions
        address implementation = CutDiamondDeployLib.deployNewInstance();
        assertNotEq(implementation, address(0), 'Implementation was not deployed');
        assertGt(LibDeploy.codeSize(implementation), 0, 'Implementation has no code');

        string memory originalValue = vm.envOr(CutDiamondDeployLib.ENV_NAME, string(''));
        vm.setEnv(CutDiamondDeployLib.ENV_NAME, vm.toString(implementation));
        address instance = CutDiamondDeployLib.getInjectedOrNewImplementationInstance();
        vm.setEnv(CutDiamondDeployLib.ENV_NAME, originalValue);

        assertEq(instance, implementation, 'Implementation address was not taken from ENV');
    }

    /// NOTE: This messes with global state in the environment variables
    /// This has a good chance of messing up other tests when running in parallel...
    function testGetInjectedOrNewImplementationInstanceRevertsOnEmptyAddress() public {
        vm.skip(!TEST_ENVIRONMENT_VARIABLES); //  skip to avoid race conditions
        address implementation = makeAddr('Implementation McImplementationface');
        assertNotEq(implementation, address(0), 'Implementation address failed to be created');
        assertEq(LibDeploy.codeSize(implementation), 0, 'Fake implementation should not have code');

        string memory originalValue = vm.envOr(CutDiamondDeployLib.ENV_NAME, string(''));
        vm.setEnv(CutDiamondDeployLib.ENV_NAME, vm.toString(implementation));
        vm.expectRevert(
            bytes(string.concat(CutDiamondDeployLib.ENV_NAME, ' has no code: ', vm.toString(implementation)))
        );
        CutDiamondDeployLib.getInjectedOrNewImplementationInstance();
        vm.setEnv(CutDiamondDeployLib.ENV_NAME, originalValue);
    }

    /// NOTE: This messes with global state in the environment variables
    /// This has a good chance of messing up other tests when running in parallel...
    function testGetInjectedOrNewImplementationInstance() public {
        vm.skip(!TEST_ENVIRONMENT_VARIABLES); //  skip to avoid race conditions
        string memory originalValue = vm.envOr(CutDiamondDeployLib.ENV_NAME, string(''));
        vm.setEnv(CutDiamondDeployLib.ENV_NAME, 'UNSET');
        string memory raw = vm.envOr(CutDiamondDeployLib.ENV_NAME, string('UNSET'));
        address instance = CutDiamondDeployLib.getInjectedOrNewImplementationInstance();
        vm.setEnv(CutDiamondDeployLib.ENV_NAME, originalValue);

        address control = LibDeploy.parseAddress('UNSET'); //  should be address(0)
        address env = LibDeploy.parseAddress(raw); //  should be address(0)

        assertEq(control, address(0), 'Control address was not address(0)');
        assertEq(env, address(0), 'env address was not address(0)'); //  This means the env var was not un-set, or got overwritten
        assertNotEq(instance, address(0), 'Implementation instance was not deployed');
    }

    function testDeployNewInstance() public {
        address implementation = CutDiamondDeployLib.deployNewInstance();
        assertNotEq(implementation, address(0), 'Implementation was not deployed');
        assertGt(LibDeploy.codeSize(implementation), 0, 'Implementation has no code');

        address implementation2 = CutDiamondDeployLib.deployNewInstance();
        assertNotEq(implementation2, address(0), 'Implementation was not deployed');
        assertGt(LibDeploy.codeSize(implementation2), 0, 'Implementation has no code');
        assertNotEq(implementation, implementation2, 'Implementation addresses were the same');

        assertEq(implementation.code.length, implementation2.code.length);
    }

    function testAttachFacetToDiamond() public {
        address diamondCutFacet = DiamondCutDeployLib.deployNewInstance();
        assertNotEq(diamondCutFacet, address(0), 'Facet was not deployed');
        address diamond = address(new Diamond(diamondCutFacet));
        address diamondProxyFacet = DiamondProxyDeployLib.deployNewInstance();
        DiamondProxyDeployLib.attachFacetToDiamond(diamond, diamondProxyFacet);

        DiamondProxyFacet proxy = DiamondProxyFacet(diamond);
        assertEq(proxy.implementation(), address(0), 'Implementation address was not address(0)');

        address implementation = CutDiamondDeployLib.deployNewInstance();
        assertGt(LibDeploy.codeSize(implementation), 0, 'Implementation has no code');
        proxy.setImplementation(implementation);
        assertEq(proxy.implementation(), implementation, 'Implementation address was not set');

        address implementation2 = CutDiamondDeployLib.deployNewInstance();
        assertNotEq(implementation2, address(0), 'Implementation2 was not deployed');
        assertNotEq(implementation, implementation2, 'Implementation addresses were the same');
        assertEq(
            LibDeploy.codeSize(implementation),
            LibDeploy.codeSize(implementation2),
            'Implementation contracts dont match'
        );
        proxy.setImplementation(implementation2);
        assertEq(proxy.implementation(), implementation2, 'Implementation2 address was not set');
    }
}
