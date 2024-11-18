// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';
import {LibSupportsInterface} from '../../src/libraries/LibSupportsInterface.sol';
import {IERC165} from '../../src/interfaces/IERC165.sol';
import {IDiamondCut} from '../../src/interfaces/IDiamondCut.sol';
import {IDiamondLoupe} from '../../src/interfaces/IDiamondLoupe.sol';
import {IERC173} from '../../src/interfaces/IERC173.sol';

contract LibSupportsInterfaceTest is Test {
    MockLibSupportsInterfaceFacet private mock;

    function setUp() public {
        mock = new MockLibSupportsInterfaceFacet();
    }

    function testSUPPORTS_INTERFACE_STORAGE_POSITION() public {
        assertEq(
            LibSupportsInterface.SUPPORTS_INTERFACE_STORAGE_POSITION,
            keccak256(abi.encode(uint256(keccak256('games.laguna.LibSupportsInterface')) - 1)) & ~bytes32(uint256(0xff))
        );

        assertEq(
            LibSupportsInterface.SUPPORTS_INTERFACE_STORAGE_POSITION,
            0xf70528b1d142fe724b35f8622f20c0b2faf624d01a6459aa36ab9dc422a11300
        );

        assertEq(
            keccak256(abi.encode(uint256(keccak256('games.laguna.LibSupportsInterface')) - 1)) &
                ~bytes32(uint256(0xff)),
            0xf70528b1d142fe724b35f8622f20c0b2faf624d01a6459aa36ab9dc422a11300
        );
    }

    function testSupportsInterface(bytes4 fuzzSelector) public {
        vm.assume(fuzzSelector != bytes4(0));

        assert(mock.supportsInterface(fuzzSelector) == false);
        mock.setSupportsInterface(fuzzSelector, true);
        assert(mock.supportsInterface(fuzzSelector) == true);
    }

    function testCalculateInterfaceId() public {
        bytes4[] memory erc165Selectors = new bytes4[](1);
        erc165Selectors[0] = IERC165.supportsInterface.selector;
        assertEq(LibSupportsInterface.calculateInterfaceId(erc165Selectors), type(IERC165).interfaceId);
        assertEq(LibSupportsInterface.calculateInterfaceId(erc165Selectors), bytes4(0x01ffc9a7));

        bytes4[] memory iDiamondCutSelectors = new bytes4[](1);
        iDiamondCutSelectors[0] = IDiamondCut.diamondCut.selector;
        assertEq(LibSupportsInterface.calculateInterfaceId(iDiamondCutSelectors), type(IDiamondCut).interfaceId);
        assertEq(LibSupportsInterface.calculateInterfaceId(iDiamondCutSelectors), bytes4(0x1f931c1c));

        bytes4[] memory iDiamondLoupeSelectors = new bytes4[](4);
        iDiamondLoupeSelectors[0] = IDiamondLoupe.facets.selector;
        iDiamondLoupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        iDiamondLoupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        iDiamondLoupeSelectors[3] = IDiamondLoupe.facetAddress.selector;
        assertEq(LibSupportsInterface.calculateInterfaceId(iDiamondLoupeSelectors), type(IDiamondLoupe).interfaceId);
        assertEq(LibSupportsInterface.calculateInterfaceId(iDiamondLoupeSelectors), bytes4(0x48e2b093));

        bytes4[] memory erc173Selectors = new bytes4[](2);
        erc173Selectors[0] = IERC173.owner.selector;
        erc173Selectors[1] = IERC173.transferOwnership.selector;
        assertEq(LibSupportsInterface.calculateInterfaceId(erc173Selectors), type(IERC173).interfaceId);
        assertEq(LibSupportsInterface.calculateInterfaceId(erc173Selectors), bytes4(0x7f5828d0));
    }
}

contract MockLibSupportsInterfaceFacet {
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return LibSupportsInterface.supportsInterface(interfaceId);
    }

    function setSupportsInterface(bytes4 interfaceId, bool implemented) public {
        LibSupportsInterface.setSupportsInterface(interfaceId, implemented);
    }

    // add this to be excluded from coverage report
    function test() public {}
}
