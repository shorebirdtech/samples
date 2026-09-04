# 🐤 Shorebird Patch Rush

**A fast-paced 3D arcade runner and live multiplayer booth battle for events.**

> Dodge store reviews and production bugs. Collect Shorebird patches (🐤). Upgrade your plan and race live with booth attendees!

---

## 🎮 Game Concept & Shorebird Lore

You pilot **Shorebird (🐤)** through high-velocity production tunnels. Deploy instant Over-The-Air (OTA) patches to bypass app review queues and fix production bugs before users notice.

| Element | In-Game Symbol | Real-World Shorebird Concept |
|---|---|---|
| **Player Hero** | 🐤 Shorebird Chick | Your Flutter app deploying instant OTA updates |
| **Collectible** | 🐤 Shorebird Patch | OTA patch update (+25 pts) |
| **Obstacle 1** | 🍏 App Store Logo | App Store review delays |
| **Obstacle 2** | ▶️ Google Play Logo | Play Store review delays |
| **Obstacle 3** | 🐛 Caterpillar Worm | Production crash bug |
| **Missed Patch** | ⚠️ -15 pts penalty | Unpatched bug reaching users & streak reset |

### 📈 Shorebird Plan Tiers & Level Progression
As you collect patches, your deployment infrastructure upgrades through Shorebird's official plans:
1. **🐣 HOBBY** — `5,000 Patches / month`
2. **⚡ PRO** — `50K Patches / month`
3. **💼 BUSINESS** — `1,000,000 Patches / month`
4. **👑 ENTERPRISE** — `Custom Patches` (Endless Hyperdrive)

---

## 🕹️ Controls

| Input | Action |
|---|---|
| `←` / `A` | Steer Left |
| `→` / `D` | Steer Right |
| **Tap Left Half** | Steer Left (Touch / Trackpad) |
| **Tap Right Half** | Steer Right (Touch / Trackpad) |

> *Tip: Pure lane dodging — jump mechanics have been removed to ensure fast arcade reflexes.*

---

## 🌐 How to Run: Server & Client Setup

Patch Rush supports **Solo Campaign** as well as **Live Multiplayer Lobby Races** across multiple devices.

```
┌─────────────────────────────────┐
│     Lobby Server (Dart)         │
│     ws://0.0.0.0:8088           │
│     Embedded JSON Database      │
└──────────────┬──────────────────┘
               │ WebSockets
       ┌───────┴───────┐
       ▼               ▼
┌──────────────┐ ┌──────────────┐
│ Player 1     │ │ Player 2..N  │
│ Host Phone   │ │ Attendee Mac │
└──────────────┘ └──────────────┘
```

---

### Step 1: Start the Multiplayer Lobby Server

The multiplayer server is a native Dart process with an embedded JSON tournament database at `bin/data/db.json`.

From the `shorebird_runner` root directory:

```bash
# Using Dart SDK directly:
dart bin/lobby_server.dart

# Or specify a custom port:
PORT=8088 dart bin/lobby_server.dart
```

When started, you will see:
```
====================================================
🚀 SHOREBIRD PATCH RUSH LOBBY SERVER RUNNING
📡 Listening on http://0.0.0.0:8088 (WebSocket: ws://0.0.0.0:8088)
💾 Database file: bin/data/db.json
====================================================
```

#### Server Endpoints:
* **WebSocket**: `ws://<host-ip>:8088` (Handles room creation, live standings sync, countdowns, and race finishes)
* **REST API**:
  * `GET http://<host-ip>:8088/api/health` — Server health check
  * `GET http://<host-ip>:8088/api/leaderboard` — All-time Hall of Fame leaderboard
  * `GET http://<host-ip>:8088/api/matches` — Recent tournament match results

---

### Step 2: Start the Client Web App

Open a second terminal window in `shorebird_runner`.

#### Option A: Local Chrome Development
```bash
flutter run -d chrome
```

#### Option B: Booth Kiosk / Multi-Device LAN (Attendees joining on phones/laptops)
To let attendees on the same Wi-Fi or hotspot join from their own mobile phones or laptops:

```bash
flutter run -d web-server --web-port 52785 --web-hostname 0.0.0.0
```

1. Find your machine's LAN IP address:
   * **macOS / Linux**: `ipconfig getifaddr en0` or `hostname -I`
   * **Windows**: `ipconfig`
2. Open the URL on client devices:
   ```
   http://<YOUR-LAN-IP>:52785/
   ```
3. The Flutter web client **automatically connects** to the lobby server at `ws://<YOUR-LAN-IP>:8088`!

---

#### Option C: Hosting on Netlify (Production Web Deployment)

Netlify is an ideal platform for hosting the Flutter web frontend with fast global CDN delivery, HTTPS, and custom domains.

> **Important Architecture Note:** Netlify is a static CDN hosting platform and does not run persistent TCP background processes. The **client web app** runs on Netlify, while the **multiplayer lobby server** runs on a cloud container (Render, Railway, Fly.io) or your booth laptop.

##### 1. Build the Web App for Netlify
```bash
# Standard release build:
flutter build web --release

# OR build with your cloud WebSocket server pre-configured:
flutter build web --release --dart-define=LOBBY_SERVER_URL=wss://your-lobby-server.com
```

