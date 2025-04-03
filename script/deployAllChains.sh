#!/bin/bash

# Source the .env file to get all environment variables
set -a
source .env
set +a

# Broadcast function for different chain deployments
function broadcast() {
    defaultArgs=("--sig" "$2" "--rpc-url" "$3" "--account" "$DEPLOYER_ACCOUNT_NAME" "--sender" "$DEPLOYER_ADDRESS" "--broadcast" "--verify" "--slow" "--password" "$PASSWORD")
    
    if [[ $3 == "arbitrum" || $3 == "scroll" ]]; then
        forge script "$1" "${defaultArgs[@]}" --verifier blockscout --verifier-url "https://$3.blockscout.com/api/"
    elif [[ $3 == "bera" ]]; then
        forge script "$1" "${defaultArgs[@]}" --verifier custom --verifier-url "https://api.routescan.io/v2/network/mainnet/evm/80094/etherscan/api"
    elif [[ $3 == "morph_testnet" ]]; then
        forge script "$1" "${defaultArgs[@]}" --verifier blockscout --with-gas-price 0.03gwei --priority-gas-price 0.03gwei --verifier-url "https://explorer-api-holesky.morphl2.io/api?" --chain 2810
    elif [[ $3 == "binance" ]]; then
        forge script "$1" "${defaultArgs[@]}" --verifier etherscan --verifier-url "https://api.bscscan.com/api" --verifier-api-key "$BSCSCAN_API_KEY" --chain 56
    elif [[ $3 == "hemi" ]]; then
        forge script "$1" "${defaultArgs[@]}" --verifier blockscout --verifier-url "https://explorer.hemi.xyz/api" --chain 43111
    else
        forge script "$1" "${defaultArgs[@]}" --etherscan-api-key "$4"
    fi
}

# Function to deploy to a specific chain
deploy_to_chain() {
    local script_path="script/Deploy.s.sol:DeployScript"
    local sig="run()"
    local chain_name=$1
    local rpc_url=$2
    local api_key=$3
    
    echo "Deploying to $chain_name..."
    broadcast "$script_path" "$sig" "$chain_name" "$api_key"
    echo "Deployment to $chain_name completed"
    echo "----------------------------------------"
}

# Array of chain configurations
declare -A chains=(
    # Mainnets
    ["mainnet"]="$MAINNET_RPC_URL|$ETHERSCAN_API_KEY"
    ["base"]="$BASE_RPC_URL|$BASESCAN_API_KEY"
    ["optimism"]="$OPTIMISM_RPC_URL|$OPTIMISTIC_ETHERSCAN_API_KEY"
    ["arbitrum"]="$ARBITRUM_RPC_URL|$ARBISCAN_API_KEY"
    ["fraxtal"]="$FRAX_RPC_URL|$FRAXSCAN_API_KEY"
    ["manta"]="$MANTA_RPC_URL|$MANTASCAN_API_KEY"
    ["taiko"]="$TAIKO_RPC_URL|$TAIKOSCAN_API_KEY"
    ["scroll"]="$SCROLL_RPC_URL|$SCROLLSCAN_API_KEY"
    ["fantom"]="$FANTOM_RPC_URL|$FANTOMSCAN_API_KEY"
    ["mantle"]="$MANTLE_RPC_URL|$MANTLESCAN_API_KEY"
    ["blast"]="$BLAST_RPC_URL|$BLASTSCAN_API_KEY"
    ["linea"]="$LINEA_RPC_URL|$LINEASCAN_API_KEY"
    ["bera"]="$BERA_RPC_URL|$BERASCAN_API_KEY"
    ["binance"]="$BSC_RPC_URL|$BSCSCAN_API_KEY"
    ["hemi"]="$HEMI_RPC_URL|$HEMI_API_KEY"
    
    # Testnets
    ["holesky"]="$HOLESKY_RPC_URL|$ETHERSCAN_API_KEY"
    ["sepolia"]="$SEPOLIA_RPC_URL|$ETHERSCAN_API_KEY"
    ["fraxtal_testnet"]="$FRAX_TESTNET_RPC_URL|$FRAXSCAN_API_KEY"
    ["morph_testnet"]="$MORPH_TESTNET_RPC_URL|$MORPHSCAN_API_KEY"
    ["hemi_testnet"]="$HEMI_TESTNET_RPC_URL|$HEMI_TESTNET_API_KEY"
    ["binance_testnet"]="$BSC_TESTNET_RPC_URL|$BSCSCAN_TESTNET_API_KEY"
)

# Deploy to each chain
for chain_name in "${!chains[@]}"; do
    IFS='|' read -r rpc_url api_key <<< "${chains[$chain_name]}"
    if [ -n "$rpc_url" ]; then
        deploy_to_chain "$chain_name" "$rpc_url" "$api_key"
    fi
done

echo "All deployments completed!"
