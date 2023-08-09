#!/bin/sh

echo "I am a nwaku node"

MY_EXT_IP=$(wget -qO- https://api4.ipify.org)

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
  --dns-discovery-url=enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@prod.waku.nodes.status.im\
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
  --nat=extip:"${MY_EXT_IP}"\
  --store=true\
  --store-message-db-url="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/postgres"\
  --store-message-retention-policy=time:86400
