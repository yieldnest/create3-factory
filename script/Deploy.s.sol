// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {CREATE3Factory} from "../src/CREATE3Factory.sol";

contract Deploy is Script {
    string public constant _SALT = "yieldnest.create3factory.v1";
    bytes32 salt = keccak256(bytes(_SALT));
    CREATE3Factory factory;

    function run() public {
        vm.startBroadcast();

        console.log("Chain ID: %s", vm.toString(block.chainid));
        console.log("Sender: %s", msg.sender);
        console.log("Salt: %s", string.concat("keccak256(", _SALT, ")"));

        factory = new CREATE3Factory{salt: salt}();
        console.log("CREATE3Factory: %s", address(factory));

        vm.stopBroadcast();

        saveDeployment();
        console.log("Saved to: %s", getDeploymentFile());
    }

    function getDeploymentFile() internal view virtual returns (string memory) {
        string memory root = vm.projectRoot();
        string memory network = vm.envString("NETWORK");
        return string.concat(root, "/deployments/", network, "-", vm.toString(block.chainid), ".json");
    }

    function saveDeployment() internal {
        string memory jsonFile = getDeploymentFile();
        vm.serializeUint(jsonFile, "chainid", block.chainid);
        vm.serializeAddress(jsonFile, "CREATE3Factory", address(factory));
        string memory finalJson = vm.serializeAddress(jsonFile, "sender", msg.sender);
        vm.writeJson(finalJson, jsonFile);
    }
}
