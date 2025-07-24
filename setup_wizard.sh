#!/bin/sh

echocol()
{
  COL='\033[0;32m'
  NC='\033[0m'
  printf "$COL${1}${NC}\n"
}

RLN_CONTRACT_ADDRESS=0xB9cd878C90E49F797B4431fBF4fb333108CB90e6
TOKEN_CONTRACT_ADDRESS=0x185A0015aC462a0aECb81beCc0497b649a64B9ea
REQUIRED_AMOUNT=5
TTT_AMOUNT_WEI=5000000000000000000

mint_tokens() {
  echocol ""
  echocol "Minting TTT tokens ..."
  cast send $TOKEN_CONTRACT_ADDRESS "mint(address,uint256)" \
    $ETH_TESTNET_ACCOUNT $TTT_AMOUNT_WEI \
    --private-key $ETH_TESTNET_KEY \
    --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS || {
      echocol "❌ Mint transaction failed."
      exit 1
    }
  echocol "✅ Mint complete!"
  echocol ""
}

approve_tokens() {
  echocol ""
  echocol "Approving RLN contract to spend your TTT tokens ..."
  cast send $TOKEN_CONTRACT_ADDRESS "approve(address,uint256)" \
    $RLN_CONTRACT_ADDRESS $TTT_AMOUNT_WEI \
    --private-key $ETH_TESTNET_KEY \
    --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS || {
      echocol "❌ Approve transaction failed."
      exit 1
    }
  echocol "✅ Approval complete!"
  echocol ""
}

check_eth_balance() {
  # 0.01 ETH in wei
  local MIN=10000000000000000
  local BAL

  BAL=$(cast balance "$ETH_TESTNET_ACCOUNT" --rpc-url "$RLN_RELAY_ETH_CLIENT_ADDRESS" 2>/dev/null | tr -d '[:space:]')
  [ -z "$BAL" ] && { echocol "Couldn’t fetch ETH balance."; exit 1; }
  [ "$BAL" -lt "$MIN" ] && { echocol "Need ≥ 0.01 Linea Sepolia ETH. Top up at https://www.infura.io/faucet/sepolia"; exit 1; }

  echocol "✅ You have enough Linea Sepolia ETH to register."
}

if [ -f ./.env ]; then
  echocol ".env file already exists."
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
  fi
fi

# Ensure Foundry (cast & foundryup) is available for token mint/approve calls
if ! command -v cast >/dev/null 2>&1; then
  echocol "Foundry toolkit (cast) not found. Installing Foundry... \n"
  curl -L https://foundry.paradigm.xyz | bash
  # Make the freshly installed binaries available in the current session
  export PATH="$HOME/.foundry/bin:$PATH"
  foundryup
fi

if [ -z "$(which docker 2>/dev/null)" ]; then
  echo "Ensure that 'docker\` is installed and in \$PATH"
  exit 1
fi

if [ -z "$(which docker-compose 2>/dev/null)" ]; then
  echo "Ensure that 'docker-compose' is installed and in \$PATH"
  exit 1
fi


echocol ""
echocol "╔══════════════════════════════════════════════════════════════════════════════╗"
echocol "║                                                                              ║"
echocol "║                        Welcome to nwaku-compose wizard                       ║"
echocol "║                                                                              ║"
echocol "╚══════════════════════════════════════════════════════════════════════════════╝"
echocol ""
echocol "First, you need a RPC HTTP endpoint for Linea Sepolia"
echocol "If you don't have one, try out https://www.infura.io/ (Expected format is https://linea-sepolia.infura.io/v3/<api key>)"
read -p "RLN_RELAY_ETH_CLIENT_ADDRESS: " RLN_RELAY_ETH_CLIENT_ADDRESS

if [ -z "$RLN_RELAY_ETH_CLIENT_ADDRESS" ] \
  || [ $(echo "$RLN_RELAY_ETH_CLIENT_ADDRESS" | grep -c "^https:") -eq 0 ]; then
    echo "Invalid value, received '$RLN_RELAY_ETH_CLIENT_ADDRESS'"
    exit 1
fi

echocol ""
echocol "Now enter your Linea Sepolia Testnet account address (should start with 0x and be 42 characters)"
read -p "ETH_TESTNET_ACCOUNT: " ETH_TESTNET_ACCOUNT

