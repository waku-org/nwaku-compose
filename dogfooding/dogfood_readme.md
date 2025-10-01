# Dogfooding

## 📝 Prerequisites

- **Docker** and **Git**

1. Copy `.env.example.publisher` to `.env` and fill in all parameters.

    ```
    cp dogfooding/.env.example.publisher .env
    ```
2. Obtain test tokens.   
    The total tokens minted is determined by the amount of ETH sent with the transaction.

    ```
    cast send $TOKEN_CONTRACT_ADDRESS "mintWithETH(address)" $ETH_TESTNET_ACCOUNT --value $ETH_AMOUNT --rpc-url $RLN_RELAY_ETH_CLIENT_ADDRESS --private-key $ETH_TESTNET_KEY --from $ETH_TESTNET_ACCOUNT
    ```
3. Run the RLN registration script:

    ```
    ./register_rln.sh
    ```
4. Start the node:

    ```
    docker compose up -d
    ```
    
