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
echocol "Expected format is https://sepolia.infura.io/v3/<api key>:"
read -r RLN_RELAY_ETH_CLIENT_ADDRESS

if [ -z "$RLN_RELAY_ETH_CLIENT_ADDRESS" ] \
  || [ $(echo "$RLN_RELAY_ETH_CLIENT_ADDRESS" | grep -c "^https:") -eq 0 ]; then
    echo "Invalid value, received '$RLN_RELAY_ETH_CLIENT_ADDRESS'"
    exit 1
fi

echocol "...."
echocol "Double check you have some Eth Sepolia, at least 0.01Eth."
echocol "If not, you can use this faucet: https://www.infura.io/faucet/sepolia"
echocol "Now enter your SEPOLIA TESTNET private key in hex format 0a...1f without 0x prefix"
read ETH_TESTNET_KEY

if [ -z "$ETH_TESTNET_KEY" ] \
  || [ $(echo -n "$ETH_TESTNET_KEY" | grep -c '^[0-9a-fA-F]\{64\}$' ) -ne 1 ]; then
    echo "Invalid value, received '$ETH_TESTNET_KEY'"
    exit 1
fi

echocol "...."
echocol "Generating a password for the RLN membership keystore file..."
RLN_RELAY_CRED_PASSWORD=$(< /dev/urandom tr -dc ',/.;:<>?!@#$%^&*()+\-_A-Z-a-z-0-9' | head -c${1:-16};echo;)

echocol "...."
echocol "Selecting a size for DB..."
STORAGE_SIZE=$(./set_storage_retention.sh echo-value)

if [ -z "$STORAGE_SIZE" ]; then
  echo "Error encountered when estimating storage size, exiting"
  exit 1
fi

echocol "...."
echocol "Selecting a SHM for Postgres..."
POSTGRES_SHM=$(./set_postgres_shm.sh echo-value)

if [ -z "$POSTGRES_SHM" ]; then
  echo "Error encountered when estimating postgres container shm, exiting"
  exit 1
fi

echocol "...."
echocol "The following parameters will be saved to your .env file. Press ENTER to confirm or quit with CONTROL-C to abort:"
echo "RLN_RELAY_ETH_CLIENT_ADDRESS='$RLN_RELAY_ETH_CLIENT_ADDRESS'
ETH_TESTNET_KEY=$ETH_TESTNET_KEY
RLN_RELAY_CRED_PASSWORD='$RLN_RELAY_CRED_PASSWORD'
STORAGE_SIZE=$STORAGE_SIZE
POSTGRES_SHM=$POSTGRES_SHM"
read foo

echo "RLN_RELAY_ETH_CLIENT_ADDRESS='$RLN_RELAY_ETH_CLIENT_ADDRESS'
ETH_TESTNET_KEY=$ETH_TESTNET_KEY
RLN_RELAY_CRED_PASSWORD='$RLN_RELAY_CRED_PASSWORD'
STORAGE_SIZE=$STORAGE_SIZE
POSTGRES_SHM=$POSTGRES_SHM" > ./.env

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