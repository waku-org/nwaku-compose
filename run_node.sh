#!/bin/sh

echo "I am a nwaku node"

if [ -z "${ETH_CLIENT_ADDRESS}" ]; then
    echo "Missing Eth client address, please refer to README.md for detailed instructions"
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

if [ -n "${NODEKEY}" ]; then
    NODEKEY=--nodekey=${NODEKEY}
fi


RLN_RELAY_CRED_PATH=--rln-relay-cred-path=${RLN_RELAY_CRED_PATH:-/keystore/keystore.json}


if [ -n "${RLN_RELAY_CRED_PASSWORD}" ]; then
    RLN_RELAY_CRED_PASSWORD=--rln-relay-cred-password="${RLN_RELAY_CRED_PASSWORD}"
fi

# waku2.test
exec /usr/bin/wakunode\
  --relay=true\
  --filter=true\
  --filternode="/dns4/node-01.do-ams3.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAkykgaECHswi3YKJ5dMLbq2kPVCo89fcyTd38UcQD6ej5W"\
  --lightpush=true\
  --lightpushnode="/dns4/node-01.do-ams3.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAkykgaECHswi3YKJ5dMLbq2kPVCo89fcyTd38UcQD6ej5W"\
  --keep-alive=true\
  --pubsub-topic=/waku/2/rs/1/0\
  --pubsub-topic=/waku/2/rs/1/1\
  --pubsub-topic=/waku/2/rs/1/2\
  --pubsub-topic=/waku/2/rs/1/3\
  --pubsub-topic=/waku/2/rs/1/4\
  --pubsub-topic=/waku/2/rs/1/5\
  --pubsub-topic=/waku/2/rs/1/6\
  --pubsub-topic=/waku/2/rs/1/7\
  --max-connections=150\
  --cluster-id=1\
  --staticnode="/dns4/node-01.do-ams3.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAkykgaECHswi3YKJ5dMLbq2kPVCo89fcyTd38UcQD6ej5W"\
  --staticnode="/dns4/node-01.gc-us-central1-a.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAmDCp8XJ9z1ev18zuv8NHekAsjNyezAvmMfFEJkiharitG"\
  --staticnode="/dns4/node-01.ac-cn-hongkong-c.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAkzHaTP5JsUwfR9NR8Rj9HC24puS6ocaU8wze4QrXr9iXp"\
  --discv5-discovery=true\
  --discv5-udp-port=9005\
  --discv5-enr-auto-update=True\
  --log-level=DEBUG\
  --tcp-port=30304\
  --metrics-server=True\
  --metrics-server-port=8003\
  --metrics-server-address=0.0.0.0\
  --rest=true\
  --rest-admin=true\
  --rest-address=0.0.0.0\
  --rest-port=8645\
  --rest-allow-origin="waku-org.github.io"\
  --nat=extip:"${MY_EXT_IP}"\
  --store=true\
  --store-message-db-url="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/postgres"\
  --store-message-retention-policy=time:86400\
  --rln-relay=true\
  --rln-relay-dynamic=true\
  --rln-relay-eth-contract-address="${RLN_RELAY_CONTRACT_ADDRESS}"\
  --rln-relay-eth-client-address="${ETH_CLIENT_ADDRESS}"\
  --rln-relay-tree-path="/etc/rln_tree"\
  ${RLN_RELAY_CRED_PATH}\
  ${RLN_RELAY_CRED_PASSWORD}\
  ${DNS_WSS_CMD}\
  ${NODEKEY}\
  ${EXTRA_ARGS}

# Waku.test
# exec /usr/bin/wakunode\
#   --relay=true\
#   --filter=true\
#   --lightpush=true\
#   --rpc-admin=true\
#   --keep-alive=true\
#   --pubsub-topic=/waku/2/rs/1/0\
#   --pubsub-topic=/waku/2/rs/1/1\
#   --pubsub-topic=/waku/2/rs/1/2\
#   --pubsub-topic=/waku/2/rs/1/3\
#   --pubsub-topic=/waku/2/rs/1/4\
#   --pubsub-topic=/waku/2/rs/1/5\
#   --pubsub-topic=/waku/2/rs/1/6\
#   --pubsub-topic=/waku/2/rs/1/7\
#   --max-connections=150\
#   --cluster-id=1\
#   --staticnode="/dns4/node-01.do-ams3.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAkykgaECHswi3YKJ5dMLbq2kPVCo89fcyTd38UcQD6ej5W"\
#   --staticnode="/dns4/node-01.gc-us-central1-a.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAmDCp8XJ9z1ev18zuv8NHekAsjNyezAvmMfFEJkiharitG"\
#   --staticnode="/dns4/node-01.ac-cn-hongkong-c.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAkzHaTP5JsUwfR9NR8Rj9HC24puS6ocaU8wze4QrXr9iXp"\
#   --discv5-discovery=true\
#   --discv5-udp-port=9005\
#   --discv5-enr-auto-update=True\
#   --log-level=DEBUG\
#   --rpc-port=8545\
#   --rpc-address=0.0.0.0\
#   --tcp-port=30304\
#   --metrics-server=True\
#   --metrics-server-port=8003\
#   --metrics-server-address=0.0.0.0\
#   --rest=true\
#   --rest-admin=true\
#   --rest-address=0.0.0.0\
#   --rest-port=8645\
#   --nat=extip:"${MY_EXT_IP}"\
#   --store=true\
#   --store-message-db-url="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/postgres"\
#   --store-message-retention-policy=time:86400\
#   --rln-relay=true\
#   --rln-relay-dynamic=true\
#   --rln-relay-eth-contract-address="${RLN_RELAY_CONTRACT_ADDRESS}"\
#   --rln-relay-eth-client-address="${ETH_CLIENT_ADDRESS}"\
#   --rln-relay-tree-path="/etc/rln_tree"\
#   ${RLN_RELAY_CRED_PATH}\
#   ${RLN_RELAY_CRED_PASSWORD}\
#   ${DNS_WSS_CMD}\
#   ${NODEKEY}\
#   ${EXTRA_ARGS}


