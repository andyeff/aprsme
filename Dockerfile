########################################
# 1. Build nodejs frontend
########################################
FROM node:12.14.0-alpine3.11 as build-node

# prepare build dir
RUN mkdir -p /app/assets
WORKDIR /app

# set build ENV
ENV NODE_ENV=prod

# install npm dependencies
COPY assets ./assets/
COPY deps/phoenix deps/phoenix
COPY deps/phoenix_html deps/phoenix_html
COPY deps/phoenix_live_view deps/phoenix_live_view

RUN cd assets && npm install
RUN cd assets && npm rebuild node-sass
RUN npm run deploy

########################################
# 2. Build elixir backend
########################################
FROM elixir:1.9.4-alpine as build-elixir

RUN apk add --update git bash

# prepare build dir
RUN mkdir /app
WORKDIR /app

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# Set environment files
ENV MIX_ENV=prod

# install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get

# copy only elixir files to keep the cache
COPY config /app/config/
COPY lib /app/lib/
COPY priv /app/priv/
COPY start.sh /app/
COPY wait-for-it.sh /app/

RUN mix deps.compile

# copy assets from node build
COPY --from=build-node /app/priv/static ./priv/static
RUN mix phx.digest

# build release
RUN mix release

########################################
# 3. Build release image
########################################
FROM alpine:3.11.2
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build-elixir /app/_build/prod/rel/aprsme ./

ARG VERSION
ENV VERSION=$VERSION
ENV REPLACE_OS_VARS=true
#EXPOSE 80

ENTRYPOINT ["/app/bin/aprsme"]
CMD ["start"]

#WORKDIR /app
#RUN npm run deploy --prefix ./assets
#RUN mix phx.digest

# Wait for rabbit to become available before starting
#CMD /app/wait-for-it.sh rabbitmq:5672 -- /app/start.sh
