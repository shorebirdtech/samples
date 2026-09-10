# 🐤 Shorebird Patch Rush

**A fast-paced 3D arcade runner showcasing instant Over-The-Air (OTA) Code Push for Flutter.**

> Dodge monolithic store review delays and production bugs. Collect Shorebird patches (🐤). Level up your deployment infrastructure from Hobby to Unicorn!

---

## 🎮 Game Concept & Shorebird Lore

You sprint as a **Mobile Developer** through the neon-lit production highway against a city night skyline. Deploy instant Over-The-Air (OTA) patches to bypass app review queues, leap over bug barricades, and slide under code review gates.

| Element | In-Game Symbol | Real-World Shorebird Concept |
|---|---|---|
| **Player Hero** | 👨‍💻 Developer | Mobile engineer deploying instant OTA updates |
| **Collectible** | 🐤 Shorebird Patch | Instant OTA patch update (+25 pts) |
| **Power-Up** | ⚡ Hot Reload Core | Invincibility shield, speed boost, magnet & obstacle smashing (+500 pts) |
| **Obstacle 1** | 🍏 App Store Logo | Monolithic App Store review delays (dodge sideways) |
| **Obstacle 2** | ▶️ Google Play Logo | Monolithic Play Store review delays (dodge sideways) |
| **Obstacle 3** | 🐛 Caterpillar Worm | Production crash bugs (low — jump over or dodge) |
| **Obstacle 4** | 🚧 Merge Barricade | Warning construction barricade (low — jump over or dodge) |
| **Obstacle 5** | 🚨 App Review Laser Gate | Overhead review barrier (high — slide underneath or dodge) |
| **Missed Patch** | ⚠️ -15 pts penalty | Unpatched bug reaching users & streak reset |

### 📈 Shorebird Plan Tiers & Progression
As you collect patches, your deployment infrastructure upgrades through Shorebird's plans:
1. **🐣 HOBBY** — `5,000 Patches / month`
2. **⚡ PRO** — `50K Patches / month`
3. **💼 BUSINESS** — `1,000,000 Patches / month`
4. **👑 ENTERPRISE / UNICORN** — `Custom Scale Patches`

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
| Touch control bar | Dedicated Jump / Slide / Lane buttons |

---

## 🚀 Getting Started

### 1. Run Locally (Zero Configuration Fallback)
Because this is an open-source project, you can run the game immediately without setting up any credentials or databases:

```bash
flutter run -d chrome
```

Leads entered in the "Start Patching" modal will automatically save to local storage (`LocalLeadRepository` using `SharedPreferences`).

---

### 2. Configuring Supabase Lead Capture (Optional)
To persist player telemetry and lead submissions to a live Supabase database, pass your project credentials at compile time using `--dart-define`:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-public-key
```

#### Supabase Database Setup
In your Supabase SQL Editor, run this script to create the `leads` table and Row-Level Security (RLS) policy:

```sql
-- Create leads table (with event as the first column)
CREATE TABLE leads (
  event TEXT,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  organization TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);

-- Enable Row Level Security
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

-- Allow anonymous inserts from web/mobile players
CREATE POLICY "Allow public insert to leads"
ON leads
FOR INSERT
TO anon
WITH CHECK (true);
```

> **Security Note:** Secrets are never committed into git. The app uses compile-time environment defines (`SUPABASE_URL` and `SUPABASE_ANON_KEY`) with anonymous insert-only permissions. If credentials are empty or the network drops, it gracefully saves to `LocalLeadRepository`.

---

## 🗂️ Project Architecture

The project follows a **clean, feature-first architecture** with the BLoC pattern:

```
shorebird_runner/
├── lib/
│   ├── main.dart                      # App entry point & dependency injection
│   ├── core/                          # Shared utilities & constants
│   │   ├── audio/                     # AudioService
│   │   ├── constants/                 # AppColors, AppStrings, GameConfig
│   │   ├── storage/                   # HighScoreRepository
│   │   └── theme/                     # AppTheme
│   ├── game/                          # Flame game engine layer
│   │   ├── shorebird_runner_game.dart # FlameGame loop, obstacle spawning, scoring
│   │   └── components/                # Player, Patch, Obstacle, Hud, LaneWorld
│   └── features/
│       ├── app_shell/                 # Navigation & mode routing (menu <-> solo)
│       │   ├── bloc/                  # AppShellBloc, AppMode, AppShellState
│       │   └── screens/               # AppShellScreen
│       ├── start_menu/                # Start screen & game briefing
│       │   ├── bloc/                  # StartMenuBloc
│       │   ├── screens/               # StartScreen (Start Patching CTA)
│       │   └── widgets/               # ShorebirdLogo, GameRulesDialog, StagesRoadmap
│       ├── lead_capture/              # Developer onboarding & Supabase sync
│       │   ├── bloc/                  # LeadCaptureBloc, LeadCaptureState
│       │   ├── data/                  # ILeadRepository, SupabaseLeadRepository, LocalLeadRepository
│       │   ├── models/                # LeadModel
│       │   └── widgets/               # LeadCaptureDialog (obsidian modal)
│       └── solo_runner/               # Solo runner game screen
│           ├── bloc/                  # SoloRunnerBloc
│           ├── screens/               # SoloRunnerScreen (displays player tag in HUD)
│           └── widgets/               # GameOverOverlay, MobileTouchBar
└── test/
    ├── lead_capture_test.dart         # Unit tests for lead model, repo & bloc
    └── widget_test.dart               # App widget test
```

---

## ⚡ Shorebird OTA Patches

To deploy instant Over-The-Air code patches to Android or iOS devices without going through app store review:

```bash
# Initialize Shorebird
shorebird init

# Deploy an instant OTA release / patch
shorebird patch android
shorebird patch ios
```
