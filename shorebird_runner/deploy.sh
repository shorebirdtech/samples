#!/usr/bin/env bash
# ==============================================================================
# 🐤 Shorebird Patch Rush — Web Build Script
# 
# Builds Flutter Web release ready for GitHub Pages or static web hosting.
# 
# Usage:
#   ./deploy.sh                  # Build web release for distribution
#   ./deploy.sh --gh-pages       # Build with GitHub Pages subpath base-href
#   ./deploy.sh --base-href /... # Build with custom base-href
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
echo "  ║      🐤  SHOREBIRD PATCH RUSH — WEB RELEASE BUILD  🚀      ║"
echo "  ║             GitHub Pages & Static Web Hosting             ║"
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
BASE_HREF_VAL="/"
SUPABASE_URL_ARG=""
SUPABASE_KEY_ARG=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --gh-pages)
      BASE_HREF_VAL="/samples/patch-runner/"
      shift
      ;;
    --base-href)
      BASE_HREF_VAL="$2"
      shift 2
      ;;
    --supabase-url)
      SUPABASE_URL_ARG="$2"
      shift 2
      ;;
    --supabase-key)
      SUPABASE_KEY_ARG="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: ./deploy.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --gh-pages               Build for GitHub Pages with base-href /samples/patch-runner/"
      echo "  --base-href <PATH>       Specify custom base-href (default: /)"
      echo "  --supabase-url <URL>     Embed Supabase URL via --dart-define"
      echo "  --supabase-key <KEY>     Embed Supabase Anon Key via --dart-define"
      echo "  -h, --help               Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

echo ""
echo -e "${PURPLE}======================================================${NC}"
echo -e "${BOLD}🔨 Compiling Flutter Web Release (base-href: ${BASE_HREF_VAL})...${NC}"
echo -e "${PURPLE}======================================================${NC}"

BUILD_ARGS=("build" "web" "--release" "--base-href" "$BASE_HREF_VAL")
if [ -n "$SUPABASE_URL_ARG" ]; then
  echo -e "${CYAN}→ Embedding Supabase URL:${NC} $SUPABASE_URL_ARG"
  BUILD_ARGS+=("--dart-define=SUPABASE_URL=$SUPABASE_URL_ARG")
fi
if [ -n "$SUPABASE_KEY_ARG" ]; then
  echo -e "${CYAN}→ Embedding Supabase Anon Key${NC}"
  BUILD_ARGS+=("--dart-define=SUPABASE_ANON_KEY=$SUPABASE_KEY_ARG")
fi

"$FLUTTER_CMD" "${BUILD_ARGS[@]}"

# Ensure updated icons and assets are synchronized
cp web/favicon.png web/favicon.svg web/index.html build/web/
mkdir -p build/web/icons
cp web/icons/* build/web/icons/

echo ""
echo -e "${GREEN}✓ Flutter Web compiled successfully to build/web/${NC}"
echo -e "${GREEN}✓ Ready for deployment to GitHub Pages or static hosting.${NC}"
echo ""
