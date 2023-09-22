# nwaku-compose

Ready to use docker-compose that runs a [nwaku](https://github.com/waku-org/nwaku) node and monitors it with already set up and configured postgres, grafana and prometheus instances. All in just a few steps.

## Instructions

Note that you must have installed `docker-compose` and `git`.

Get the code:

```console
git clone git@github.com:waku-org/nwaku-compose.git
cd nwaku-compose
```

Edit the environment variables present at the beginning of the `docker-compose.yml` file.

It is required to set the `ETH_CLIENT_ADDRESS` environment variable within the `docker-compose.yml` file before starting the instance.

`ETH_CLIENT_ADDRESS` must be a WebSockets URL for your Ethereum Node.
For the current default contract, it must be a node for the Sepolia network.
In case you're not running your own node, you can get it from [Infura](https://www.infura.io/)

Start everything: `nwaku`, `postgres`, `prometheus`, and `grafana`.
```console
docker-compose up -d
```

Go to [http://localhost:3000/d/yns_4vFVk/nwaku-monitoring?orgId=1](http://localhost:3000/d/yns_4vFVk/nwaku-monitoring?orgId=1), type the credentials (by default,"admin", "admin") and after some seconds, your node metrics will be live there, just like in the picture. As simple as that.

![grafana-dashboard](https://i.ibb.co/C6m7JHN/Screenshot-2022-12-01-at-11-09-28.png)


Notes:
* Feel free to change the image you are using `statusteam/nim-waku:xxx`. You can see the available tags in [docker hub](https://hub.docker.com/r/statusteam/nim-waku).
* If you want to access grafana from outside your machine, feel free to remove `127.0.0.1` and open the port, but in that case you may want to set up a password to your grafana.

## Configuration

There are multiple environment variables you can configure to modify behaviour of the Waku node:

* `NWAKU_IMAGE` - the image you want to use for the nwaku container (e.g. `NWAKU_IMAGE=statusteam/nim-waku:v0.19.0-rc.0`)
* `DOMAIN` - domain name pointing to the IP address of your node, when configured the run script will request SSL certs from Let's Encrypt and run Waku node with WebSockets Secure (WSS) options enabled (e.g. `DOMAIN=waku.example.com`)
* `NODEKEY` - this env variable allows you to provide a node key as described in [operators documentation](https://github.com/waku-org/nwaku/blob/master/docs/operators/how-to/configure-key.md) (e.g. `NODEKEY=9f439983aa4851346cfe6e17585e426f482871a43626812e23490895cd602c11`)
* `RLN_RELAY_CONTRACT_ADDRESS` - address of the RLN Relay Contract. It defaults to a Sepolia testnet address
* `ETH_CLIENT_ADDRESS` (**mandatory**) - URL to a WebSockets Ethereum node URL on the same network as the contract address. If you're not running your own node, you can get the URL at Infura with the following [instructions](https://docs.infura.io/networks/ethereum/how-to/choose-a-network)
* `RLN_RELAY_CRED_PATH` - path for peristing rln-relay credential
* `RLN_RELAY_CRED_PASSWORD` - password for encrypting RLN credentials
* `EXTRA_ARGS` - this variable allows you to specify additional or overriding CLI option for the Waku node which will be appended to the `wakunode2` command. (e.g. `EXTRA_ARGS="--store=false --max-connections=3000`)

## Log monitoring and troubleshooting

When running the container in detached mode, it's important to note that while notifications about successful container startup are received, any errors occurring during runtime won't be printed to the terminal.

To ensure the proper functioning of the container, it is strongly recommended to monitor the logs. Pay special attention during the first minute of runtime to confirm that the node has spun up successfully.

To check the status of the node, visit [http://localhost:8003/health](http://localhost:8003/health)

For real-time logs of the 'nwaku' service, use the following command:

```console
docker-compose logs -f nwaku
```

In general, to view logs of any service running on Docker Compose, execute:

```console
docker-compose logs -f <service>
```

To identify different services currently running, refer to the "SERVICE" column displayed when executing:
```console
docker-compose ps
```

![services](https://i.ibb.co/ZXG3Ld9/image.png)