// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {LibDiamond} from '../../src/libraries/LibDiamond.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';

contract LibDiamondTest is Test {
    MockLibDiamondFacet private mock;
    address private initialOwner;

    function setUp() public {
        initialOwner = address(1);
        mock = new MockLibDiamondFacet();
        mock.setContractOwner(initialOwner);
    }

    function testDiamondCutEvent(
        bytes4 fuzzSelector,
        address fuzzAddress1,
        address fuzzAddress2,
        address fuzzAddress3,
        bytes memory fuzzCalldata
    ) public {
        vm.assume(fuzzSelector != bytes4(0));
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(fuzzAddress2 != address(0));
        vm.assume(fuzzAddress3 != address(0));
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](2);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = fuzzSelector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: fuzzAddress1,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });
        cut[1] = IDiamondCut.FacetCut({
            facetAddress: fuzzAddress2,
            action: IDiamondCut.FacetCutAction.Replace,
            functionSelectors: functionSelectors
        });

        vm.expectEmit(true, true, true, false);
        emit LibDiamond.DiamondCut(cut, fuzzAddress3, fuzzCalldata);
        mock.emitDiamondCut(cut, fuzzAddress3, fuzzCalldata);
    }

    function testDIAMOND_STORAGE_POSITION() public pure {
        assertEq(LibDiamond.DIAMOND_STORAGE_POSITION, keccak256('diamond.standard.diamond.storage'));
        assertEq(
            LibDiamond.DIAMOND_STORAGE_POSITION,
            0xc8fcad8db84d3cc18b4c41d551ea0ee66dd599cde068d998e57d5e09332c131c
        );
    }

    function testFacetAddressAndPosition(
        address fuzzAddress1,
        uint96 fuzzInt1,
        address fuzzAddress2,
        uint96 fuzzInt2
    ) public pure {
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(fuzzInt1 != 0);
        vm.assume(fuzzAddress2 != address(0));
        vm.assume(fuzzInt2 != 0);
        LibDiamond.FacetAddressAndPosition memory fac = LibDiamond.FacetAddressAndPosition({
            facetAddress: fuzzAddress1,
            functionSelectorPosition: fuzzInt1
        });
        assertEq(fac.facetAddress, fuzzAddress1);
        assertEq(fac.functionSelectorPosition, fuzzInt1);
        fac.facetAddress = fuzzAddress2;
        fac.functionSelectorPosition = fuzzInt2;
        assertEq(fac.facetAddress, fuzzAddress2);
        assertEq(fac.functionSelectorPosition, fuzzInt2);
    }

    function testFacetFunctionSelectors(bytes4 fuzzSelector1, bytes4 fuzzSelector2, uint256 fuzzUint1) public pure {
        vm.assume(fuzzSelector1 != bytes4(0));
        vm.assume(fuzzSelector2 != bytes4(0));
        vm.assume(fuzzUint1 != 0);
        LibDiamond.FacetFunctionSelectors memory fac = LibDiamond.FacetFunctionSelectors({
            functionSelectors: new bytes4[](2),
            facetAddressPosition: fuzzUint1
        });

        assertEq(fac.functionSelectors.length, 2);
        assertEq(fac.functionSelectors[0], '');
        assertEq(fac.functionSelectors[1], '');
        fac.functionSelectors[0] = fuzzSelector1;
        fac.functionSelectors[1] = fuzzSelector2;
        assertEq(fac.functionSelectors[0], fuzzSelector1);
        assertEq(fac.functionSelectors[1], fuzzSelector2);
        assertEq(fac.facetAddressPosition, fuzzUint1);
    }

    function testEnforceIsContractOwner() public {
        vm.prank(initialOwner);
        mock.enforceIsContractOwner(); // This should succeed without reverting
    }

    function testEnforceIsContractOwnerFails() public {
        vm.expectRevert(LibContractOwner.CallerIsNotContractOwner.selector);
        vm.prank(address(99));
        mock.enforceIsContractOwner(); // This should succeed without reverting
    }

    //  NOTE - cut methods are tested through DiamondCutFacet and TestDiamondFactory

    function testEnforceHasContractCode() public view {
        // Call `enforceHasContractCode` with the address of the deployed contract
        // This should pass without reverting since `testContract` has code
        try mock.enforceHasContractCode(address(mock), 'No contract code at address') {
            // This block will execute if the call does not revert
        } catch {
            // If it reverts, fail the test
            assertFalse(true, 'enforceHasContractCode reverted, but the address has contract code');
        }
    }

    function testEnforceHasContractCodeWithoutContract() public {
        vm.expectRevert('error:foo');
        mock.enforceHasContractCode(0x513cC39E4782A2df83f6fC8998D11E0c1CA29ACb, 'error:foo');
    }
}

contract MockLibDiamondFacet {
    function emitDiamondCut(IDiamondCut.FacetCut[] calldata _diamondCut, address _init, bytes memory _calldata) public {
        emit LibDiamond.DiamondCut(_diamondCut, _init, _calldata);
    }

    function diamondStorage() internal pure returns (LibDiamond.DiamondStorage storage ds) {
        ds = LibDiamond.diamondStorage();
    }

    function setContractOwner(address newOwner) public {
        LibContractOwner.setContractOwner(newOwner);
    }

    function contractOwner() public view returns (address owner) {
        owner = LibContractOwner.contractOwner();
    }

    function enforceIsContractOwner() public view {
        LibDiamond.enforceIsContractOwner();
    }

    function diamondCut(IDiamondCut.FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) public {
        (_init); // noop
        (_calldata); // noop
        LibDiamond.diamondCut(_diamondCut);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) public {
        LibDiamond.addFunctions(_facetAddress, _functionSelectors);
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) public view {
        LibDiamond.enforceHasContractCode(_contract, _errorMessage);
    }

    // add this to be excluded from coverage report
    function test() public {}
}
