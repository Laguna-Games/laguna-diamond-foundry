// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {CutDiamond} from '../../src/diamond/CutDiamond.sol';
import {Diamond} from '../../src/diamond/LGDiamond.sol';
import {DiamondCutFacet} from '../../src/diamond/DiamondCutFacet.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {Test} from '../../lib/forge-std/src/Test.sol';
import {TestDiamondFactory} from '../diamond/TestDiamondFactory.sol';
import {TestSnapshotFactory} from './TestSnapshotFactory.t.sol';

contract LGDiamondTest is Test, TestSnapshotFactory {
    address owner = makeAddr('owner');

    function testInitialization() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        address payable diamond = payable(address(factory.gogogo(owner)));
        assertTrue(diamond.code.length > 0);

        assertEq(CutDiamond(diamond).owner(), owner);

        address diamondCutFacet = CutDiamond(diamond).facetAddress(DiamondCutFacet.cutSelector.selector);
        assertFalse(diamondCutFacet == address(0));

        vm.expectRevert(Diamond.DiamondAlreadyInitialized.selector);
        Diamond(diamond).initializeDiamond(diamondCutFacet);
    }

    function testFunctionCallDelegation() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        CutDiamond diamond = factory.gogogo(owner);
        TestFacet testFacet = new TestFacet();

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        IDiamondCut.FacetCut memory cut = IDiamondCut.FacetCut({
            facetAddress: address(testFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: new bytes4[](1)
        });
        cut.functionSelectors[0] = TestFacet.someFunction.selector;
        cuts[0] = cut;
        vm.prank(owner);
        diamond.diamondCut(cuts, address(0), '');

        // Call a function on the diamond that should be delegated to TestFacet
        (bool success, ) = address(diamond).call(abi.encodeWithSelector(TestFacet.someFunction.selector));
        assertTrue(success);
        // Optionally verify the state change or return value to ensure delegation worked
    }

    function testBadFunctionCallDelegation() public {
        TestDiamondFactory factory = new TestDiamondFactory();
        CutDiamond diamond = factory.gogogo(owner);

        vm.prank(owner);

        // Call a function on the diamond that should be delegated to TestFacet
        vm.expectRevert(Diamond.FunctionDoesNotExist.selector);
        (bool success, ) = address(diamond).call(abi.encodeWithSelector(TestFacet.someFunction.selector));
        assertFalse(success);
    }
}

contract TestFacet {
    function someFunction() external pure returns (bool) {
        return true;
    }
}
