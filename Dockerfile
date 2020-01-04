FROM elixir:1.9.4-alpine

RUN apk add --update nodejs nodejs-npm git bash

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# Copy in files
COPY assets /app/assets/
COPY config /app/config/
COPY lib /app/lib/
COPY priv /app/priv/
COPY mix.exs /app/
COPY mix.* /app/
COPY start.sh /app/
COPY wait-for-it.sh /app/

# Set working directory to /app
WORKDIR /app

# Set environment files
ENV MIX_ENV=prod
ENV PORT=80

RUN mix do deps.get --only $MIX_ENV, deps.compile, compile

# Build assets
WORKDIR /app/assets
RUN npm install && ./node_modules/webpack/bin/webpack.js --mode production

WORKDIR /app
RUN npm run deploy --prefix ./assets
RUN mix phx.digest

# Wait for rabbit to become available before starting
CMD /app/wait-for-it.sh rabbitmq:5672 -- /app/start.sh
