#!/usr/bin/env bash
# ==============================================================================
# Netlify Flutter Web Build Script
# Automatically ensures Flutter SDK is available on Netlify build containers
# ==============================================================================
set -e

echo "→ Checking Flutter environment..."

if ! command -v flutter &> /dev/null; then
  echo "→ Flutter not found in PATH. Fetching Flutter stable SDK..."
  if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
  fi
  export PATH="$HOME/flutter/bin:$PATH"
fi

echo "→ Using Flutter version:"
flutter --version

echo "→ Building Flutter Web release..."
flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"

# Sync icons & favicon to build/web
cp -r web/icons build/web/ 2>/dev/null || true
cp web/favicon.png web/favicon.svg build/web/ 2>/dev/null || true

echo "✓ Flutter Web build complete in build/web"
