FROM elixir:1.9.4-slim

# Ensure package list is up to date
RUN apt update
RUN apt install -y curl git

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt install -y nodejs
RUN npm install -g yarn

# Copy in files
COPY assets /app/assets/
COPY config /app/config/
COPY lib /app/lib/
COPY priv /app/priv/
COPY mix* /app/
COPY start.sh /app/
COPY wait-for-it.sh /app/

# Set working directory to /app
WORKDIR /app

# Set environment files
ENV MIX_ENV=prod
ENV PORT=80

# Install hex
RUN ["mix", "local.hex", "--force"]
# Install rebar
RUN ["mix", "local.rebar", "--force"]
# Install dependencies
RUN ["mix", "deps.get"]
# Compile
RUN ["mix", "compile"]

# Build assets
WORKDIR /app/assets
RUN ["yarn", "install"]

# Wait for postgres to become available before starting
CMD /app/wait-for-it.sh postgres:5432 -- /app/start.sh
