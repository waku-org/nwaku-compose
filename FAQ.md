⚠️⚠️ There are no incentives or rewards for running a Waku node. ⚠️⚠️
🛑🛑 DO NOT RUN A NODE IF YOU ARE EXPECTING REWARDS 🛑🛑 

# Waku FAQ

- [Does my node work properly?](#does-my-node-work-properly)
- [My node is not able to start properly](#My-node-is-not-able-to-start-properly)
- [Does the running node have any incentives?](#does-running-a-node-have-any-incentives)
- [Error when running .register_rln.sh](#error-when-running-register_rlnsh)
- [Problem with Grafana](#does-my-grafana-looks-right)
- [Migrate my setup to another server?](#how-to-migrate-my-setup-to-another-server)

----

### Does my node work properly?
Your node should have at least 40 connected peers, and you should see some traffic in and out, in the Grafana board.

1. Run `docker ps` and check that the `wakuorg/nwaku` container is not continuously restarting
2. Use the following commands to check the node better:
    1. `curl -X GET http://localhost:8645/health`
    2. `curl -X GET http://localhost:8645/debug/v1/info`
    3. `curl -X GET http://localhost:8645/debug/v1/version`
    4. `curl -X GET http://localhost:8645/admin/v1/peers`
    5. `curl -X GET http://localhost:8645/admin/v1/filter/subscriptions`
    6. `curl -X GET http://localhost:8003/metrics`
3. Check the following local services:
    1. Grafana: [http://localhost:3000/](http://localhost:4000/)
    2. Local node front end: http://localhost:4000/


### My node is not able to start properly
If you are using Contabo, we recommend moving to a different VPS vendor.
If not, remove the keystore and rln_tree folders, run the ./register_rln script again, and try to run your node again.

### Does running a node have any incentives?
There are currently no incentives in place, but it's something currently being researched and designed.

### Error when running .register_rln.sh

> ERR 2024-06-23 16:05:04.984+00:00 failure while initializing OnchainGroupManager topics="rln_keystore_generator" tid=1 file=rln_keystore_generator.nim:61 error="Failed to get the chain id: Forbidden"

There is a problem with you EthClient account.
Take a closer look on how you set the values of the .env file paying attention to example, and make sure you have a valid EthClient.

### Does my Grafana looks right?

It should look like:
http://5.196.26.230:3000/d/yns_4vFVk/nwaku-monitoring?orgId=1&refresh=1m


### How to migrate my setup to another server?

1. Clone [nwaku-compose](https://github.com/waku-org/nwaku-compose) in the new server.

2. Move your `keystore` folder (`nwaku-compose/keystore/`) from your current setup to the new server.

   That folder was created when you executed `./register_rln.sh`,
and then, there is no need to run `./register_rln.sh` again.


