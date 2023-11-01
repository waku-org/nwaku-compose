# nwaku-compose

Ready to use docker-compose to run your own [nwaku](https://github.com/waku-org/nwaku) full node. Features:
* nwaku node running relay and store protocols with RLN enabled.
* simple frontend to interact with your node and the network, to publish and receive messages.
* grafana dashboard for advances users or node operators.

You need `docker-compose` and `git`.

Get the code:
```console
git clone git@github.com:waku-org/nwaku-compose.git
cd nwaku-compose
```

Waku needs an Ethereum Sepolia node, either yours or from a third party. Provide a websockets endpoint. You can get one for free from [Infura](https://www.infura.io/).
```
export ETH_CLIENT_ADDRESS=wss://sepolia.infura.io/ws/v3/USE_YOUR_INFURA_KEY_HERE
```

Start everything.
```console
docker-compose up -d
```

Your node is now connected to the network:
* See [localhost:4000](localhost:4000) to interact with your node
* See [localhost:3000](localhost:3000) for advanced metrics.

If you just want to relay traffic in the network, you are all set. If you want to publish messages, you would need an RLN membership. For that you need:
* A wallet with some Sepolia Eth, <0.1 Eth.
* Go to [localhost:4000](localhost:4000) and `Register Credentials`. Set a `password`` and `Export` it as `keystore.json`
* In your nwaku node, set:
  * `rln-relay-cred-password` to the `password` you chose.
  * `rln-relay-cred-path` to `keystore.json`

**Note**: TODO: This last step of setting the keystore.json is quite manual. To be improved.

For advanced documentation, refer to [ADVANCED.md](https://github.com/waku-org/nwaku-compose/blob/master/ADVANCED.md).