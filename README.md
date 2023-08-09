# nwaku-compose

Ready to use docker-compose that runs a [nwaku](https://github.com/waku-org/nwaku) node and monitors it with already set up and configured postgres, grafana and prometheus instances. All in just a few steps.

## Instructions

Note that you must have installed `docker-compose` and `git`.

Get the code:

```console
git clone https://github.com/alrevuelta/nwaku-compose.git
cd nwaku-compose
```

Edit the environment variables present at the beginning of the `docker-compose.yml` file.

Start everything: `nwaku`, `postgres`, `prometheus`, and `grafana`.
```console
docker-compose up -d
```

Go to [http://localhost:3000/d/yns_4vFVk/nwaku-monitoring?orgId=1](http://localhost:3000/d/yns_4vFVk/nwaku-monitoring?orgId=1) and after some seconds, your node metrics will be live there, just like in the picture. As simple as that.

![grafana-dashboard](https://i.ibb.co/C6m7JHN/Screenshot-2022-12-01-at-11-09-28.png)


Notes:
* Feel free to change the image you are using `statusteam/nim-waku:xxx`. You can see the available tags in [docker hub](https://hub.docker.com/r/statusteam/nim-waku).
* If you want to access grafana from outside your machine, feel free to remove `127.0.0.1` and open the port, but in that case you may want to set up a password to your grafana.