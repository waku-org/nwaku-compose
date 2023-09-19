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
* `EXTRA_ARGS` - this variable allows you to specify additional or overriding CLI option for the Waku node which will be appended to the `wakunode2` command. (e.g. `EXTRA_ARGS="--store=false --max-connections=3000`)