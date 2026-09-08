#!/usr/bin/env bash
# ==============================================================================
# 🐤 Shorebird Patch Rush — Unified Build & Deployment Script
# 
# Builds Flutter Web release and deploys both Solo Campaign and Tournament Lobby.
# 
# Usage:
#   ./deploy.sh                  # Interactive menu
#   ./deploy.sh --netlify        # Build & Deploy directly to Netlify
#   ./deploy.sh --server <URL>   # Build with custom WebSocket server URL (e.g. wss://...)
#   ./deploy.sh --local          # Build and launch all-in-one local server
#   ./deploy.sh --docker         # Build multi-stage all-in-one Docker image
#   ./deploy.sh --build-only     # Compile build/web release only
# ==============================================================================

set -e

# ANSI Color Codes
CYAN='\033[0;36m'
GOLD='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo -e "${GOLD}${BOLD}"
echo "  ╔═══════════════════════════════════════════════════════════╗"
echo "  ║        🐤  SHOREBIRD PATCH RUSH — DEPLOYMENT CLI  🚀       ║"
echo "  ║      All-in-One Build & Deployment (Solo + Tournament)    ║"
echo "  ╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Find Flutter executable
FLUTTER_CMD="flutter"
if ! command -v flutter &> /dev/null; then
  if [ -x "/Users/abhishekdoshi/Documents/flutter/bin/flutter" ]; then
    FLUTTER_CMD="/Users/abhishekdoshi/Documents/flutter/bin/flutter"
  elif [ -x "$HOME/flutter/bin/flutter" ]; then
    FLUTTER_CMD="$HOME/flutter/bin/flutter"
  else
    echo -e "${RED}Error: Flutter SDK not found in PATH or standard directories.${NC}"
    exit 1
  fi
fi

echo -e "${CYAN}→ Using Flutter SDK:${NC} $($FLUTTER_CMD --version | head -n 1)"

# Parse optional arguments
TARGET_ACTION=""
CUSTOM_SERVER=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --netlify)
      TARGET_ACTION="netlify"
      shift
      ;;
    --server)
      CUSTOM_SERVER="$2"
      shift 2
      ;;
    --local)
      TARGET_ACTION="local"
      shift
      ;;
    --docker)
      TARGET_ACTION="docker"
      shift
      ;;
    --build-only)
      TARGET_ACTION="build-only"
      shift
      ;;
    --help|-h)
      echo "Usage: ./deploy.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --netlify          Build and deploy web release directly to Netlify"
      echo "  --server <URL>     Embed a default WebSocket server URL (e.g. wss://your-lobby.railway.app)"
      echo "  --local            Build and run the all-in-one local server (web + tournament)"
      echo "  --docker           Build multi-stage Docker container (serves web + tournament)"
      echo "  --build-only       Compile Flutter web release without deploying"
      echo "  -h, --help         Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# If no target specified, show interactive prompt
if [ -z "$TARGET_ACTION" ]; then
  echo -e "${BOLD}Select a Deployment Target:${NC}"
  echo -e "  ${GOLD}1)${NC} ${BOLD}Deploy to Netlify${NC} (Instant global CDN for web client)"
  echo -e "  ${GOLD}2)${NC} ${BOLD}Run All-in-One Local/Booth Server${NC} (Hosts web game + WebSocket tournament on port 8088)"
  echo -e "  ${GOLD}3)${NC} ${BOLD}Build All-in-One Docker Image${NC} (Deployable to Railway, Render, Fly.io, or VPS)"
  echo -e "  ${GOLD}4)${NC} ${BOLD}Build Web Release Only${NC} (Compile to build/web)"
  echo ""
  read -p "Enter choice [1-4] (default 1): " CHOICE
  case $CHOICE in
    2) TARGET_ACTION="local" ;;
    3) TARGET_ACTION="docker" ;;
    4) TARGET_ACTION="build-only" ;;
    *) TARGET_ACTION="netlify" ;;
  esac