if ! [[ "$ETH_TESTNET_ACCOUNT" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
  echo "Invalid value, received '$ETH_TESTNET_ACCOUNT'"
  exit 1
fi

echocol ""
echocol "Checking your Linea Sepolia Testnet balance..."
check_eth_balance
echocol ""

echocol "Now enter your Linea Sepolia Testnet private key in hex format 0a...1f without 0x prefix"
read -p "ETH_TESTNET_KEY: " ETH_TESTNET_KEY

if ! [[ "$ETH_TESTNET_KEY" =~ ^[0-9a-fA-F]{64}$ ]]; then
  echo "Invalid value, received '$ETH_TESTNET_KEY'"
  exit 1
fi

echocol ""
echocol "Generating a password for the RLN membership keystore file..."
read -p "Press ENTER to continue..." foo
RLN_RELAY_CRED_PASSWORD=$(LC_ALL=C < /dev/urandom tr -dc ',/.;:<>?!@#$%^&*()+\-_A-Z-a-z-0-9' | head -c${1:-16}; echo)

echocol ""
echocol "Estimating storage size for DB..."
read -p "Press ENTER to continue..." foo
STORAGE_SIZE=$(./set_storage_retention.sh echo-value)

if [ -z "$STORAGE_SIZE" ]; then
  echo "Error encountered when estimating storage size, exiting"
  exit 1
fi

echocol ""
echocol "Estimating SHM for Postgres..."
read -p "Press ENTER to continue..." foo
POSTGRES_SHM=$(./set_postgres_shm.sh echo-value)

if [ -z "$POSTGRES_SHM" ]; then
  echo "Error encountered when estimating postgres container shm, exiting"
  exit 1
fi

echocol ""
echocol "🔐 Review your credentials and environment configuration below."
echocol "They will be saved to '.env'. Press ENTER to confirm or CONTROL-C to cancel:"

echocol ""
echocol "RLN_RELAY_ETH_CLIENT_ADDRESS: $RLN_RELAY_ETH_CLIENT_ADDRESS"
echocol "ETH_TESTNET_KEY: $ETH_TESTNET_KEY"
echocol "ETH_TESTNET_ACCOUNT: $ETH_TESTNET_ACCOUNT"
echocol "RLN_RELAY_CRED_PASSWORD: $RLN_RELAY_CRED_PASSWORD"
echocol "STORAGE_SIZE: $STORAGE_SIZE"
echocol "POSTGRES_SHM: $POSTGRES_SHM"

read -p "Press ENTER to continue..." foo

echo "RLN_RELAY_ETH_CLIENT_ADDRESS='$RLN_RELAY_ETH_CLIENT_ADDRESS'
ETH_TESTNET_KEY=$ETH_TESTNET_KEY
ETH_TESTNET_ACCOUNT=$ETH_TESTNET_ACCOUNT
RLN_RELAY_CRED_PASSWORD='$RLN_RELAY_CRED_PASSWORD'
STORAGE_SIZE=$STORAGE_SIZE
POSTGRES_SHM=$POSTGRES_SHM" > ./.env

echocol ""
echocol "Checking your TTT token balance..."
USER_BALANCE_RAW=$(cast call $TOKEN_CONTRACT_ADDRESS "balanceOf(address)(uint256)" $ETH_TESTNET_ACCOUNT --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS 2>/dev/null)
USER_BALANCE=$(echo "$USER_BALANCE_RAW" | awk '{print $1}')
USER_BALANCE=$(echo "$USER_BALANCE / 10^18" | bc)

if [ -z "$USER_BALANCE" ]; then
  echocol "Could not fetch balance. Please ensure your RPC endpoint and account are correct."
  exit 1
fi

echocol "Your current TTT token balance is: $USER_BALANCE"
echocol "Required amount: $REQUIRED_AMOUNT"
echocol ""

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

echocol "🔐 Registering RLN membership..."
read -p "Press ENTER to continue..." foo

if ! docker run --rm \
  -v "$(pwd)/keystore:/keystore":Z \
  wakuorg/nwaku:v0.36.0 \
  generateRlnKeystore \
    --rln-relay-eth-client-address="${RLN_RELAY_ETH_CLIENT_ADDRESS}" \
    --rln-relay-eth-private-key="${ETH_TESTNET_KEY}" \
    --rln-relay-eth-contract-address="${RLN_RELAY_CONTRACT_ADDRESS}" \
    --rln-relay-cred-path=/keystore/keystore.json \
    --rln-relay-cred-password="${RLN_RELAY_CRED_PASSWORD}" \
    --rln-relay-user-message-limit=100 \
    --execute; then
  echocol ""
  echocol "❌ RLN registration failed (likely gas / RPC issue)."
  echocol ""
  exit 1
fi

echocol ""
echocol "✅ RLN membership registered successfully!"
echocol ""

echocol "Your node is ready! enter the following command to start it:"
read -p "Press ENTER to continue..." foo
sudo docker-compose up -d
echocol "✅ Node started successfully!"
echocol ""
