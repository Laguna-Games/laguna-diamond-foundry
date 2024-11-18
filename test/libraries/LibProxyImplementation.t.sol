// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {LibProxyImplementation} from '../../src/libraries/LibProxyImplementation.sol';

contract LibProxyImplementationTest is Test {
    MockLibProxyImplementationFacet private mock;

    function setUp() public {
        mock = new MockLibProxyImplementationFacet();
    }

    function testUpgradedEvent(address fuzzAddress1) public {
        vm.expectEmit(true, true, false, false);
        emit LibProxyImplementation.Upgraded(fuzzAddress1);
        mock.emitUpgraded(fuzzAddress1);
    }

    function testERC_1967_SLOT_POSITION() public {
        assertEq(
            LibProxyImplementation.ERC_1967_SLOT_POSITION,
            0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
        );
        assertEq(
            LibProxyImplementation.ERC_1967_SLOT_POSITION,
            bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
        );
    }

    function testERC_1822_SLOT_POSITION() public {
        assertEq(
            LibProxyImplementation.ERC_1822_SLOT_POSITION,
            0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7
        );
        assertEq(LibProxyImplementation.ERC_1822_SLOT_POSITION, bytes32(keccak256('PROXIABLE')));
    }

    function testSetImplementation(address fuzzAddress1) public {
        vm.assume(fuzzAddress1 != address(0));

        assert(mock.getImplementation() == address(0));
        vm.expectEmit(true, true, false, false);
        emit LibProxyImplementation.Upgraded(fuzzAddress1);
        mock.setImplementation(fuzzAddress1);
        assertEq(mock.getImplementation(), fuzzAddress1);
        assertFalse(mock.getImplementation() == address(0));
    }

    function testImplementationParity(address fuzzAddress1) public {
        vm.assume(fuzzAddress1 != address(0));
        assert(mock.getImplementation() == address(0));
        mock.setImplementation(fuzzAddress1);
        assertEq(fuzzAddress1, mock.get1967Address());
        assertEq(fuzzAddress1, mock.get1822Address());
    }
}

contract MockLibProxyImplementationFacet {
    function emitUpgraded(address implementation) public {
        emit LibProxyImplementation.Upgraded(implementation);
    }

    function setImplementation(address newImplementation) public {
        LibProxyImplementation.setImplementation(newImplementation);
    }

    function getImplementation() public view returns (address implementation) {
        implementation = LibProxyImplementation.getImplementation();
    }

    function get1967Address() public view returns (address) {
        return LibProxyImplementation.proxyImplementationStorage1967().value;
    }

    function get1822Address() public view returns (address) {
        return LibProxyImplementation.proxyImplementationStorage1822().value;
    }

    // add this to be excluded from coverage report
    function test() public {}
}
