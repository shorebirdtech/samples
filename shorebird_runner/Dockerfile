# ----------------------------------------------------------------------
# Shorebird Patch Rush — All-in-One Cloud Dockerfile (Render, Railway, Fly.io)
# Builds Flutter Web Release + Dart WebSocket Server into a single image
# ----------------------------------------------------------------------

# Stage 1: Build Flutter Web & Dart Server
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Cache dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy source code
COPY . .

# 1. Compile Flutter Web release
RUN flutter build web --release

# 2. Compile native Dart Lobby & Tournament server
RUN dart compile exe bin/lobby_server.dart -o bin/server

# Stage 2: Minimal Runtime Image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/bin/server /app/server
COPY --from=build /app/build/web /app/build/web
RUN mkdir -p /app/bin/data

ENV PORT=8088
EXPOSE 8088

CMD ["/app/server"]
