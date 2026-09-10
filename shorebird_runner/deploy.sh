#!/usr/bin/env bash
# ==============================================================================
# 🐤 Shorebird Patch Rush — Netlify Build & Deployment Script
# 
# Builds Flutter Web release and deploys directly to Netlify.
# 
# Usage:
#   ./deploy.sh                  # Interactive build & deploy to Netlify
#   ./deploy.sh --netlify        # Build & Deploy directly to Netlify
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
echo "  ║        🐤  SHOREBIRD PATCH RUSH — NETLIFY DEPLOY  🚀       ║"
echo "  ║             Solo Runner Web Build & Deployment            ║"
echo "  ╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Find Flutter executable
FLUTTER_CMD="flutter"
if ! command -v flutter &> /dev/null; then
  if [ -x "/Users/abhishekdoshi/.shorebird/bin/cache/flutter/309dd6573a9fe716410489284cd325a34b950375/bin/flutter" ]; then
    FLUTTER_CMD="/Users/abhishekdoshi/.shorebird/bin/cache/flutter/309dd6573a9fe716410489284cd325a34b950375/bin/flutter"
  elif [ -x "$HOME/.shorebird/bin/cache/flutter/309dd6573a9fe716410489284cd325a34b950375/bin/flutter" ]; then
    FLUTTER_CMD="$HOME/.shorebird/bin/cache/flutter/309dd6573a9fe716410489284cd325a34b950375/bin/flutter"
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
SUPABASE_URL_ARG=""
SUPABASE_KEY_ARG=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --netlify)
      TARGET_ACTION="netlify"
      shift
      ;;
    --supabase-url)
      SUPABASE_URL_ARG="$2"
      shift 2
      ;;
    --supabase-key)
      SUPABASE_KEY_ARG="$2"
      shift 2
      ;;
    --build-only)
      TARGET_ACTION="build-only"
      shift
      ;;
    --help|-h)
      echo "Usage: ./deploy.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --netlify                Build and deploy web release directly to Netlify"
      echo "  --supabase-url <URL>     Embed Supabase URL via --dart-define"
      echo "  --supabase-key <KEY>     Embed Supabase Anon Key via --dart-define"
      echo "  --build-only             Compile Flutter web release without deploying"
      echo "  -h, --help               Show this help message"
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
  echo -e "${BOLD}Select an Action:${NC}"
  echo -e "  ${GOLD}1)${NC} ${BOLD}Deploy to Netlify${NC} (Build & deploy web client to Netlify CDN)"
  echo -e "  ${GOLD}2)${NC} ${BOLD}Build Web Release Only${NC} (Compile to build/web)"
  echo ""
  read -p "Enter choice [1-2] (default 1): " CHOICE
  case $CHOICE in
    2) TARGET_ACTION="build-only" ;;
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
  if [ -n "$SUPABASE_URL_ARG" ]; then
    echo -e "${CYAN}→ Embedding Supabase URL:${NC} $SUPABASE_URL_ARG"
    BUILD_ARGS+=("--dart-define=SUPABASE_URL=$SUPABASE_URL_ARG")
  fi
  if [ -n "$SUPABASE_KEY_ARG" ]; then
    echo -e "${CYAN}→ Embedding Supabase Anon Key${NC}"
    BUILD_ARGS+=("--dart-define=SUPABASE_ANON_KEY=$SUPABASE_KEY_ARG")
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

  build-only)
    build_flutter_web
    echo ""
    echo -e "${GREEN}✓ Build complete! Folder '${BOLD}build/web${NC}' is ready for Netlify hosting.${NC}"
    ;;
esac

echo ""
