# ----------------------------------------------------------------------
# Shorebird Patch Rush — Lobby & Tournament WebSocket Server Dockerfile
# Deployable to Railway, Render, Fly.io, or any container host
# ----------------------------------------------------------------------

FROM dart:stable AS build

WORKDIR /app

# Cache dependencies
COPY pubspec.* ./
RUN dart pub get

# Build native binary
COPY . .
RUN dart compile exe bin/lobby_server.dart -o bin/server

# Minimal runtime image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/bin/server /app/server
RUN mkdir -p /app/bin/data

ENV PORT=8088
EXPOSE 8088

CMD ["/app/server"]