# waku2.test
#   --pubsub-topic='/waku/2/default-waku/proto'\
#   --pubsub-topic='/waku/2/dev-waku/proto'\
#   --staticnode="/dns4/node-01.do-ams3.wakuv2.test.statusim.net/tcp/30303/p2p/16Uiu2HAmPLe7Mzm8TsYUubgCAW1aJoeFScxrLj8ppHFivPo97bUZ"\
#   --staticnode="/dns4/node-01.gc-us-central1-a.wakuv2.test.statusim.net/tcp/30303/p2p/16Uiu2HAmJb2e28qLXxT5kZxVUUoJt72EMzNGXB47Rxx5hw3q4YjS"\
#   --staticnode="/dns4/node-01.ac-cn-hongkong-c.wakuv2.test.statusim.net/tcp/30303/p2p/16Uiu2HAkvWiyFsgRhuJEb9JfjYxEkoHLgnUQmr1N5mKWnYjxYRVm"\

# waku.test
#   --pubsub-topic=/waku/2/rs/1/0\
#   --pubsub-topic=/waku/2/rs/1/1\
#   --pubsub-topic=/waku/2/rs/1/2\
#   --pubsub-topic=/waku/2/rs/1/3\
#   --pubsub-topic=/waku/2/rs/1/4\
#   --pubsub-topic=/waku/2/rs/1/5\
#   --pubsub-topic=/waku/2/rs/1/6\
#   --pubsub-topic=/waku/2/rs/1/7\
#   --staticnode="/dns4/node-01.do-ams3.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAkykgaECHswi3YKJ5dMLbq2kPVCo89fcyTd38UcQD6ej5W"\
#   --staticnode="/dns4/node-01.gc-us-central1-a.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAmDCp8XJ9z1ev18zuv8NHekAsjNyezAvmMfFEJkiharitG"\
#   --staticnode="/dns4/node-01.ac-cn-hongkong-c.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAkzHaTP5JsUwfR9NR8Rj9HC24puS6ocaU8wze4QrXr9iXp"\

# waku.test bootstrap:
#   --discv5-bootstrap-node="enr:-QESuEC1p_s3xJzAC_XlOuuNrhVUETmfhbm1wxRGis0f7DlqGSw2FM-p2Ugl_r25UHQJ3f1rIRrpzxJXSMaJe4yk1XFSAYJpZIJ2NIJpcISygI2rim11bHRpYWRkcnO4XAArNiZub2RlLTAxLmRvLWFtczMud2FrdS50ZXN0LnN0YXR1c2ltLm5ldAZ2XwAtNiZub2RlLTAxLmRvLWFtczMud2FrdS50ZXN0LnN0YXR1c2ltLm5ldAYfQN4DgnJzkwABCAAAAAEAAgADAAQABQAGAAeJc2VjcDI1NmsxoQJATXRSRSUyTw_QLB6H_U3oziVQgNRgrXpK7wp2AMyNxYN0Y3CCdl-DdWRwgiMohXdha3UyDw"\
#   --discv5-bootstrap-node="enr:-QEkuECnZ3IbVAgkOzv-QLnKC4dRKAPRY80m1-R7G8jZ7yfT3ipEfBrhKN7ARcQgQ-vg-h40AQzyvAkPYlHPaFKk6u9uAYJpZIJ2NIJpcIQiEAFDim11bHRpYWRkcnO4bgA0Ni9ub2RlLTAxLmdjLXVzLWNlbnRyYWwxLWEud2FrdS50ZXN0LnN0YXR1c2ltLm5ldAZ2XwA2Ni9ub2RlLTAxLmdjLXVzLWNlbnRyYWwxLWEud2FrdS50ZXN0LnN0YXR1c2ltLm5ldAYfQN4DgnJzkwABCAAAAAEAAgADAAQABQAGAAeJc2VjcDI1NmsxoQMIJwesBVgUiBCi8yiXGx7RWylBQkYm1U9dvEy-neLG2YN0Y3CCdl-DdWRwgiMohXdha3UyDw"\
#   --discv5-bootstrap-node="enr:-QEkuEDzQyIAhs-CgBHIrJqtBv3EY1uP1Psrc-y8yJKsmxW7dh3DNcq2ergMUWSFVcJNlfcgBeVsFPkgd_QopRIiCV2pAYJpZIJ2NIJpcIQI2ttrim11bHRpYWRkcnO4bgA0Ni9ub2RlLTAxLmFjLWNuLWhvbmdrb25nLWMud2FrdS50ZXN0LnN0YXR1c2ltLm5ldAZ2XwA2Ni9ub2RlLTAxLmFjLWNuLWhvbmdrb25nLWMud2FrdS50ZXN0LnN0YXR1c2ltLm5ldAYfQN4DgnJzkwABCAAAAAEAAgADAAQABQAGAAeJc2VjcDI1NmsxoQJIN4qwz3v4r2Q8Bv8zZD0eqBcKw6bdLvdkV7-JLjqIj4N0Y3CCdl-DdWRwgiMohXdha3UyDw"\
