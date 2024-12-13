// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// forge-ignore: 5574

import {console} from '../../lib/forge-std/src/console.sol';
import {CutDiamond} from '../../src/diamond/CutDiamond.sol';
import {DiamondProxyFacet} from '../../src/diamond/DiamondProxyFacet.sol';
import {LibDeploy} from './LibDeploy.s.sol';

library CutDiamondDeployLib {
    string public constant IMPLEMENTATION_NAME = 'CutDiamond';
    string public constant ENV_NAME = 'CUT_DIAMOND_IMPLEMENTATION';

    /// @notice Returns the address of a deployed CutDiamond instance to use
    /// @dev Prefers the address from the CLI environment, otherwise deploys a fresh implementation
    /// @return implementation The address of the deployed implementation
    function getInjectedOrNewImplementationInstance() internal returns (address implementation) {
        implementation = LibDeploy.getAddressFromENV(ENV_NAME);

        if (implementation == address(0)) {
            implementation = deployNewInstance();
        } else {
            console.log(
                string.concat(
                    'Using pre-deployed ',
                    IMPLEMENTATION_NAME,
                    ': ',
                    LibDeploy.getVM().toString(implementation)
                )
            );
        }
    }

    /// @notice Deploys a new implementation instance
    /// @return implementation The address of the deployed implementation
    function deployNewInstance() internal returns (address implementation) {
        implementation = address(new CutDiamond());
        console.log(
            string.concat(
                string.concat('Deployed ', IMPLEMENTATION_NAME, ' at: ', LibDeploy.getVM().toString(implementation))
            )
        );
    }

    /// @notice Sets the implementation interface on a diamond
    /// @param diamond The address of the diamond to attach the facet to
    /// @param implementation The address of the implementation
    function setImplementationOnDiamond(address diamond, address implementation) internal {
        DiamondProxyFacet(diamond).setImplementation(implementation);
    }
}
