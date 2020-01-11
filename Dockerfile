########################################
# 1. Build elixir backend
########################################
FROM elixir:1.9.4-alpine as build-elixir

RUN apk add --update git bash nodejs npm

# prepare build dir
RUN mkdir /app
WORKDIR /app
RUN mkdir -p /app/assets

# set build ENV
ENV NODE_ENV=prod
ENV MIX_ENV=prod

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

# install npm dependencies
COPY assets ./assets/

RUN cd assets && npm install
RUN cd assets && npm rebuild node-sass
RUN cd assets && npm run deploy

# copy only elixir files to keep the cache
COPY config /app/config/
COPY lib /app/lib/
COPY priv /app/priv/
COPY start.sh /app/
COPY wait-for-it.sh /app/

RUN mix deps.compile
RUN mix phx.digest

# build release
RUN mix release

########################################
# 2. Build release image
########################################
FROM alpine:3.11.2
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build-elixir /app/_build/prod/rel/aprsme ./

ARG VERSION
ENV VERSION=$VERSION
ENV REPLACE_OS_VARS=true

ENTRYPOINT ["/app/bin/aprsme"]
CMD ["start"]
