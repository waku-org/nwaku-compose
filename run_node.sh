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
        WSS_CERT="--websocket-secure-cert-path=${LETSENCRYPT_PATH}/cert.pem"
        DNS4_DOMAIN="--dns4-domain-name=${DOMAIN}"

        DNS_WSS_CMD="${WS_SUPPORT} ${WSS_SUPPORT} ${WSS_CERT} ${WSS_KEY} ${DNS4_DOMAIN}" 
    fi
fi

if [ -n "${NODEKEY}" ]; then
    NODEKEY=--nodekey=${NODEKEY}
fi

RLN_RELAY_CRED_PATH=--rln-relay-cred-path=${RLN_RELAY_CRED_PATH:-/keystore/keystore.json}


if [ -n "${RLN_RELAY_CRED_PASSWORD}" ]; then
    RLN_RELAY_CRED_PASSWORD=--rln-relay-cred-password="${RLN_RELAY_CRED_PASSWORD}"
fi

STORE_RETENTION_POLICY=--store-message-retention-policy=size:1GB

if [ -n "${STORAGE_SIZE}" ]; then
    STORE_RETENTION_POLICY=--store-message-retention-policy=size:"${STORAGE_SIZE}"
fi

exec /usr/bin/wakunode\
    --relay=true\
    --filter=true\
    --lightpush=true\
    --keep-alive=true\
    --max-connections=150\
    --cluster-id=16\
    --shard=32\
    --discv5-discovery=true\
    --discv5-bootstrap-node="enr:-QEKuED9AJm2HGgrRpVaJY2nj68ao_QiPeUT43sK-aRM7sMJ6R4G11OSDOwnvVacgN1sTw-K7soC5dzHDFZgZkHU0u-XAYJpZIJ2NIJpcISnYxMvim11bHRpYWRkcnO4WgAqNiVib290LTAxLmRvLWFtczMuc3RhdHVzLnByb2Quc3RhdHVzLmltBnZfACw2JWJvb3QtMDEuZG8tYW1zMy5zdGF0dXMucHJvZC5zdGF0dXMuaW0GAbveA4Jyc40AEAUAAQAgAEAAgAEAiXNlY3AyNTZrMaEC3rRtFQSgc24uWewzXaxTY8hDAHB8sgnxr9k8Rjb5GeSDdGNwgnZfg3VkcIIjKIV3YWt1Mg0"\
    --discv5-bootstrap-node="enr:-QEcuED7ww5vo2rKc1pyBp7fubBUH-8STHEZHo7InjVjLblEVyDGkjdTI9VdqmYQOn95vuQH-Htku17WSTzEufx-Wg4mAYJpZIJ2NIJpcIQihw1Xim11bHRpYWRkcnO4bAAzNi5ib290LTAxLmdjLXVzLWNlbnRyYWwxLWEuc3RhdHVzLnByb2Quc3RhdHVzLmltBnZfADU2LmJvb3QtMDEuZ2MtdXMtY2VudHJhbDEtYS5zdGF0dXMucHJvZC5zdGF0dXMuaW0GAbveA4Jyc40AEAUAAQAgAEAAgAEAiXNlY3AyNTZrMaECxjqgDQ0WyRSOilYU32DA5k_XNlDis3m1VdXkK9xM6kODdGNwgnZfg3VkcIIjKIV3YWt1Mg0"\
    --discv5-bootstrap-node="enr:-QEcuEAoShWGyN66wwusE3Ri8hXBaIkoHZHybUB8cCPv5v3ypEf9OCg4cfslJxZFANl90s-jmMOugLUyBx4EfOBNJ6_VAYJpZIJ2NIJpcIQI2hdMim11bHRpYWRkcnO4bAAzNi5ib290LTAxLmFjLWNuLWhvbmdrb25nLWMuc3RhdHVzLnByb2Quc3RhdHVzLmltBnZfADU2LmJvb3QtMDEuYWMtY24taG9uZ2tvbmctYy5zdGF0dXMucHJvZC5zdGF0dXMuaW0GAbveA4Jyc40AEAUAAQAgAEAAgAEAiXNlY3AyNTZrMaEDP7CbRk-YKJwOFFM4Z9ney0GPc7WPJaCwGkpNRyla7mCDdGNwgnZfg3VkcIIjKIV3YWt1Mg0"\
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
    "${RLN_RELAY_CRED_PATH}"\
    "${RLN_RELAY_CRED_PASSWORD}"\
    ${DNS_WSS_CMD}\
    ${NODEKEY}\
    ${STORE_RETENTION_POLICY}\
    ${EXTRA_ARGS}