##### 2. Deploy to Netlify
A [`netlify.toml`](file:///Users/abhishekdoshi/Documents/shorebirdtech/samples/shorebird_runner/netlify.toml) file is already provided in the project root with the correct publish directory (`build/web`) and SPA rewrite rules.

* **Via Netlify CLI**:
  ```bash
  npm install -g netlify-cli
  netlify deploy --prod --dir=build/web
  ```
* **Via Netlify Web UI (Drag & Drop or Git)**:
  * Connect your GitHub repository to Netlify.
  * **Build command**: `flutter build web --release`
  * **Publish directory**: `build/web`

##### 3. How the Netlify Web App Connects to the Lobby Server
The client supports three convenient ways to connect to the backend:

1. **Build-Time Config**: Add `--dart-define=LOBBY_SERVER_URL=wss://your-lobby-server.com` during `flutter build web`.
2. **Query Parameter (No rebuild needed!)**: Share a link with `?server=`:
   ```
   https://your-game.netlify.app/?server=wss://your-lobby-server.com
   ```
   *Tip: At a booth with a local Wi-Fi router, you can even point attendees to your laptop's IP:*
   `https://your-game.netlify.app/?server=ws://192.168.1.50:8088`
3. **In-Game Settings**: Tap the ⚙️ settings icon beside `DISCONNECTED` in the Multiplayer Lobby to type the server address and connect immediately.

##### 4. Deploying the Lobby Server to the Cloud (Render / Railway / Fly.io)
A production-ready [`Dockerfile`](file:///Users/abhishekdoshi/Documents/shorebirdtech/samples/shorebird_runner/Dockerfile) is included in the project:
* **Railway**: Create a new project ➔ "Deploy from GitHub Repo" ➔ Railway will automatically detect the `Dockerfile`, expose port `8088`, and assign a public `wss://...` URL.
* **Render**: Create "New Web Service" ➔ select repo ➔ Docker runtime ➔ Port `8088`.
* **Fly.io**: Run `fly launch` in the project directory.

---

## 🏁 How to Play in Multiplayer Lobby Mode

1. **Enter the Lobby**:
   * On the home screen, tap **MULTIPLAYER LOBBY**.
2. **Select Chassis & Callsign**:
   * Enter your name / callsign (e.g. `Maverick`, `DevPilot`).
   * Choose your ship skin:
     * `Blue Jet 🐤`
     * `Cyber Gold ⚡`
     * `Crimson Ace 🔴`
     * `Shadow Stealth 🟣`
3. **Create or Join a Room (Multi-Device Flow)**:
   * **Host a Room**: Tap **CREATE NEW ROOM**. The screen will display:
     * A large 4-letter room code (e.g. `FLUT`).
     * A **live QR Code**: Attendees at the booth simply point their iPhone or Android camera at the host's screen to open the game and auto-join!
     * A **"Copy Invite Link"** button to share via Slack, Discord, or group chat.
   * **Attendees Joining on Phones / Laptops**:
     * **Method A (Scan QR)**: Point camera at host's screen ➔ taps link ➔ opens lobby with room code pre-filled!
     * **Method B (Direct Code)**: Tap **MULTIPLAYER LOBBY** on their device ➔ enter the 4-letter code ➔ tap **JOIN ROOM**.
4. **Launch Race**:
   * Once attendees appear in the **CONNECTED PILOTS** list, the host taps **LAUNCH RACE**.
   * A synchronized 3-2-1 countdown begins simultaneously across all devices.
5. **Live Standings & Tournament Podium**:
   * During the race, a live mini-HUD shows real-time rank changes and crash status across all devices.
   * When the race concludes, all devices transition to the **Tournament Podium** showing 🥇 1st, 🥈 2nd, and 🥉 3rd place pedestals with match stats persisted to the database!

---

## 🗂️ Project Architecture

```
shorebird_runner/
├── bin/
│   ├── lobby_server.dart              # Native Dart WebSocket server & REST API
│   └── data/
│       └── db.json                    # Persistent tournament database
├── lib/
│   ├── main.dart                      # App entry point & responsive Game Over dialog
│   ├── game/
│   │   ├── shorebird_runner_game.dart # FlameGame loop, obstacle spawning, scoring
│   │   ├── components/
│   │   │   ├── player.dart            # Player ship with 4 custom skins & motion trails
│   │   │   ├── patch.dart             # Shorebird Patch (🐤) with 3D rotation & glow
│   │   │   ├── obstacle.dart          # App Store, Google Play, and 🐛 caterpillar bugs
│   │   │   ├── hud.dart               # Live score, combo streaks, plan tier & quota
│   │   │   └── lane_world.dart        # 3D perspective road & horizon vanishing point
│   │   └── utils/
│   │       └── game_config.dart       # Tuning, Shorebird plans, penalty rules
│   ├── screens/
│   │   ├── start_screen.dart          # Home menu with Shorebird Plans roadmap
│   │   ├── lobby_screen.dart          # Callsign, skin selector, 4-letter room codes
│   │   ├── multiplayer_race_screen.dart # Live racing screen with rankings mini-HUD
│   │   └── tournament_podium_screen.dart # Pedestal podium (1st, 2nd, 3rd) & stats
│   └── services/
│       ├── lobby_service.dart         # WebSocket client networking & state management
│       └── audio_service.dart         # Sound effects & synthesized audio
```

---

## ⚡ Shorebird OTA Patches

This project is built to showcase Shorebird Code Push. You can patch game balance, speeds, new obstacles, or themes instantly on deployed devices without app store reviews:

```bash
# 1. Initialize Shorebird
shorebird init

# 2. Deploy instant OTA patch
shorebird patch android
```
