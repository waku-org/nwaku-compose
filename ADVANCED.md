# Advanced

Information for advances users

## Configuration

There are multiple environment variables you can configure to modify behaviour of the Waku node:

* `NWAKU_IMAGE` - the image you want to use for the nwaku container (e.g. `NWAKU_IMAGE=statusteam/nim-waku:v0.19.0-rc.0`). You can see the available tags in [docker hub](https://hub.docker.com/r/waku-org/nwaku).
* `DOMAIN` - domain name pointing to the IP address of your node, when configured the run script will request SSL certs from Let's Encrypt and run Waku node with WebSockets Secure (WSS) options enabled (e.g. `DOMAIN=waku.example.com`)
* `NODEKEY` - this env variable allows you to provide a node key as described in [operators documentation](https://github.com/waku-org/nwaku/blob/master/docs/operators/how-to/configure-key.md) (e.g. `NODEKEY=9f439983aa4851346cfe6e17585e426f482871a43626812e23490895cd602c11`)
* `RLN_RELAY_ETH_CLIENT_ADDRESS` (**mandatory**) - URL to an HTTP Ethereum node URL on the same network as the contract address. If you're not running your own node, you can get the URL at Infura with the following [instructions](https://docs.infura.io/networks/ethereum/how-to/choose-a-network)
* `RLN_RELAY_CRED_PATH` - path for peristing rln-relay credential
* `RLN_RELAY_CRED_PASSWORD` - password for encrypting RLN credentials
* `EXTRA_ARGS` - this variable allows you to specify additional or overriding CLI option for the Waku node which will be appended to the `wakunode2` command. (e.g. `EXTRA_ARGS="--store=false --max-connections=3000`)
* `CERTS_DIR` - allows you to define a path where SSL certificates are/will be stored. It needs to follow the directory structure produced by Certbot in `/etc/letsencrypt`
* `STORAGE_SIZE` - overrides the default allowed DB size of Waku message storage service. Current default is 1GB. (e.g. `STORAGE_SIZE=2GB` or `STORAGE_SIZE=3500MB`)
* `PROMETHEUS_RETENTION_SIZE` - overrides the default allow data dir for Prometheus data (which feeds Grafana). Current default is 5GB. (e.g. `PROMETHEUS_RETENTION_SIZE=1GB`)

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

## RLN - Rate Limit Nullifier

RLN is the technology used to achieve the rate limiting feature, which combines zero-knowledge
proofs, hashing, Merkle tree, Blockchain, etc.

Deeper technical details can be found in:
* [RLN-V1 spec](https://rfc.vac.dev/spec/32/)
* [RLN-V2 spec](https://rfc.vac.dev/spec/58/)

## DB Administration

In case compositon is started with command
```console
docker compose --profile dbadmin up -d
```
an additional service - pgadmin - is started and can be accessed from browser on http://localhost:15432
That will give insights on the Node's message store database.

### Shutting down the container with pgadmin service

If started with 'dbadmin' profile it must be used when stopping it:
```console
docker compose --profile dbadmin down
```
