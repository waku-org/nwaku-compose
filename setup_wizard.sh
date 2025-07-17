#!/bin/sh

if [ -f ./.env ] ; then
  echo "'./.env\` already exists, exiting wizard"
  exit 1
fi

if [ -f keystore/keystore.json ] ; then
  echo "'keystore/keystore.json\` already exists, exiting wizard"
  exit 1
fi

if [ -z "$(which docker 2>/dev/null)" ]; then
  echo "Ensure that 'docker\` is installed and in \$PATH"
  exit 1
fi

if [ -z "$(which docker-compose 2>/dev/null)" ]; then
  echo "Ensure that 'docker-compose' is installed and in \$PATH"
  exit 1
fi

echocol()
{
  COL='\033[0;32m'
  NC='\033[0m'
  printf "$COL${1}${NC}\n"
}

echocol "##############################"
echocol "#### nwaku-compose wizard ####"
echocol "##############################"
echocol "First, you need a RPC HTTP endpoint for Ethereum Sepolia"
echocol "If you don't have one, try out https://www.infura.io/"
echocol "Expected format is https://linea-sepolia.infura.io/v3/<api key>"
read -p "RLN_RELAY_ETH_CLIENT_ADDRESS: " RLN_RELAY_ETH_CLIENT_ADDRESS

if [ -z "$RLN_RELAY_ETH_CLIENT_ADDRESS" ] \
  || [ $(echo "$RLN_RELAY_ETH_CLIENT_ADDRESS" | grep -c "^https:") -eq 0 ]; then
    echo "Invalid value, received '$RLN_RELAY_ETH_CLIENT_ADDRESS'"
    exit 1
fi

echocol "...."
echocol "Now enter your SEPOLIA TESTNET account address (should start with 0x and be 42 characters)"
read -p "ETH_TESTNET_ACCOUNT: " ETH_TESTNET_ACCOUNT

