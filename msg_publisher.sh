#!/bin/sh

while true
do
    ## Target of ~10kB
    payload_size=$(( RANDOM % 2000 + 9000 ))
    payload=$(openssl rand -hex ${payload_size} | base64 | tr -d '\n')

    #  echo "publishing ${payload}"

    # Example on how to publish to autosharding endpoint
    #  curl -X POST "http://127.0.0.1:8646/relay/v1/auto/messages"  -H "content-type: application/json"  -d '{"payload":"'${payload}'","contentTopic":"/my-app/0/my-ctopic/enc"}'

    # publish towards waku.test:
    # curl -X POST "http://127.0.0.1:8645/relay/v1/messages/%2Fwaku%2F2%2Frs%2F1%2F1"  -H "content-type: application/json"  -d '{"payload":"'${payload}'","contentTopic":"my-ctopic", "timestamp":'$(date +%s%N)'}'
    # curl -X POST "http://127.0.0.1:8645/relay/v1/messages/%2Fwaku%2F2%2Frs%2F1%2F0"  -H "content-type: application/json"  -d '{"payload":"'${payload}'","contentTopic":"my-ctopic", "timestamp":'$(date +%s%N)'}'
    
    # publish towards waku2.test:
    curl -X POST "http://127.0.0.1:8645/relay/v1/messages/%2Fwaku%2F2%2Fdefault-waku%2Fproto"  -H "content-type: application/json"  -d '{"payload":"'${payload}'","contentTopic":"my-ctopic", "timestamp":'$(date +%s%N)'}'
    #  curl -X POST "http://127.0.0.1:8646/relay/v1/messages/%2Fwaku%2F2%2Fdefault-waku%2Fproto"  -H "content-type: application/json"  -d '{"payload":"'${payload}'","contentTopic":"my-ctopic"}'

sleep 1.5
done
