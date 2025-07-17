#!/bin/sh

if [ -f ./.env ]; then
  echocol "'.env' already exists."
  read -p "Do you want to delete and regenerate it? (y/N): " RECREATE_ENV
  if [ "$RECREATE_ENV" = "y" ] || [ "$RECREATE_ENV" = "Y" ]; then
    rm -f ./.env
    echocol "Old .env removed. Generating a new one..."
  else
    echocol "Keeping existing .env. Exiting wizard."
    exit 1
  fi
fi

if [ -f keystore/keystore.json ]; then
  echocol "'keystore/keystore.json' already exists."
  read -p "Do you want to delete and regenerate it? (y/N): " RECREATE_KEYSTORE
  if [ "$RECREATE_KEYSTORE" = "y" ] || [ "$RECREATE_KEYSTORE" = "Y" ]; then
    rm -f keystore/keystore.json
    echocol "Old keystore/keystore.json removed. Generating a new one..."
  else
    echocol "Keeping existing keystore/keystore.json. Exiting wizard."
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

mint_tokens() {
  echocol "Minting TTT tokens to $ETH_TESTNET_ACCOUNT …"
  cast send $TOKEN_CONTRACT_ADDRESS "mint(address,uint256)" \
    $ETH_TESTNET_ACCOUNT $TTT_AMOUNT_WEI \
    --private-key $ETH_TESTNET_KEY \
    --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS || {
      echocol "❌ Mint transaction failed."
      exit 1
    }
  echocol "✅ Mint complete!"
}

approve_tokens() {
  echocol "Approving RLN contract to spend your TTT tokens …"
  cast send $TOKEN_CONTRACT_ADDRESS "approve(address,uint256)" \
    $RLN_CONTRACT_ADDRESS $TTT_AMOUNT_WEI \
    --private-key $ETH_TESTNET_KEY \
    --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS || {
      echocol "❌ Approve transaction failed."
      exit 1
    }
  echocol "✅ Approval complete!"
}

check_eth_balance() {
  # 0.01 ETH in wei
  local MIN=10000000000000000
  local BAL

  BAL=$(cast balance "$ETH_TESTNET_ACCOUNT" --rpc-url "$RLN_RELAY_ETH_CLIENT_ADDRESS" 2>/dev/null | tr -d '[:space:]')
  [ -z "$BAL" ] && { echocol "Couldn’t fetch ETH balance."; exit 1; }
  [ "$BAL" -lt "$MIN" ] && { echocol "Need ≥ 0.01 Sepolia ETH. Top up at https://www.infura.io/faucet/sepolia"; exit 1; }

  echocol "You have enough Linea Sepolia ETH to register."
}

echocol "+----------------------------------------------------------------------------------+"
echocol "|                                                                                  |"
echocol "|                            nwaku-compose wizard                                  |"
echocol "|                                                                                  |"
echocol "+----------------------------------------------------------------------------------+"
echocol "First, you need a RPC HTTP endpoint for Ethereum Sepolia"
echocol "If you don't have one, try out https://www.infura.io/ (Expected format is https://linea-sepolia.infura.io/v3/<api key>)"
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
check_eth_balance
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

echocol "...."
echocol "Checking your TTT token balance..."
USER_BALANCE_RAW=$(cast call $TOKEN_CONTRACT_ADDRESS "balanceOf(address)(uint256)" $ETH_TESTNET_ACCOUNT --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS 2>/dev/null)
USER_BALANCE=$(echo "$USER_BALANCE_RAW" | awk '{print $1}')
USER_BALANCE=$(echo "$USER_BALANCE / 10^18" | bc)

if [ -z "$USER_BALANCE" ]; then
  echocol "Could not fetch balance. Please ensure your RPC endpoint and account are correct."
  exit 1
fi

echocol "Your current TTT token balance is: $USER_BALANCE"

if [ "$USER_BALANCE" -ge "$REQUIRED_AMOUNT" ]; then
  echocol "You already have enough TTT tokens to register."
  read -p "Do you want to mint more tokens? (y/N): " MINT_CHOICE
  if [ "$MINT_CHOICE" = "y" ] || [ "$MINT_CHOICE" = "Y" ]; then
    mint_tokens
    approve_tokens
  else
    approve_tokens
  fi
else
  echocol "Minting and approving required TTT tokens …"
  mint_tokens
  approve_tokens
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