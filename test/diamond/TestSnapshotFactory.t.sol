// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from '../../lib/forge-std/src/Test.sol';

contract TestSnapshotFactory is Test {
    uint256 snapshotId;
    uint256 forkUrlLength;

    constructor() {
        string memory defaultForkUrl = '';
        string memory forkUrl = vm.envOr('TEST_FORK_RPC_URL', defaultForkUrl);
        bytes memory forkUrlBytes = bytes(forkUrl);
        if (forkUrlBytes.length > 0) {
            forkUrlLength = forkUrlBytes.length;
            uint256 mainnetFork = vm.createFork(forkUrl);
            vm.selectFork(mainnetFork);
            snapshotId = vm.snapshot();
        }
    }
}
