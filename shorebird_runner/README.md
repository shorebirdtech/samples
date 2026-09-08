# 🐤 Shorebird Patch Rush

**A fast-paced AAA 3D arcade runner and live multiplayer booth battle for events.**

> Dodge store reviews and production bugs. Collect Shorebird patches (🐤). Upgrade your plan and race live with booth attendees!

---

## 🎮 Game Concept & Shorebird Lore

You sprint as a **Mobile Developer** through the neon-lit production highway against a GTA 5 Los Santos night skyline. Deploy instant Over-The-Air (OTA) patches to bypass app review queues, leap over bug barricades, and slide under code review gates.

| Element | In-Game Symbol | Real-World Shorebird Concept |
|---|---|---|
| **Player Hero** | 👨‍💻 Developer | Mobile engineer deploying instant OTA updates |
| **Collectible** | 🐤 Shorebird Patch | Instant OTA patch update (+25 pts) |
| **Power-Up** | ⚡ Hot Reload Core | 6s invincibility shield, speed boost, magnet & obstacle smashing (+500 pts) |
| **Obstacle 1** | 🍏 App Store Logo | Monolithic App Store review delays (dodge sideways) |
| **Obstacle 2** | ▶️ Google Play Logo | Monolithic Play Store review delays (dodge sideways) |
| **Obstacle 3** | 🐛 Caterpillar Worm | Production crash bugs (low — jump over or dodge) |
| **Obstacle 4** | 🚧 Merge Barricade | Warning construction barricade (low — jump over or dodge) |
| **Obstacle 5** | 🚨 App Review Laser Gate | Overhead review barrier (high — slide underneath or dodge) |
| **Missed Patch** | ⚠️ -15 pts penalty | Unpatched bug reaching users & streak reset |

### 📈 Shorebird Plan Tiers & Level Progression
As you collect patches, your deployment infrastructure upgrades through Shorebird's official plans:
1. **🐣 HOBBY** — `5,000 Patches / month`
2. **⚡ PRO** — `50K Patches / month`
3. **💼 BUSINESS** — `1,000,000 Patches / month`
4. **👑 ENTERPRISE** — `Custom Patches` (Endless Hyperdrive)

---

## 🕹️ Controls

### Desktop
| Key | Action |
|---|---|
| `←` / `A` | Steer Left Lane |
| `→` / `D` | Steer Right Lane |
| `↑` / `W` / `Space` | **Jump** (Leap over low barricades & bugs) |
| `↓` / `S` | **Slide** (Crouch under review gates) |

### Mobile / Touch
| Input | Action |
|---|---|
| **Tap Left Third** | Move to Left Lane |
| **Tap Center Third** | Move to Center Lane |
| **Tap Right Third** | Move to Right Lane |
| Touch control bar buttons | Jump / Slide / Lane buttons |

> *Tip: Weaving past obstacles at the last millisecond triggers **`NEAR MISS! +250 PTS`**!*

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

## 🏁 How to Play in Multiplayer Lobby Mode

1. **Enter the Lobby**:
   * On the home screen, tap **MULTIPLAYER LOBBY**.
2. **Select Developer Handle & Persona**:
   * Enter your handle (e.g. `SkyWalker`, `CodeNinja`).
   * Choose your developer persona:
     * `Shorebird Dev 👨‍💻` (Cyan hoodie with Shorebird bird emblem)
     * `Frontend Ninja 🧑‍💻` (Amber hoodie with code brackets)
     * `Fullstack Hero ⚡` (Emerald hoodie with code brackets)
     * `Bug Hunter 👾` (Purple hoodie with code brackets)
3. **Create or Join a Room (Multi-Device Flow)**:
   * **Host as Spectator (Conference Booth TV Display)**:
     * Tap **HOST AS SPECTATOR (BOOTH DISPLAY)**.
     * Creates a room with **0 racers**.
     * The host screen acts as a big-screen esports leaderboard.
     * Displays a large 4-letter room code (e.g. `BIRD`) and a **live QR Code**.
     * Booth attendees point their phone camera at the host's screen to open the game and auto-join instantly!
   * **Host & Race on This Device**:
     * Tap **HOST & RACE ON THIS DEVICE** to create the room and join immediately as Racer #1.
   * **Attendees Joining on Phones / Laptops**:
     * **Scan QR**: Point camera at host's screen ➔ tap link ➔ auto-joins room!
     * **Direct Code**: Tap **MULTIPLAYER LOBBY** on their device ➔ enter the 4-letter code ➔ tap **JOIN**.
4. **Launch Race**:
   * Once attendees appear in the **CONNECTED DEVELOPERS** list, the host taps **LAUNCH RACE**.
   * A synchronized 3-2-1 countdown begins simultaneously across all devices.
5. **Rematch**:
   * After the race, the **Tournament Podium** is shown.
   * Only the **room owner (host)** can trigger a rematch via the **REMATCH RACE** button.
   * Non-host players see a waiting state and can **LEAVE ROOM** if they don't wish to continue.
6. **Live Standings & Tournament Podium**:
   * During the race, live telemetry updates rank changes, scores, and crash status in real-time.
   * When the race concludes, all devices transition to the **Tournament Podium** showing 🥇 1st, 2nd, and 3rd place pedestals with match stats persisted to the database!

