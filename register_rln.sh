#!/bin/sh

if test -f ./keystore/keystore.json; then
  echo "keystore/keystore.json already exists. Use it instead of creating a new one."
  echo "Exiting"
  exit 1
fi

if test -f .env; then
  echo "Using .env file"
  . "$(pwd)"/.env
fi

if test -n "${ETH_CLIENT_ADDRESS}"; then
  echo "ETH_CLIENT_ADDRESS variable was renamed to RLN_RELAY_ETH_CLIENT_ADDRESS"
  echo "Please update your .env file"
  exit 1
fi

# Ensure Foundry (cast & foundryup) is available for token mint/approve calls
# if ! command -v cast >/dev/null 2>&1; then
#   echo "Foundry toolkit (cast) not found. Installing Foundry..."
#   curl -L https://foundry.paradigm.xyz | bash
#   # Make the freshly installed binaries available in the current session
#   export PATH="$HOME/.foundry/bin:$PATH"
#   foundryup
# fi

# # default: do mint/approve
# NEED_MINTING=1

# for arg in "$@"; do
#   case "$arg" in
#     --no-mint) NEED_MINTING=0 ;;
#     --mint)    NEED_MINTING=1 ;;
#   esac
# done

RLN_CONTRACT_ADDRESS=0x313a4a4dcf95da8e020b5375c0f8f732b7b4f15b
TOKEN_CONTRACT_ADDRESS=0xd17e184e3c1941585a3edcb3a10367da6326d844
TTT_AMOUNT_WEI=5000000000000000000

# Mint 
# if [ "$NEED_MINTING" = "1" ]; then
#   echo "\nMinting test token"
#   if ! cast send "$TOKEN_CONTRACT_ADDRESS" "mint(address,uint256)" \
#           "$ETH_TESTNET_ACCOUNT" "$TTT_AMOUNT_WEI" \
#           --private-key "$ETH_TESTNET_KEY" \
#           --rpc-url   "$RLN_RELAY_ETH_CLIENT_ADDRESS"
#   then
#     echo " Mint transaction failed."
#     exit 1
#   fi
# fi 

# # Approve 
# echo "\nApprove to spend the test tokens"
# if ! cast send "$TOKEN_CONTRACT_ADDRESS" "approve(address,uint256)" \
#         "$RLN_CONTRACT_ADDRESS" "$TTT_AMOUNT_WEI" \
#         --private-key "$ETH_TESTNET_KEY" \
#         --rpc-url   "$RLN_RELAY_ETH_CLIENT_ADDRESS"
# then
#   echo "Approve transaction failed."
#   exit 1
# fi

docker run -v "$(pwd)/keystore":/keystore/:Z wakuorg/nwaku:v0.36.0 generateRlnKeystore \
--rln-relay-eth-client-address=${RLN_RELAY_ETH_CLIENT_ADDRESS} \
--rln-relay-eth-private-key=${ETH_TESTNET_KEY} \
--rln-relay-eth-contract-address=0x313a4a4dcf95da8e020b5375c0f8f732b7b4f15b \
--rln-relay-cred-path=/keystore/keystore.json \
--rln-relay-cred-password="${RLN_RELAY_CRED_PASSWORD}" \
--rln-relay-user-message-limit=20 \
--rln-relay-chain-id=59141 \
--execute
