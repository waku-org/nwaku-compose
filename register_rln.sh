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

# TODO: Set nwaku release when ready instead of quay

if test -n "${ETH_CLIENT_ADDRESS}"; then
  echo "ETH_CLIENT_ADDRESS variable was renamed to RLN_RELAY_ETH_CLIENT_ADDRESS"
  echo "Please update your .env file"
  exit 1
fi

docker run -v "$(pwd)/keystore":/keystore/:Z wakuorg/nwaku:v0.35.1 generateRlnKeystore \
--rln-relay-eth-client-address=${RLN_RELAY_ETH_CLIENT_ADDRESS} \
--rln-relay-eth-private-key=${ETH_TESTNET_KEY} \
--rln-relay-eth-contract-address=0xfe7a9eabce779a090fd702346fd0bfac02ce6ac8 \
--rln-relay-cred-path=/keystore/keystore.json \
--rln-relay-cred-password="${RLN_RELAY_CRED_PASSWORD}" \
--rln-relay-user-message-limit=100 \
--execute
