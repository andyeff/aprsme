FROM elixir:1.9.4-alpine

# Ensure package list is up to date
#RUN apt update
#RUN apt install -y curl git

# Install nodejs
#RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
#RUN apt install -y nodejs
#RUN npm install -g yarn
RUN apk add --update nodejs nodejs-npm git

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

RUN mix deps.get --only prod
RUN mix deps.compile

# Build assets
WORKDIR /app/assets
#RUN npm install && ./node_modules/webpack/bin/webpack.js --mode production
#RUN mix phx.digest

WORKDIR /app

# Wait for rabbit to become available before starting
CMD /app/wait-for-it.sh rabbitmq:5672 -- /app/start.sh
