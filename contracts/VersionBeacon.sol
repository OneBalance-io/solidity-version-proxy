// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

interface IVersionBeacon {
	function getImplementation(uint256 version) external view returns (address implementation);

	function getLatestVersion() external view returns (uint256 latest);
}

contract VersionBeacon is IVersionBeacon, Ownable {
	mapping(uint256 => address) private _implementations;
	uint256 private _latest;

	constructor(address implementation) public {
		_upgrade(implementation);
	}

	// external setters

	function upgrade(address newImplementation) external onlyOwner {
		_upgrade(newImplementation);
	}

	// external getters

	function getImplementation(uint256 version) external override view returns (address implementation) {
		// version 0 is treated as default and points to latest
		if (version == 0) {
			return _implementations[_latest];
		} else {
			return _implementations[version];
		}
	}

	function getLatestVersion() external override view returns (uint256 latest) {
		return _latest;
	}

	// internal setters

	function _upgrade(address newImplementation) private {
		require(Address.isContract(newImplementation), "VersionBeacon: new version is not a contract");
		_latest++;
		_implementations[_latest] = newImplementation;
	}
}
