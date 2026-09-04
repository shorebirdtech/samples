# 🐦 Patch Rush

**A fast-paced 3D endless runner for the Shorebird booth.**

> Dodge bugs. Collect patches. Keep flying.

---

## 🎮 Game Concept

You are a Shorebird app flying through a 3D tunnel. OTA patches (🩹) are incoming — collect them for points. Bugs (🐛) are lurking in your lanes — hit one and you crash. How long can you keep flying?

| Element | In-game | Real world |
|---|---|---|
| 🐦 Bird | Your Flutter app | The app on users' devices |
| 🩹 Patch | Collectible | Shorebird OTA code push |
| 🐛 Bug | Obstacle | Production crash |
| 💥 Crash | Game over | App crash |

---

## 🕹️ Controls

| Input | Action |
|---|---|
| `←` / `A` | Move left |
| `→` / `D` | Move right |
| **Tap left half** | Move left (touch / trackpad) |
| **Tap right half** | Move right (touch / trackpad) |

---

## 🏆 Scoring

| Event | Points |
|---|---|
| Survive 1 second | +1 pt |
| Collect a patch | +10 pts |
| 5-patch combo streak | +25 bonus pts |

High scores persist in the browser's `localStorage` — survives page refreshes!

---

## 🚀 Running at the Booth

### Development (with hot-reload)
```bash
cd shorebird_runner
flutter run -d chrome
```

### Production build (for hosting on a screen/kiosk)
```bash
flutter build web
# Serve the build/web/ directory from any static host
```

### Quick local serve of the production build
```bash
cd build/web && python3 -m http.server 8080
# Open: http://localhost:8080
```

---

## 🛠️ Tech Stack

| Concern | Choice |
|---|---|
| Game engine | [Flame 1.38.2](https://flame-engine.org/) |
| Platform | Flutter Web |
| Persistence | `shared_preferences` (→ `localStorage` on web) |
| "3D" effect | Pseudo-3D perspective projection via canvas transforms |

---

## 🗂️ Project Structure

```
lib/
├── main.dart                          # App shell + game-over overlay
├── game/
│   ├── shorebird_runner_game.dart     # FlameGame: loop, spawning, scoring
│   ├── components/
│   │   ├── player.dart                # Bird with lane switching + motion trail
│   │   ├── obstacle.dart              # Spiky bug with depth scaling
│   │   ├── patch.dart                 # Bandage collectible + sparkle burst
│   │   ├── lane_world.dart            # 3D perspective road + scrolling grid
│   │   ├── starfield.dart             # Twinkling parallax stars
│   │   └── hud.dart                   # Score / combo / speed overlay
│   └── utils/
│       ├── game_config.dart            # All tuning constants & speed curves
│       └── high_score_service.dart    # localStorage high score
└── screens/
    └── start_screen.dart              # Animated start screen
```

---

## ⚡ Shorebird Integration

This project is Shorebird-ready. To enable OTA patch updates for booth demos (push balance tweaks, new obstacles, etc. without app store review):

```bash
# 1. Install Shorebird CLI
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/shorebird/main/install.sh -sSf | bash

# 2. Login and initialize
shorebird login
shorebird init

# 3. Push a patch (zero-downtime, no store review!)
shorebird patch web
```

---

## 🎨 Design

- **Color palette:** Deep space `#0A0E1A` · Electric cyan `#00D4FF` · Coral `#FF5D73` · Amber `#FFB347` · Purple `#8B5CF6`
- **Animations:** Floating bird logo, pulsing play button, twinkling stars, scrolling 3D perspective grid, player motion trail, sparkle burst on patch collection, crash flash effect
