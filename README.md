# nwaku-compose

Ready‑to‑use **docker‑compose** stack for running your own [nwaku](https://github.com/waku-org/nwaku) node for a subset of protocols (full node capability is coming soon).:

* RLN‑enabled nwaku node (relay + store protocols, excluding message publishing)
* Simple web UI to publish and receive messages
* Grafana dashboard for metrics
* Requires **Docker Compose** and **Git**

## 📝 Prerequisites

* **Linea Sepolia RPC endpoint** — grab one for free on [Infura](https://www.infura.io)
* **Linea Sepolia wallet** with at least **0.01 ETH** (Only REquired For RLN Membership Registration which is WIP)
  * Need test ETH? Use the [Linea Sepolia faucet](https://www.infura.io/faucet/sepolia)  
  * Already have ETH on Sepolia? Bridge it to Linea via the [official bridge](https://bridge.linea.build/native-bridge)

### 🚀 Starting your node

| # | Option | Quick-start command | What happens | 
|---|------|--------------------|--------------|
| **1** | **script** | Power user / CI | setup a .env file manually and then start the node.|
| **2** | ** WIP setup-wizard** | Fastest one-command bootstrap | Generates `.env`, registers RLN, and spins up the whole stack automatically |

<details>
<summary>🧪 option 1 :- SCRIPT [ manual ] [ recommended ] </summary>

```
cp .env.example .env  
```
Edit the .env file and fill in all required parameters 


### 💽 2. Select DB Parameters

Waku runs a PostgreSQL Database to store messages from the network and serve them to other peers.
To prevent the database to grow indefinitely, you need to select how much disk space to allocate.
You can either run a script that will estimate and set a good value:

```
./set_storage_retention.sh
```

Or select your own value. For example, `50GB`:

```shell
echo "STORAGE_SIZE=50GB" >> .env
```

Depending on your machine's memory, it may be worth allocating more memory to the Postgres container to ensure heavy queries are served:

```shell
./set_postgres_shm.sh
```

Or select your own value manually, for example, `4g`:

```shell
echo "POSTGRES_SHM=4g" >> .env
```

### 🖥️ 3. Start your node

Start all processes: nwaku node, database and grafana for metrics. Your [RLN](https://rate-limiting-nullifier.github.io/rln-docs/what_is_rln.html) membership is loaded into nwaku under the hood.
```console
docker-compose up -d
```
⚠️ The node might take a few minutes the very first time it runs because it needs to build locally the RLN community membership tree.

###🏄🏼‍♂️ 4. Interact with your nwaku node

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

</details>

<details>
<summary>⚙️ option 2 (not recommended at this time):- SETUP-WIZARD [ experimental ]</summary>

Run the wizard script.
Once the script is done, the node will be started for you, so there is nothing else to do.

The script is experimental, feedback and pull requests are welcome.

```
./setup_wizard.sh
```

</details>

### 📌 Note
RLN membership is your access key to The Waku Network. It is registered on-chain, enabling your nwaku node to send messages in a decentralized and privacy-preserving way while adhering to rate limits. Messages exceeding the rate limit will not be relayed by other peers.

If you just want to relay traffic (not publish), you don't need to perform the registration.



-----
<details>
<summary>How to update to latest version</summary>

We regularly announce new available versions in our [Discord](https://discord.waku.org/) server.

### From `v0.35.1` or older

Please review the latest https://github.com/waku-org/nwaku-compose/blob/master/.env.example env var template file and update your .env accordingly.

Make sure you have some ETH in your Linea Sepolia account.
Also, move your Sepolia RPC client (e.g., Infura) to a Linea Sepolia RPC client.

You will need to delete both the `keystore` and `rln_tree` folders, and register your membership again before using the new version by running the following commands:

1. `cd nwaku-compose` ( go into the root's repository folder )
2. `docker-compose down`
3. `sudo rm -r keystore rln_tree`
4. `git pull origin master`
5. `./register_rln.sh`
6. `docker-compose up -d`

### From `v0.36.0` or newer

Updating the node is as simple as running the following:
1. `cd nwaku-compose` ( go into the root's repository folder )
2. `docker-compose down`
3. `git pull origin master`
4. `docker-compose up -d`
</details>

<details>
<summary>Set storage size (optional)</summary>

To improve storage on the network, you can increase the allocated space for the database.
To do so, you can simply run:

```
./set_storage_retention.sh
```
</details>

<details>
<summary>Node's health check</summary>

Once done, check your node is healthy: 

```
./chkhealth.sh 
```

All good:
```
02:15:51 - node health status is:

{
  "nodeHealth": "Ready",
  "protocolsHealth": [
    {
      "Rln Relay": "Ready"
    }
    ...
  ]
}
```

If the `./chkhealth.sh` script is hanging or returns the following, wait a few minutes and run it again:
```
02:17:57 - node health status is:

{
  "nodeHealth": "Initializing",
  "protocolsHealth": []
}
```
</details>

<details>
<summary>Disk cleanup tips</summary>

Docker artefact can take some precious disk space, run the following commands to free space **while your node is running**.

**Only do this if this machine is solely used for Waku and you have no other docker services**.

**I repeat, this will clean other docker services and images not running, only do this if this machine is only used for Waku**.

```
# Be sure that your containers **are running**
sudo docker-compose up -d

# Clean docker system files
sudo docker system prune -a

# Delete docker images
sudo docker image prune -a

# Delete docker containers
sudo docker container prune

# Delete docker volumes
sudo docker volume prune
```

#### journal

If your `/var/log` gets quite large:

```
journalctl --disk-usage
> Archived and active journals take up 1.5G in the file system.
```

You can cap the size in ` /etc/systemd/journald.conf` with

```
SystemMaxUse=50M
```

then restart to apply

```
systemctl restart systemd-journald
```

and verify
```
journalctl --disk-usage
> Archived and active journals take up 55.8M in the file system.
```

</details>

<details>
<summary>FAQ</summary>
[see](FAQ.md)
</details>
