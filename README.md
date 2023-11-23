# go-waku-compose

Ready to use docker-compose to run your own [go-waku](https://github.com/waku-org/go-waku) full node:
* go-waku node running relay and store protocols with RLN enabled.
* Simple frontend to interact with your node and the network, to publish and receive messages.
* Grafana dashboard for advanced users or node operators.
* Requires `docker-compose` and `git`.


**📝 0. Prerequisites**

You need:
* Ethereum Sepolia WebSocket endpoint. Get one free from [Infura](https://www.infura.io/).
* Ethereum Sepolia account with some balance <0.01 Eth. Get some [here](https://www.infura.io/faucet/sepolia).
* A password to protect your rln membership.

```
export ETH_CLIENT_ADDRESS=wss://sepolia.infura.io/ws/v3/YOUR_INFURA_KEY
export ETH_TESTNET_KEY=REPLACE_BY_YOUR_KEY
export KEYSTORE_PASSWORD=PICK_A_PASSWORD
```

**🔑 1. Register RLN membership**

The RLN membership is your access key to The Waku Network. Its registration is done onchain, and allows your go-waku node to publish messages in a decentralized and private way, respecting some [rate limits](https://rfc.vac.dev/spec/64/#rate-limit-exceeded).
Messages exceeding the rate limit won't be relayed by other peers.

This command will register your membership and store it in `keystore/keystore.json`.
Note that if you just want to relay traffic (not publish), you don't need one.

```
./register_rln.sh
```

**🖥️ 2. Start your node**

Start all processes: go-waku node, database and grafana for metrics. Your RLN membership is loaded into go-waku under the hood.
```console
docker-compose up -d
```

**🏄🏼‍♂️ 3. Interact with your go-waku node**
* See [http://localhost:3000/d/yns_4vFVk/go-waku-monitoring](http://localhost:3000/d/yns_4vFVk/go-waku-monitoring) for node metrics.
* See [localhost:4000](http://localhost:4000). Under development 🚧

**📬 4. Use the REST API**

Your go-waku node exposes a [REST API](https://waku-org.github.io/waku-rest-api/) to interact with it.

```
# get go-waku version
curl http://127.0.0.1:8645/debug/v1/version
# get go-waku info
curl http://127.0.0.1:8645/debug/v1/info
```

**Publish a message to a `contentTopic`**. Everyone subscribed to it will receive it. Note that `payload` is base64 encoded.

```
curl -X POST "http://127.0.0.1:8645/relay/v1/auto/messages" \
 -H "content-type: application/json" \
 -d '{"payload":"'$(echo -n "Hello Waku Network - from Anonymous User" | base64)'","contentTopic":"/my-app/2/chatroom-1/proto"}'
```

**Get messages sent to a `contentTopic`**. Note that any store node in the network is used to reply.
```
curl -X GET "http://127.0.0.1:8645/store/v1/messages?contentTopics=%2Fmy-app%2F2%2Fchatroom-1%2Fproto&pageSize=50&ascending=true" \
 -H "accept: application/json"
```

For advanced documentation, refer to [ADVANCED.md](https://github.com/waku-org/go-waku-compose/blob/master/ADVANCED.md).
