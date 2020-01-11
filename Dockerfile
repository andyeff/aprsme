########################################
# 1. Build container
########################################
FROM bitwalker/alpine-elixir-phoenix:latest AS phx-builder


ENV MIX_ENV=prod
ENV NODE_ENV=prod

# prepare build dir
RUN mkdir -p /app/assets
WORKDIR /app

# Elixir stuff
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# NPM stuff
COPY assets ./assets
RUN cd assets && \
    npm install

# Copy files
COPY config /app/config/
COPY lib /app/lib/
COPY priv /app/priv/
COPY start.sh /app/
COPY wait-for-it.sh /app/

# Build steps
RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

# Build release
RUN mix release

# ########################################
# # 3. Build release image
# ########################################
FROM alpine:3.11.2
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=phx-builder /app/_build/prod/rel/aprsme ./

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
