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
        return string.concat(root, "/deployments/", getChainName(), "-deployment.json");
    }

    function getChainName() internal view virtual returns (string memory) {
        if (block.chainid == 1) {
            return "mainnet";
        } else if (block.chainid == 8453) {
            return "base";
        } else if (block.chainid == 10) {
            return "optimism";
        } else if (block.chainid == 42161) {
            return "arbitrum";
        } else if (block.chainid == 252) {
            return "fraxtal";
        } else if (block.chainid == 169) {
            return "manta";
        } else if (block.chainid == 534352) {
            return "scroll";
        } else if (block.chainid == 250) {
            return "fantom";
        } else if (block.chainid == 5000) {
            return "mantle";
        } else if (block.chainid == 81457) {
            return "blast";
        } else if (block.chainid == 59144) {
            return "linea";
        } else if (block.chainid == 80094) {
            return "bera";
        } else if (block.chainid == 56) {
            return "binance";
        } else if (block.chainid == 43111) {
            return "hemi";
        } else if (block.chainid == 17000) {
            return "holesky";
        } else if (block.chainid == 11155111) {
            return "sepolia";
        } else if (block.chainid == 2522) {
            return "fraxtal_testnet";
        } else if (block.chainid == 2810) {
            return "morph_testnet";
        } else if (block.chainid == 743111) {
            return "hemi_testnet";
        } else if (block.chainid == 97) {
            return "binance_testnet";
        } else {
            revert("Unsupported chain");
        }
    }

    function saveDeployment() internal {
        string memory jsonFile = getDeploymentFile();
        vm.serializeUint(jsonFile, "chainid", block.chainid);
        vm.serializeAddress(jsonFile, "CREATE3Factory", address(factory));
        string memory finalJson = vm.serializeAddress(jsonFile, "sender", msg.sender);
        vm.writeJson(finalJson, jsonFile);
    }
}