if ! [[ "$ETH_TESTNET_ACCOUNT" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
  echo "Invalid value, received '$ETH_TESTNET_ACCOUNT'"
  exit 1
fi

echocol "...."
echocol "Double check you have some Eth Sepolia, at least 0.01Eth."
echocol "If not, you can use this faucet: https://www.infura.io/faucet/sepolia"
echocol "Now enter your SEPOLIA TESTNET private key in hex format 0a...1f without 0x prefix"
read -p "ETH_TESTNET_KEY: " ETH_TESTNET_KEY

if ! [[ "$ETH_TESTNET_KEY" =~ ^[0-9a-fA-F]{64}$ ]]; then
  echo "Invalid value, received '$ETH_TESTNET_KEY'"
  exit 1
fi

echocol "...."
echocol "Generating a password for the RLN membership keystore file..."
read -p "Press ENTER to continue..." foo
RLN_RELAY_CRED_PASSWORD=$(LC_ALL=C < /dev/urandom tr -dc ',/.;:<>?!@#$%^&*()+\-_A-Z-a-z-0-9' | head -c${1:-16}; echo)

echocol "...."
echocol "Estimating storage size for DB..."
read -p "Press ENTER to continue..." foo
STORAGE_SIZE=$(./set_storage_retention.sh echo-value)

if [ -z "$STORAGE_SIZE" ]; then
  echo "Error encountered when estimating storage size, exiting"
  exit 1
fi

echocol "...."
echocol "Estimating SHM for Postgres..."
read -p "Press ENTER to continue..." foo
POSTGRES_SHM=$(./set_postgres_shm.sh echo-value)

if [ -z "$POSTGRES_SHM" ]; then
  echo "Error encountered when estimating postgres container shm, exiting"
  exit 1
fi

echocol "...."
echocol "The following parameters will be saved to your .env file. Press ENTER to confirm or quit with CONTROL-C to abort:"
echo "RLN_RELAY_ETH_CLIENT_ADDRESS='$RLN_RELAY_ETH_CLIENT_ADDRESS'
ETH_TESTNET_KEY=$ETH_TESTNET_KEY
ETH_TESTNET_ACCOUNT=$ETH_TESTNET_ACCOUNT
RLN_RELAY_CRED_PASSWORD='$RLN_RELAY_CRED_PASSWORD'
STORAGE_SIZE=$STORAGE_SIZE
POSTGRES_SHM=$POSTGRES_SHM"
read -p "Press ENTER to continue..." foo

echo "RLN_RELAY_ETH_CLIENT_ADDRESS='$RLN_RELAY_ETH_CLIENT_ADDRESS'
ETH_TESTNET_KEY=$ETH_TESTNET_KEY
ETH_TESTNET_ACCOUNT=$ETH_TESTNET_ACCOUNT
RLN_RELAY_CRED_PASSWORD='$RLN_RELAY_CRED_PASSWORD'
STORAGE_SIZE=$STORAGE_SIZE
POSTGRES_SHM=$POSTGRES_SHM" > ./.env

RLN_CONTRACT_ADDRESS=0xB9cd878C90E49F797B4431fBF4fb333108CB90e6
TOKEN_CONTRACT_ADDRESS=0x185A0015aC462a0aECb81beCc0497b649a64B9ea
REQUIRED_AMOUNT=5000000000000000000

echocol "...."
echocol "Checking your TTT token balance..."
USER_BALANCE_RAW=$(cast call $TOKEN_CONTRACT_ADDRESS "balanceOf(address)(uint256)" $ETH_TESTNET_ACCOUNT --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS 2>/dev/null)
USER_BALANCE=$(echo "$USER_BALANCE_RAW" | awk '{print $1}')

if [ -z "$USER_BALANCE" ]; then
  echocol "Could not fetch balance. Please ensure your RPC endpoint and account are correct."
  exit 1
fi

echocol "Your current TTT token balance is: $USER_BALANCE"

if [ "$USER_BALANCE" -ge "$REQUIRED_AMOUNT" ]; then
  echocol "You already have enough TTT tokens to register."
  read -p "Do you want to mint more tokens? (y/N): " MINT_CHOICE
  if [ "$MINT_CHOICE" = "y" ] || [ "$MINT_CHOICE" = "Y" ]; then
    echocol "Run the following commands in your terminal:"
    echo "cast send $TOKEN_CONTRACT_ADDRESS \"mint(address,uint256)\" $ETH_TESTNET_ACCOUNT 5000000000000000000 --private-key $ETH_TESTNET_KEY --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS"
    echo "cast send $TOKEN_CONTRACT_ADDRESS \"approve(address,uint256)\" $RLN_CONTRACT_ADDRESS 5000000000000000000 --private-key $ETH_TESTNET_KEY --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS"
    echocol "Press ENTER after you have minted and approved tokens, or CONTROL-C to abort."
    read foo
    echocol "🎉 Minting and approval complete! You're ready for the next step."
  else
    echocol "Run the following command in your terminal:"
    echo "cast send $TOKEN_CONTRACT_ADDRESS \"approve(address,uint256)\" $RLN_CONTRACT_ADDRESS 5000000000000000000 --private-key $ETH_TESTNET_KEY --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS"
    echocol "Press ENTER after you have approved tokens, or CONTROL-C to abort."
    read foo
    echocol "✅ Approval complete! You're ready for the next step."
  fi
else
  echocol "You do not have enough TTT tokens. Mint and approve tokens to continue."
  echo "cast send $TOKEN_CONTRACT_ADDRESS \"mint(address,uint256)\" $ETH_TESTNET_ACCOUNT 5000000000000000000 --private-key $ETH_TESTNET_KEY --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS"
  echo "cast send $TOKEN_CONTRACT_ADDRESS \"approve(address,uint256)\" $RLN_CONTRACT_ADDRESS 5000000000000000000 --private-key $ETH_TESTNET_KEY --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS"
  echocol "Press ENTER after you have minted and approved tokens, or CONTROL-C to abort."
  read foo
  echocol "🎉 Minting and approval complete! You're ready for the next step."
fi

SUDO=""
if ! docker info > /dev/null 2>&1; then
  echocol "...."
  echocol "'sudo' seems to be needed to run docker, your unix password will be asked"
  SUDO="sudo"
fi



echocol "...."
echocol "Registering an RLN membership..."
if ! $SUDO ./register_rln.sh; then
  echocol "###"
  echocol "Failed to register RLN membership, usually due to high gas fee"
  echocol "Double check you have enough Sepolia eth and run the following command:"
  echocol "$SUDO ./register_rln.sh"
  echocol "###"
  exit 1
fi

echocol "...."
echocol "Your node is ready! enter the following command to start it:"
echo "> $SUDO docker-compose up -d"