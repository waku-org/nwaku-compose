# nwaku-compose

Ready‑to‑use **docker compose** stack for running your own [nwaku](https://github.com/waku-org/nwaku) node.

## 📝 Prerequisites

- **Docker** and **Git**
- **Linea Sepolia RPC endpoint** You can get a free endpoint from [Infura](https://www.infura.io) or any other Linea Sepolia RPC provider.
 
### 🚀 Starting your node

| #     | Setup Type          | Setup Style          | What happens                                                                | 
|-------|---------------------|----------------------|-----------------------------------------------------------------------------|
| **A** | **manual**          | Power User           | Setup a .env file manually and then start the node.                         |
| **B** | **setup-wizard**    | Command-Line         | Generates `.env`, starts the node.                                          |

<details>
<summary>🧪 OPTION A :- manual [ recommended ] </summary>

### 1. Setup .env file
```
cp .env.example .env  
```
Edit the .env file and fill in all required parameters 

### 💽 2. Set Database Parameters

Waku uses PostgreSQL to store and serve messages.  
Limit disk usage and (optionally) increase shared memory for better performance.

| Setting        | Auto-set command                | Manual example                       |
|----------------|---------------------------------|--------------------------------------|
| Storage size   | `./set_storage_retention.sh`    | `echo "STORAGE_SIZE=50GB" >> .env`   |
| Shared memory  | `./set_postgres_shm.sh`         | `echo "POSTGRES_SHM=4g" >> .env`     |

### 🖥️ 3. Start your node

Start all processes: nwaku node, database and grafana for metrics. 

```
docker compose up -d
```

</details>

<details>
<summary>⚙️ OPTION B :- setup-wizard [ experimental ]</summary>

Run the wizard script.
Once the script is done, the node will be started for you, so there is nothing else to do.

The script is experimental, feedback and pull requests are welcome.

```
./setup_wizard.sh
```

</details>

<<<<<<< Updated upstream

### 🛑 Shutting down your node

To gracefully shut down your node:
```shell
docker compose down
```

=======
### 🏄🏼‍♂️ 4. Monitor your nwaku node

- **Metrics (Grafana):**  
  Open [localhost:3000](http://localhost:3000/d/yns_4vFVk/nwaku-monitoring) to view node metrics.  
  Metrics will appear **only if your node is running correctly**.

- **Live logs:**  
  See what’s happening inside your node in real time:  
  ```bash
  docker compose logs nwaku -f --tail 100
  ```

**📬 5. Use the REST API**

Your nwaku node exposes a [REST API](https://waku-org.github.io/waku-rest-api/) to interact with it.
```
# get nwaku version
curl http://127.0.0.1:8645/debug/v1/version
# get nwaku info
curl http://127.0.0.1:8645/debug/v1/info
```

For advanced documentation, refer to [ADVANCED.md](https://waku-org.github.io/waku-rest-api/).

>>>>>>> Stashed changes
### 📌 Note
RLN membership is your access key to The Waku Network. It is registered on-chain, enabling your nwaku node to send messages in a decentralized and privacy-preserving way while adhering to rate limits. Messages exceeding the rate limit will not be relayed by other peers.

If you just want to relay traffic (not publish), you don't need to perform the registration.

-----
<details>
<summary>How to update to latest version</summary>

We regularly announce new available versions in our [Discord](https://discord.waku.org/) server.

### From `v0.35.1` or older

Please review the latest https://github.com/waku-org/nwaku-compose/blob/master/.env.example env var template file and update your .env accordingly.

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
