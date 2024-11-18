// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {LibContractOwner} from '../../src/libraries/LibContractOwner.sol';

contract LibContractOwnerTest is Test {
    MockLibContractOwnerFacet private mock;
    address private initialOwner;

    function setUp() public {
        initialOwner = address(1);
        mock = new MockLibContractOwnerFacet();
        mock.setContractOwner(initialOwner);
    }

    function testOwnershipTransferredEvent(address fuzzAddress1, address fuzzAddress2) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(fuzzAddress2 != address(0));
        vm.expectEmit(true, true, false, false);
        emit LibContractOwner.OwnershipTransferred(fuzzAddress1, fuzzAddress2);
        mock.emitOwnershipTransferred(fuzzAddress1, fuzzAddress2);
    }

    function testAdminChangedEvent(address fuzzAddress1, address fuzzAddress2) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(fuzzAddress2 != address(0));
        vm.expectEmit(true, true, true, false);
        emit LibContractOwner.AdminChanged(fuzzAddress1, fuzzAddress2);
        mock.emitAdminChanged(fuzzAddress1, fuzzAddress2);
    }

    function testSetContractOwner(address fuzzAddress1) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(fuzzAddress1 != initialOwner);
        assert(mock.contractOwner() == initialOwner);
        address previousOwner = mock.contractOwner();
        assertEq(previousOwner, initialOwner);
        address newOwner = fuzzAddress1;

        // Listen for the OwnershipTransferred event...
        vm.expectEmit(true, true, false, false);
        emit LibContractOwner.OwnershipTransferred(previousOwner, newOwner);

        // Trigger the setContractOwner change
        mock.setContractOwner(newOwner);

        assertEq(mock.contractOwner(), newOwner);
        assertFalse(previousOwner == newOwner, 'Ownership not changed');
    }

    function testContractOwner() public {
        assert(mock.contractOwner() == initialOwner);
        assertFalse(mock.contractOwner() == address(0), 'Contract owner should not be address(0)');
    }

    function testEnforceIsContractOwner() public {
        // Simulate call from initialOwner
        vm.prank(initialOwner);
        mock.enforceIsContractOwner(); // This should succeed without reverting
    }

    function testEnforceIsContractOwnerFails(address fuzzAddress1) public {
        vm.assume(fuzzAddress1 != address(0));
        vm.assume(fuzzAddress1 != initialOwner);
        vm.expectRevert(LibContractOwner.CallerIsNotContractOwner.selector);
        vm.prank(fuzzAddress1);
        mock.enforceIsContractOwner(); // This should succeed without reverting
    }
}

contract MockLibContractOwnerFacet {
    function emitOwnershipTransferred(address previousOwner, address newOwner) public {
        emit LibContractOwner.OwnershipTransferred(previousOwner, newOwner);
    }

    function emitAdminChanged(address previousAdmin, address newAdmin) public {
        emit LibContractOwner.AdminChanged(previousAdmin, newAdmin);
    }

    function setContractOwner(address newOwner) public {
        LibContractOwner.setContractOwner(newOwner);
    }

    function contractOwner() public view returns (address owner) {
        owner = LibContractOwner.contractOwner();
    }

    function enforceIsContractOwner() public view {
        LibContractOwner.enforceIsContractOwner();
    }

    // add this to be excluded from coverage report
    function test() public {}
}