---

## 🚀 Deploying Web Client to Netlify

The game is pre-configured with `netlify.toml` for instant continuous deployment:

1. **Netlify Build Settings**:
   * **Build command**: `flutter build web --release`
   * **Publish directory**: `build/web`
2. **Headers & SPA Routing**:
   * `netlify.toml` includes automatic SPA redirect rules (`/*` -> `/index.html 200`) and security headers.
3. **Connecting Web Clients to Live Lobby Server**:
   * In the lobby screen, click the **⚙️ Server Config** icon next to "SERVER CONNECTED".
   * Enter your deployed WebSocket server URL (e.g. `wss://your-lobby-server.onrender.com` or `ws://192.168.1.50:8088`).
   * Share the invite link — any attendee opening the link will auto-connect to your server!

---

## 🗂️ Project Architecture

The project follows a **feature-first architecture** with BLoC pattern, SOLID principles, and barrel exports:

```
shorebird_runner/
├── bin/
│   ├── lobby_server.dart              # Native Dart WebSocket server & REST API
│   └── data/
│       └── db.json                    # Persistent tournament database
├── lib/
│   ├── main.dart                      # App entry point & dependency injection
│   ├── core/                          # Shared utilities & constants
│   │   ├── audio/                     # AudioService
│   │   ├── constants/                 # AppColors, AppStrings, GameConfig
│   │   ├── storage/                   # IHighScoreRepository, HighScoreRepository
│   │   └── theme/                     # AppTheme
│   ├── game/                          # Flame game engine layer
│   │   ├── shorebird_runner_game.dart # FlameGame loop, obstacle spawning, scoring
│   │   └── components/
│   │       ├── player.dart            # Player with 4 custom skins & motion trails
│   │       ├── patch.dart             # Shorebird Patch (🐤) with 3D rotation & glow
│   │       ├── obstacle.dart          # App Store, Google Play, and 🐛 caterpillar bugs
│   │       ├── hud.dart               # Live score, combo streaks, plan tier & quota
│   │       └── lane_world.dart        # 3D perspective road & horizon vanishing point
│   └── features/
│       ├── app_shell/                 # Root navigator & application mode state
│       │   ├── bloc/                  # AppShellBloc, AppMode, AppShellEvent/State
│       │   └── screens/               # AppShellScreen (routes between features)
│       ├── start_menu/                # Home screen & game rules
│       │   ├── bloc/                  # StartMenuBloc
│       │   ├── screens/               # StartScreen
│       │   └── widgets/               # ShorebirdLogo, GameRulesDialog, PlanChip, etc.
│       ├── solo_runner/               # Single-player campaign
│       │   ├── bloc/                  # SoloRunnerBloc
│       │   ├── screens/               # SoloRunnerScreen
│       │   └── widgets/               # GameOverOverlay, MobileTouchBar, StatTile, etc.
│       ├── booth_battle/              # Local 2-player split-screen mode
│       │   ├── bloc/                  # BoothBattleBloc
│       │   ├── screens/               # BoothBattleScreen
│       │   └── widgets/               # VsScoreboard, ScoreCard, MatchResultOverlay, etc.
│       ├── tournament_lobby/          # WebSocket multiplayer lobby & room management
│       │   ├── bloc/                  # LobbyBloc, LobbyEvent/State
│       │   ├── data/                  # ILobbyRepository, WebSocketLobbyRepository
│       │   ├── models/                # LobbyPlayer, RacerStanding, RoomStatus
│       │   ├── screens/               # LobbyScreen
│       │   └── widgets/               # RoomCodeCard, PlayerListCard, SetupView, etc.
│       ├── multiplayer_race/          # Live synchronized race screen
│       │   ├── bloc/                  # RaceBloc, RaceEvent/State
│       │   ├── screens/               # MultiplayerRaceScreen
│       │   └── widgets/               # LiveStandingsCard, CrashedSpectatorOverlay
│       └── tournament_podium/         # Post-race results & rematch flow
│           ├── screens/               # TournamentPodiumScreen
│           └── widgets/               # PodiumPedestal, StandingRow
```

### Architectural Principles

- **Feature-First**: All code is co-located by feature, not by type
- **BLoC Pattern**: All state management via `flutter_bloc` with `copyWith` state updates — no `setState`
- **SOLID Principles**:
  - **SRP**: Each file contains a single class/widget
  - **OCP**: Features extended via interfaces (`ILobbyRepository`, `IHighScoreRepository`)
  - **DIP**: Screens depend on repository interfaces, not concrete implementations
- **Barrel Exports**: Each folder has an export file (`*.dart` or `widgets.dart`, `screens.dart`, etc.). Import the barrel, not individual files
- **Constants**: All strings in `AppStrings`, colors in `AppColors`, game values in `GameConfig`

---

## ⚡ Shorebird OTA Patches

This project is built to showcase Shorebird Code Push. You can patch game balance, speeds, new obstacles, or themes instantly on deployed devices without app store reviews:

```bash
# 1. Initialize Shorebird
shorebird init

# 2. Deploy instant OTA patch
shorebird patch android
```
