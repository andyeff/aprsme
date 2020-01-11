# APRSme

## Local Development

## Start dependencies with docker-compose (will start rabbitmq, aprs injest, and postgresql.)
    $ docker-compose -f docker-compose.dev.yml up

You can then view the RabbitMQ admin at http://localhost:15672/
The default bitnami username and password are in docker-compose.yml

## In another terminal, run the actual app

## Install dependencies:

    $ mix deps.get

## Start the web server:

    $ iex -S mix phx.server

## Migrate the database:

    $ mix ecto.migrate

## Seed the database and create an admin user:

    $ mix run priv/repo/seeds.exs

Then navigate to <a href="http://127.0.0.1:4000/">http://127.0.0.1:4000/</a> and you should see the messages coming in via websocket.

## Running tests

    $ mix test.watch

## Troubleshooting message publishing

Use the script (requires jq to be installed):

    $ ./bin/inspect_rabbit

You can also retrieve RabbitMQ publish/deliver stats using cURL, the Rabbit management API, and the `jq` command.

Retrieve the number of messages published by the Perl script. If it is zero, nothing is being published at all.

    $ curl -s -u guest:guest http://localhost:15672/api/exchanges/aprs/aprs:messages | jq '.message_stats .publish_in_details .rate'

Retrieve publish & deliver rates for the aprs:archive queue:

    $ curl -s -u guest:guest http://localhost:15672/api/queues/aprs/aprs:archive | jq '.message_stats'

```json
{
  "deliver_get": 90813,
  "deliver_get_details": {
    "rate": 0
  },
  "deliver_no_ack": 90813,
  "deliver_no_ack_details": {
    "rate": 0
  },
  "publish": 92103,
  "publish_details": {
    "rate": 52
  }
}
```

  * If `publish_details.rate` drops to 0, then the Perl ingest script is either not properly running, or the exchange is wired wrong.

        $ ... | jq '.message_stats .publish_details .rate'


  * If `deliver_get_details.rate` drops to 0, then nothing is consuming messages from aprs:archive (there is a problem).

        $ ... | jq '.message_stats .deliver_get_details .rate'


## Store.js docs
  * https://github.com/marcuswestin/store.js

## Dokku config vars MUST be set
  * DATABASE_URL
  * DOKKU_LETSENCRYPT_EMAIL: grahamREMOVEME@mcintireREMOVE.me
  * HOSTNAME:                aprs.me
  * RABBITMQ_URL
  * SECRET_KEY_BASE

## Thanks
  * APRS symbols from https://github.com/smarek/aprs-symbols
