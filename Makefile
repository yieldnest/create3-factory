# Default values
network ?= holesky
deployerAccountName := $(shell grep '^DEPLOYER_ACCOUNT_NAME=' .env | cut -d '=' -f2)
deployerAddress := $(shell grep '^DEPLOYER_ADDRESS=' .env | cut -d '=' -f2)
export NETWORK=${network}

# Default target
.PHONY: all
all: clean install build

# Clean the cache and output directories
.PHONY: clean
clean:
	rm -rf cache out

# Install dependencies using forge
.PHONY: install
install:
	forge install

# Build the project using forge
.PHONY: build
build:
	forge build

# Compile the project using forge
.PHONY: compile
compile:
	forge compile

# Format the Solidity files using forge fmt
.PHONY: fmt
fmt:
	forge fmt --root .

# make simulate network=holesky
.PHONY: simulate
simulate:
	@if [ -z "${network}" ]; then echo "Error: network is required"; exit 1; fi
	@if [ -z "${deployerAccountName}" ]; then echo "Error: deployerAccountName is required"; exit 1; fi
	@if [ -z "${deployerAddress}" ]; then echo "Error: deployerAddress is required"; exit 1; fi
	forge script Deploy --rpc-url ${network} --account ${deployerAccountName} --sender ${deployerAddress} 
# make deploy network=holesky
.PHONY: deploy
deploy:
	@if [ -z "${network}" ]; then echo "Error: network is required"; exit 1; fi
	@if [ -z "${deployerAccountName}" ]; then echo "Error: deployerAccountName is required"; exit 1; fi
	@if [ -z "${deployerAddress}" ]; then echo "Error: deployerAddress is required"; exit 1; fi
	forge script Deploy --rpc-url ${network} --account ${deployerAccountName} --sender ${deployerAddress} --broadcast --verify
