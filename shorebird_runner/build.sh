#!/usr/bin/env bash
# ==============================================================================
# Shorebird Runner — Web Release Build Script
# Builds Flutter Web release for GitHub Pages and web distribution.
# ==============================================================================
set -e

echo "→ Checking Flutter environment..."

if ! command -v flutter &> /dev/null; then
  if [ -x "$HOME/.shorebird/bin/cache/flutter/309dd6573a9fe716410489284cd325a34b950375/bin/flutter" ]; then
    export PATH="$HOME/.shorebird/bin/cache/flutter/309dd6573a9fe716410489284cd325a34b950375/bin:$PATH"
  elif [ -x "$HOME/flutter/bin/flutter" ]; then
    export PATH="$HOME/flutter/bin:$PATH"
  else
    echo "→ Flutter not found in PATH. Fetching Flutter stable SDK..."
    if [ ! -d "$HOME/flutter" ]; then
      git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
    fi
    export PATH="$HOME/flutter/bin:$PATH"
  fi
fi

echo "→ Using Flutter version:"
flutter --version

BASE_HREF="${BASE_HREF:-/}"

echo "→ Building Flutter Web release with base-href: $BASE_HREF ..."
flutter build web --release \
  --base-href "$BASE_HREF" \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"

# Sync icons & favicon to build/web
cp -r web/icons build/web/ 2>/dev/null || true
cp web/favicon.png web/favicon.svg build/web/ 2>/dev/null || true

echo "✓ Flutter Web build complete in build/web"
