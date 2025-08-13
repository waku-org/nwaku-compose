#!/usr/bin/env bash

echocol()
{
  COL='\033[0;32m'
  NC='\033[0m'
  printf "$COL${1}${NC}\n"
}

RLN_CONTRACT_ADDRESS=0xB9cd878C90E49F797B4431fBF4fb333108CB90e6


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


# Ensure Foundry (cast & foundryup) is available for token mint/approve calls
if ! command -v cast >/dev/null 2>&1; then
  echocol "\n Foundry toolkit (cast) not found. Installing Foundry... \n"
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
echocol "RLN_CONTRACT_ADDRESS: $RLN_CONTRACT_ADDRESS"
echocol "STORAGE_SIZE: $STORAGE_SIZE"
echocol "POSTGRES_SHM: $POSTGRES_SHM"

read -p "Press ENTER to continue..." foo

echo "RLN_RELAY_ETH_CLIENT_ADDRESS='$RLN_RELAY_ETH_CLIENT_ADDRESS'
RLN_CONTRACT_ADDRESS=$RLN_CONTRACT_ADDRESS
STORAGE_SIZE=$STORAGE_SIZE
POSTGRES_SHM=$POSTGRES_SHM" > ./.env

echocol "Your node is ready! enter the following command to start it:"
read -p "Press ENTER to continue..." foo
docker-compose up -d
echocol "✅ Node started successfully!"
echocol ""