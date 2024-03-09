
<h1 align="center"> Waku Setup</h1>

# Sunucu Paketleri update
```console
sudo apt update && sudo apt upgrade -y
sudo apt-get install build-essential git libpq5 jq -y
```

# kodu girdikten sonra 1 yazıyoruz.
```console
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```
```console
sudo apt install docker.io -y
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
# Waku kurulumu için

> wakuyu clonluyoruz
```console
git clone https://github.com/waku-org/nwaku-compose
cd nwaku-compose
cp .env.example .env
```
# .env içinde değişiklik için
> nano .env
```

> Değiştireceğimiz kısımlar bunlar aşağıya yazıyorum:
```console
* `ETH_CLIENT_ADDRESS` = Infura'dan Sepolia RPC aldım bedava onu ekledim - https://www.infura.io/
* `ETH_TESTNET_KEY` = Waku için açtığım metamaskın private keyini ekliyoruz - Metamask hesap bilgileri kısmında
* `RLN_RELAY_CRED_PASSWORD` = Bir şifre belirledim
```
> CTRL X Y ENTER ile kaydedip çıkıyoruz.

```console
# ve register edelim.
./register_rln.sh
# register etmeden önce cüzdanda sepolia eth olmalı
```

<h1 align="center"> Waku node başlatma </h1>

```console
# firewallda portları aktif ediyoruz.

# yes diyelim aşağıdaki komutu girdikten sonra
sudo ufw enable
sudo ufw allow 22    
sudo ufw allow 3000   
sudo ufw allow 8545   
sudo ufw allow 8645   
sudo ufw allow 9005   
sudo ufw allow 30304  
sudo ufw allow 8645

# dockerları ayağa kaldıralım
> docker-compose up -d
# dockerları kontrol edelim
> docker-compose ps
```
# bu komut ile içersine girelim:

nano ~/nwaku-compose/docker-compose.yml
```console
> içersine girdikten sonra `ctrl w` yaparak `3000:3000` portuna bakalım
> `127.0.0.1:3000:3000` yazıyor ise  `0.0.0.0:3000:3000`şeklinde düzeltelim ve docker-compose down-up yazalım.
```

> Yaklaşık 30 dk içersine verileriniz güncellenecek

> `http://IP_ADRESİN:3000/d/yns_4vFVk/nwaku-monitoring`

> IP_ADRESİN kendi sunucunuzun ipsi ile tarayıcıdan açın.

> Yedekleme için `keystore.json` dosyasını kaydedin.



