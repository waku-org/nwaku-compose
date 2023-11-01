# nwaku-compose

Ready to use docker-compose to run your own [nwaku](https://github.com/waku-org/nwaku) full node. Description:
* nwaku node running relay and store protocols with RLN enabled.
* Simple frontend to interact with your node and the network, to publish and receive messages.
* Grafana dashboard for advanced users or node operators.
* Requires `docker-compose` and `git`.

**1. Get the code:**
```console
git clone git@github.com:waku-org/nwaku-compose.git
cd nwaku-compose
```

**2. Provide your Ethereum node**
Waku needs an Ethereum Sepolia node, either yours or from a third party. Provide a websockets endpoint. You can get one for free from [Infura](https://www.infura.io/).
```
export ETH_CLIENT_ADDRESS=wss://sepolia.infura.io/ws/v3/USE_YOUR_INFURA_KEY_HERE
```

**3. Start everything**
```console
docker-compose up -d
```

**4. Register your RLN membership**
If you just want to relay traffic in the network, you are all set. But if you want to publish messages, you need an RLN membership. Its a simple onchain transaction, you need:
* A wallet with some Sepolia Eth, <0.1 Eth.
* Go to [localhost:4000](http://localhost:4000) and `Register Credentials`. Set a `password` and `Export` it as `keystore.json`
* In your nwaku node, set. TODO: Improve manual process.
  * `rln-relay-cred-password` to the `password` you chose.
  * `rln-relay-cred-path` to `keystore.json`

**5. Interact with your nwaku node**
* See [localhost:4000](http://localhost:4000) to interact with your node
* See [localhost:3000](http://localhost:3000) for advanced metrics.

For advanced documentation, refer to [ADVANCED.md](https://github.com/waku-org/nwaku-compose/blob/master/ADVANCED.md).