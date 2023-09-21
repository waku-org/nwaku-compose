#!/bin/sh

echo "I am a nwaku node"

if [ -z "${ETH_CLIENT_ADDRESS}" ]; then
    echo -e "Missing Eth client address, please refer to README.md for detailed instructions"
    exit 1
fi

MY_EXT_IP=$(wget -qO- https://api4.ipify.org)
DNS_WSS_CMD=

if [ -n "${DOMAIN}" ]; then

    LETSENCRYPT_PATH=/etc/letsencrypt/live/${DOMAIN}

    if ! [ -d "${LETSENCRYPT_PATH}" ]; then
        apk add --no-cache certbot

        certbot certonly\
            --non-interactive\
            --agree-tos\
            --no-eff-email\
            --no-redirect\
            --email admin@${DOMAIN}\
            -d ${DOMAIN}\
            --standalone
    fi

    if ! [ -e "${LETSENCRYPT_PATH}/privkey.pem" ]; then
        echo "The certificate does not exist"
        sleep 60
        exit 1
    fi

    WS_SUPPORT="--websocket-support=true"
    WSS_SUPPORT="--websocket-secure-support=true"
    WSS_KEY="--websocket-secure-key-path=${LETSENCRYPT_PATH}/privkey.pem"
    WSS_CERT="--websocket-secure-cert-path=${LETSENCRYPT_PATH}/cert.pem"
    DNS4_DOMAIN="--dns4-domain-name=${DOMAIN}"

    DNS_WSS_CMD="${WS_SUPPORT} ${WSS_SUPPORT} ${WSS_CERT} ${WSS_KEY} ${DNS4_DOMAIN}"
fi

if [ "${NODEKEY}" != "" ]; then
    NODEKEY=--nodekey=${NODEKEY}
fi

exec /usr/bin/wakunode\
  --relay=true\
  --topic=/waku/2/default-waku/proto\
  --topic=/waku/2/dev-waku/proto\
  --filter=true\
  --lightpush=true\
  --rpc-admin=true\
  --keep-alive=true\
  --max-connections=150\
  --dns-discovery=true\
  --dns-discovery-url=enrtree://ANEDLO25QVUGJOUTQFRYKWX6P4Z4GKVESBMHML7DZ6YK4LGS5FC5O@prod.wakuv2.nodes.status.im\
  --discv5-discovery=true\
  --discv5-udp-port=9005\
  --discv5-enr-auto-update=True\
  --log-level=DEBUG\
  --rpc-port=8545\
  --rpc-address=0.0.0.0\
  --tcp-port=30304\
  --metrics-server=True\
  --metrics-server-port=8003\
  --metrics-server-address=0.0.0.0\
  --rest=true\
  --rest-address=0.0.0.0\
  --rest-port=8645\
  --nat=extip:"${MY_EXT_IP}"\
  --store=true\
  --store-message-db-url="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/postgres"\
  --store-message-retention-policy=time:86400\
  --rln-relay=true\
  --rln-relay-dynamic=true\
  --rln-relay-eth-contract-address="${RLN_RELAY_CONTRACT_ADDRESS}"\
  --rln-relay-eth-client-address="${ETH_CLIENT_ADDRESS}"\
  --rln-relay-tree-path="/etc/rln_tree"\
  ${DNS_WSS_CMD}\
  ${NODEKEY}\
  ${EXTRA_ARGS}

