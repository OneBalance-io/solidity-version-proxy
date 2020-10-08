// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IVersionBeacon} from "./VersionBeacon.sol";

contract VersionProxy is Proxy {
	bytes32 private constant _BEACON_SLOT = bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1);
	bytes32 private constant _VERSION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.version")) - 1);
	bytes32 private constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

	event BeaconChanged(address previousBeacon, address newBeacon);
	event VersionChanged(uint256 previousVersion, uint256 newVersion);
	event AdminChanged(address previousAdmin, address newAdmin);

	constructor(
		address beacon,
		uint256 version,
		address admin,
		bytes memory data
	) public payable {
		_setBeacon(beacon);
		_setVersion(version);
		_setAdmin(admin);
		if (data.length > 0) {
			_delegateCall(data);
		}
	}

	modifier ifAdmin() {
		if (msg.sender == _admin()) {
			_;
		} else {
			_fallback();
		}
	}

	// external functions

	function changeBeacon(address newBeacon) external ifAdmin {
		emit BeaconChanged(_beacon(), newBeacon);
		_setBeacon(newBeacon);
	}

	function changeBeaconAndCall(address newBeacon, bytes calldata data) external ifAdmin {
		emit BeaconChanged(_beacon(), newBeacon);
		_setBeacon(newBeacon);
		_delegateCall(data);
	}

	function changeVersion(uint256 newVersion) external ifAdmin {
		emit VersionChanged(_version(), newVersion);
		_setVersion(newVersion);
	}

	function changeVersionAndCall(uint256 newVersion, bytes calldata data) external ifAdmin {
		emit VersionChanged(_version(), newVersion);
		_setVersion(newVersion);
		_delegateCall(data);
	}

	function changeAdmin(address newAdmin) external ifAdmin {
		require(newAdmin != address(0), "VersionProxy: new admin is the zero address");
		emit AdminChanged(_admin(), newAdmin);
		_setAdmin(newAdmin);
	}

	// internal setters

	function _setBeacon(address beacon) private {
		require(Address.isContract(beacon), "VersionProxy: new beacon is not a contract");
		bytes32 slot = _BEACON_SLOT;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			sstore(slot, beacon)
		}
	}

	function _setVersion(uint256 version) private {
		require(version <= IVersionBeacon(_beacon()).getLatestVersion(), "VersionProxy: new version is not defined");
		bytes32 slot = _VERSION_SLOT;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			sstore(slot, version)
		}
	}

	function _setAdmin(address newAdmin) private {
		bytes32 slot = _ADMIN_SLOT;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			sstore(slot, newAdmin)
		}
	}

	function _delegateCall(bytes memory data) private {
		address implementation = _implementation();
		// solhint-disable-next-line avoid-low-level-calls
		(bool success, ) = implementation.delegatecall(data);
		require(success);
	}

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

	function _admin() internal view returns (address admin) {
		bytes32 slot = _ADMIN_SLOT;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			admin := sload(slot)
		}
	}

	// internal overrides

	function _implementation() internal override view returns (address implementation) {
		return IVersionBeacon(_beacon()).getImplementation(_version());
	}

	function _beforeFallback() internal virtual override {
		require(msg.sender != _admin(), "VersionProxy: admin cannot fallback to proxy target");
		super._beforeFallback();
	}
}
