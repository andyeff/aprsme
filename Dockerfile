FROM elixir:1.9.4-slim

# Ensure package list is up to date
RUN apt update
RUN apt install -y curl git

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt install -y nodejs
RUN npm install -g yarn

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
RUN ["yarn", "install"]

WORKDIR /app

# Wait for postgres to become available before starting
CMD /app/wait-for-it.sh postgres:5432 -- /app/start.sh
