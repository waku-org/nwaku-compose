# Dogfooding

## 📝 Prerequisites

- **Docker** and **Git**

1. Copy `.env.example.publisher` to `.env` and fill in all parameters.
    ```
    cp dogfooding/.env.example.publisher .env
    ```
2. Obtain test tokens (if needed, request in Discord).
3. Run the RLN registration script:
    ```
    ./register_rln.sh
    ```
4. Start the node:
    ```
    docker compose up -d
    ```
    
