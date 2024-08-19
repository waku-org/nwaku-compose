# nwaku-compose

Ready to use docker-compose to run your own [nwaku](https://github.com/waku-org/nwaku) full node:
* nwaku node running relay and store protocols with RLN enabled.
* Simple frontend to interact with your node and the network, to publish and receive messages.
* Grafana dashboard for advanced users or node operators.
* Requires `docker-compose` and `git`.


**📝 0. Prerequisites**

You need:
* Ethereum Sepolia HTTP endpoint. Get one free from [Infura](https://www.infura.io/).
* Ethereum Sepolia account with some balance <0.01 Eth. Get some [here](https://www.infura.io/faucet/sepolia).
* A password to protect your rln membership.

`docker-compose` [will read the `./.env` file](https://docs.docker.com/compose/environment-variables/set-environment-variables/#additional-information-3) from the filesystem. There is `.env.example` available for you as a template to use for providing the above values. The process when working with `.env` files is to copy the `.env.example`, store it as `.env` and edit the values there.

```
cp .env.example .env
${EDITOR} .env
```

Make sure to **NOT** place any secrets into `.env.example`, as they might be unintentionally published in the Git repository.


**🔑 1. Register RLN membership**

The RLN membership is your access key to The Waku Network. Its registration is done onchain, and allows your nwaku node to publish messages in a decentralized and private way, respecting some [rate limits](https://rfc.vac.dev/spec/64/#rate-limit-exceeded).
Messages exceeding the rate limit won't be relayed by other peers.

This command will register your membership and store it in `keystore/keystore.json`.
Note that if you just want to relay traffic (not publish), you don't need one.

```
./register_rln.sh
```

**🖥️ 2. Start your node**

Start all processes: nwaku node, database and grafana for metrics. Your [RLN](https://rate-limiting-nullifier.github.io/rln-docs/what_is_rln.html) membership is loaded into nwaku under the hood.
```console
docker-compose up -d
```
⚠️ The node might take ~5' the very first time it runs because it needs to build locally the RLN community membership tree.

**🏄🏼‍♂️ 3. Interact with your nwaku node**
* See [localhost:3000](http://localhost:3000/d/yns_4vFVk/nwaku-monitoring) for node metrics.
* See [localhost:4000](http://localhost:4000) for a nice frontend to chat with other users.

**📬 4. Use the REST API**

Your nwaku node exposes a [REST API](https://waku-org.github.io/waku-rest-api/) to interact with it.

```
# get nwaku version
curl http://127.0.0.1:8645/debug/v1/version
# get nwaku info
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

For advanced documentation, refer to [ADVANCED.md](https://github.com/waku-org/nwaku-compose/blob/master/ADVANCED.md).

-----
# How to update to latest version

We regularly announce new available versions in our [Discord](https://discord.waku.org/) server.

If your last running version is `v0.29` or older, you will need to delete both the `keystore` and `rln_tree` folders, and register your membership again before using the new version by running the following commands:

1. `cd nwaku-compose` ( go into the root's repository folder )
2. `docker-compose down`
3. `sudo rm -r keystore rln_tree`
4. `git pull origin master`
5. `./register_rln.sh`
6. `docker-compose up -d`

For nodes running on `v0.30` or newer, updating the node is as simple as running the following:
1. `cd nwaku-compose` ( go into the root's repository folder )
2. `docker-compose down`
3. `git pull origin master`
4. `docker-compose up -d`