fi

# Step 1: Build the Flutter Web application
build_flutter_web() {
  echo ""
  echo -e "${PURPLE}======================================================${NC}"
  echo -e "${BOLD}🔨 Compiling Flutter Web Release with 🐤 Branding...${NC}"
  echo -e "${PURPLE}======================================================${NC}"

  BUILD_ARGS=("build" "web" "--release")
  if [ -n "$CUSTOM_SERVER" ]; then
    echo -e "${CYAN}→ Embedding Tournament Server URL:${NC} $CUSTOM_SERVER"
    BUILD_ARGS+=("--dart-define=LOBBY_SERVER_URL=$CUSTOM_SERVER")
  fi

  "$FLUTTER_CMD" "${BUILD_ARGS[@]}"

  # Ensure updated 🐤 icons and assets are synchronized
  cp web/favicon.png web/favicon.svg web/index.html build/web/
  mkdir -p build/web/icons
  cp web/icons/* build/web/icons/

  echo -e "${GREEN}✓ Flutter Web compiled successfully to build/web/${NC}"
}

# Execute selected action
case $TARGET_ACTION in
  netlify)
    build_flutter_web

    echo ""
    echo -e "${PURPLE}======================================================${NC}"
    echo -e "${BOLD}🚀 Deploying to Netlify...${NC}"
    echo -e "${PURPLE}======================================================${NC}"

    if command -v netlify &> /dev/null; then
      echo -e "${CYAN}Running installed Netlify CLI...${NC}"
      netlify deploy --prod --dir=build/web
    elif command -v npx &> /dev/null; then
      echo -e "${CYAN}Running Netlify CLI via npx...${NC}"
      npx netlify-cli deploy --prod --dir=build/web
    else
      echo -e "${GOLD}Netlify CLI not found.${NC}"
      echo -e "You can deploy manually by dragging ${BOLD}build/web/${NC} into: https://app.netlify.com/drop"
    fi
    ;;

  local)
    build_flutter_web

    echo ""
    echo -e "${PURPLE}======================================================${NC}"
    echo -e "${BOLD}📡 Launching All-in-One Local Game & Tournament Server...${NC}"
    echo -e "${PURPLE}======================================================${NC}"
    echo -e "${GREEN}✓ Web Game URL:${NC}        http://localhost:8088"
    echo -e "${GREEN}✓ WebSocket Lobby:${NC}     ws://localhost:8088"
    echo -e "${GREEN}✓ REST API Endpoint:${NC}   http://localhost:8088/api/health"
    echo -e "${GOLD}→ Press Ctrl+C to stop the server.${NC}"
    echo ""

    dart run bin/lobby_server.dart
    ;;

  docker)
    build_flutter_web

    echo ""
    echo -e "${PURPLE}======================================================${NC}"
    echo -e "${BOLD}🐳 Building All-in-One Docker Image...${NC}"
    echo -e "${PURPLE}======================================================${NC}"

    docker build -t shorebird-patch-rush:latest .

    echo -e "${GREEN}✓ Docker image 'shorebird-patch-rush:latest' built!${NC}"
    echo ""
    echo -e "${BOLD}How to run or deploy this container:${NC}"
    echo -e "  • Local test:   ${CYAN}docker run -p 8088:8088 shorebird-patch-rush:latest${NC}"
    echo -e "  • Deploy:       Push this image to Docker Hub, Railway, Render, or Fly.io."
    echo -e "                  A single instance serves BOTH the Web Client & Tournament WebSockets!"
    ;;

  build-only)
    build_flutter_web
    echo ""
    echo -e "${GREEN}✓ Build complete! Folder '${BOLD}build/web${NC}' is ready for hosting anywhere.${NC}"
    ;;
esac

echo ""
echo -e "${GOLD}${BOLD}✨ Done! Thank you for flying with Shorebird 🐤✨${NC}"
