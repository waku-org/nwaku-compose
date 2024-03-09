
<h1 align="center"> Waku Setup</h1>

# Update Server Packages
```console
sudo apt update && sudo apt upgrade -y
sudo apt-get install build-essential git libpq5 jq -y
```

# After entering the code, we press the 1 key
```console
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```
```console
sudo apt install docker.io -y
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
# waku for installation

> waku clone
```console
git clone https://github.com/waku-org/nwaku-compose
cd nwaku-compose
cp .env.example .env
```
# .env for change in
> nano .env
```

> These are the parts we will change:
```console
* `ETH_CLIENT_ADDRESS` = I bought Sepolia RPC from Infura and added it for free - https://www.infura.io/
* `ETH_TESTNET_KEY` = We add the metamask private key that I opened for Waku - in the Metamask account information section
* `RLN_RELAY_CRED_PASSWORD` = I set a password
```
> CTRL X Y ENTER We save and exit with .

```console
# Let's register.
./register_rln.sh
# Must have Sepolia eth in wallet before registering
```

<h1 align="center"> Waku node initialization </h1>

```console
# We activate the ports in the firewall.

# Let's say yes after entering the following command
sudo ufw enable
sudo ufw allow 22    
sudo ufw allow 3000   
sudo ufw allow 8545   
sudo ufw allow 8645   
sudo ufw allow 9005   
sudo ufw allow 30304  
sudo ufw allow 8645

# Let's get the dockers up
> docker-compose up -d
# let's check dockers
> docker-compose ps
```
# Let's get into it with this command:

nano ~/nwaku-compose/docker-compose.yml
```console
> Once inside, let's look at port '3000:3000' by pressing 'ctrl w'.
> `If it says `127.0.0.1:3000:3000`, let's correct it as `0.0.0.0:3000:3000` and write docker-compose down-up.
```

> Your data will be updated in approximately 30 minutes.

> `http://IP_ADRESS:3000/d/yns_4vFVk/nwaku-monitoring`

> Open your IP ADDRESS from the browser with the IP of your own server.

> Save the `keystore.json` file for backup.



