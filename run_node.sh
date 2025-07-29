#!/bin/sh

echo "I am a nwaku node"

if [ -n "${ETH_CLIENT_ADDRESS}" ] ; then
    echo "ETH_CLIENT_ADDRESS variable was renamed to RLN_RELAY_ETH_CLIENT_ADDRESS"
    echo "Please update your .env file"
    exit 1
fi

if [ -z "${RLN_RELAY_ETH_CLIENT_ADDRESS}" ]; then
    echo "Missing Eth client address, please refer to README.md for detailed instructions"
    exit 1
fi

MY_EXT_IP=$(wget -qO- https://api4.ipify.org)
DNS_WSS_CMD=

if [ -z "${DOMAIN}" ]; then
    echo "auto-domain: DOMAIN is unset, trying to guess it"

    # Check if we have an IP
    IPCHECK=$(echo "${MY_EXT_IP}" | grep -c '^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$')

    if [ "${IPCHECK}" -ne 1 ]; then
        echo "Failed to get ip, received: '${MY_EXT_IP}'"
    else
        echo "auto-domain: ip is '${MY_EXT_IP}'"

        # Get reverse DNS
        DNS=$(dig +short -x "${MY_EXT_IP}")

        # Check if looks like a DNS
        DNSCHECK=$(echo "${DNS}" | grep -c '^\([a-zA-Z0-9_\-]\+\.\)\+$')

        if [ "${DNSCHECK}" -ne 1 ]; then
            echo "Failed to get DNS, received: '${DNS}'"
        else
            DOMAIN=$(echo "${DNS}" | sed s/\.$//)
            echo "auto-domain: DOMAIN deduced and set to ${DOMAIN}"

           # Double check the domain is setup to return right IP
           # OpenDNS servers are used to bypass /etc/hosts as it may return loopback address
           DNS_IP=$(dig +short @208.67.222.222 "${DNS}")

           if [ "${DNS_IP}" != "${MY_EXT_IP}"  ]; then
               echo "auto-domain: DNS queried returned a different ip: '${DNS_IP}', unsetting DOMAIN"
               unset DOMAIN
           else
               echo "auto-domain: last verification successful, DOMAIN=${DOMAIN}"
           fi
        fi
    fi
fi

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
        echo "The certificate does not exist. Proceeding without supporting websocket"
    else
        WS_SUPPORT="--websocket-support=true"
        WSS_SUPPORT="--websocket-secure-support=true"
        WSS_KEY="--websocket-secure-key-path=${LETSENCRYPT_PATH}/privkey.pem"
        WSS_CERT="--websocket-secure-cert-path=${LETSENCRYPT_PATH}/fullchain.pem"
        DNS4_DOMAIN="--dns4-domain-name=${DOMAIN}"

        DNS_WSS_CMD="${WS_SUPPORT} ${WSS_SUPPORT} ${WSS_CERT} ${WSS_KEY} ${DNS4_DOMAIN}" 
    fi
fi

if [ -n "${NODEKEY}" ]; then
    NODEKEY=--nodekey=${NODEKEY}
fi

if [ -n "${RLN_RELAY_CRED_PASSWORD}" ]; then
    RLN_RELAY_CRED_PASSWORD=--rln-relay-cred-password="${RLN_RELAY_CRED_PASSWORD}"
    ## Enable Light Push (RLNaaS) if RLN credentials are used
    LIGHTPUSH=--lightpush=true
    ## Pass default value for credentials path if not set
    RLN_RELAY_CRED_PATH=--rln-relay-cred-path=${RLN_RELAY_CRED_PATH:-/keystore/keystore.json}
    echo "Using RLN credentials from ${RLN_RELAY_CRED_PATH}"
else
    LIGHTPUSH=--lightpush=false
    # Ensure no empty values are passed
    RLN_RELAY_CRED_PATH=""
    RLN_RELAY_CRED_PASSWORD=""
fi


STORE_RETENTION_POLICY=--store-message-retention-policy=size:1GB

if [ -n "${STORAGE_SIZE}" ]; then
    STORE_RETENTION_POLICY=--store-message-retention-policy=size:"${STORAGE_SIZE}"
fi

exec /usr/bin/wakunode\
    --relay=true\
    --filter=true\
    ${LIGHTPUSH}\
    --keep-alive=true\
    --max-connections=150\
    --cluster-id=1\
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
    --rest-allow-origin="localhost:*"\
    --nat=extip:"${MY_EXT_IP}"\
    --store=true\
    --store-message-db-url="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/postgres"\
    --rln-relay-eth-client-address="${RLN_RELAY_ETH_CLIENT_ADDRESS}"\
    --rln-relay-tree-path="/etc/rln_tree"\
    ${RLN_RELAY_CRED_PATH}\
    ${RLN_RELAY_CRED_PASSWORD}\
    ${DNS_WSS_CMD}\
    ${NODEKEY}\
    ${STORE_RETENTION_POLICY}\
    ${EXTRA_ARGS}

