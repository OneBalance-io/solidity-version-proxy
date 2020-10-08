// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {IVersionBeacon} from "./VersionBeacon.sol";

/// @dev using EIP-1822 and EIP-1967 patterns
/// https://eips.ethereum.org/EIPS/eip-1822
/// https://eips.ethereum.org/EIPS/eip-1967
contract VersionProxy is Proxy {
	bytes32 private constant _BEACON_SLOT = bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1);
	bytes32 private constant _VERSION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.version")) - 1);
	bytes32 private constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

	// internal getters

	function _beacon() internal view returns (address beacon) {
		bytes32 slot = _BEACON_SLOT;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			beacon := sload(slot)
		}
	}

	function _version() internal view returns (uint256 version) {
		bytes32 slot = _VERSION_SLOT;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			version := sload(slot)
		}
	}

	// internal overrides

	function _implementation() internal override view returns (address implementation) {
		return IVersionBeacon(_beacon()).getImplementation(_version());
	}
}
