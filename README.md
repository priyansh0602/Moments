# Moments

> Capture, organize, and play exact song sections from YouTube without downloads or audio extraction.

**Moments** is a modern music companion mobile and web app. Users can search for any song via YouTube, select an exact start and end timestamp snippet (a "Moment"), organize Moments into thematic groups, play them back sequentially, and share them across platforms with dynamic deep links.

---

## Key Principles

- **Timestamp References Only**: A Moment is purely a metadata pointer `(videoId, start, end)`. Moments does not extract audio or download media. All playback is rendered in visible YouTube IFrame players in strict compliance with YouTube's Terms of Service.
- **Client Security**: The YouTube Data API v3 key never ships in client builds. All search queries are proxied securely through a Supabase Edge Function.

---

## Monorepo Layout

```
moments/
├── app/                      # Flutter mobile app (Android & iOS)
│   ├── lib/
│   │   ├── main.dart         # Entry point & guarded Supabase initialization
│   │   ├── app.dart          # MaterialApp.router, Riverpod, Material 3 theme
│   │   ├── core/             # Cross-cutting configs, router, theme, utilities
│   │   ├── features/         # Feature modules (auth, search, player, moments, etc.)
│   │   │   └── <feature>/    # Clean Architecture: data/, domain/, presentation/
│   │   └── shared/           # Models and services shared across features
│   ├── assets/               # Images, fonts, and icon assets
│   ├── test/                 # Smoke tests and unit/widget test suites
│   ├── .env.example          # Template for Flutter environment variables
│   └── pubspec.yaml          # Flutter dependencies and asset registrations
├── web/                      # Next.js 16 (App Router) share platform & landing
│   ├── src/
│   │   └── app/
│   │       ├── page.tsx      # "Moments: coming soon" landing page
│   │       ├── m/[id]/       # Dynamic preview route for shared Moments
│   │       └── g/[id]/       # Dynamic preview route for shared Groups
│   └── .env.example          # Template for Next.js public environment variables
├── supabase/                 # Supabase configuration and serverless functions
│   ├── migrations/           # PostgreSQL migrations with RLS (Phase 2+)
│   ├── functions/            # Edge Functions (YouTube proxy, etc.) (Phase 4+)
│   ├── seed.sql              # Development database seed script
│   └── config.toml           # Supabase CLI local environment config
├── docs/                     # Architectural diagrams and phase roadmap
│   ├── ARCHITECTURE.md       # High-level architecture and data flows
│   └── PHASES.md             # Project roadmap and milestone tracking
├── .editorconfig             # Universal code styling (2 spaces, LF, UTF-8)
├── .gitignore                # Global git ignore configuration
└── README.md                 # Project guide & contributor documentation
```

---

## Prerequisites

Before running the project locally, ensure you have the following installed:

- **Git** (v2.30+)
- **Flutter SDK** (v3.24+ or 3.41+) with Dart 3.5+
- **Node.js** (v20.x or v24.x LTS) & **npm** (v10.x+)
- **Supabase CLI** (v1.140+)
- Android Studio / Xcode for mobile emulation

---

## Environment Setup

### 1. Flutter Mobile App (`app/`)

Copy the environment example file:
```bash
cp app/.env.example app/.env
```

Edit `app/.env` with your Supabase credentials:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```
*(Note: If placeholders are present, the app gracefully boots into demo/mock mode.)*

### 2. Next.js Web App (`web/`)

Copy the environment example file:
```bash
cp web/.env.example web/.env.local
```

Edit `web/.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

---

## Running Locally

### Mobile App (`app/`)

```bash
cd app

# Install dependencies
flutter pub get

# Run code generator (if models or providers are updated)
dart run build_runner build

# Run static analysis
flutter analyze

# Run tests
flutter test

# Launch mobile application
flutter run
```

### Web App (`web/`)

```bash
cd web

# Install dependencies
npm install

# Start development server
npm run dev

# Build production bundle
npm run build
```
Visit `http://localhost:3000` to view the landing page, `http://localhost:3000/m/sample-id` for Moment preview, or `http://localhost:3000/g/sample-id` for Group preview.

### Supabase Local Stack (`supabase/`)

```bash
cd supabase

# Start local Supabase Docker containers
supabase start

# Check local container status
supabase status
```

---

## Development Conventions

### Commit Style: Conventional Commits
All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:
```
<type>(<scope>): <short summary>

[optional body]
```
Common types:
- `feat`: A new user-facing feature
- `fix`: A bug fix
- `chore`: Maintenance, dependencies, scaffolding
- `docs`: Documentation updates
- `refactor`: Code refactoring without behavioral changes
- `test`: Adding or updating test cases
- `style`: Formatting, missing semi-colons, no code changes

*Examples:*
- `chore: phase 0 foundation`
- `feat(player): add timestamp scrubber controls`
- `fix(search): debounce youtube query requests`

### Branch Naming
Branch names should be kebab-case, prefixed by type or phase:
- `feature/<feature-name>` (e.g., `feature/song-player`, `feature/moment-creator`)
- `fix/<issue-name>` (e.g., `fix/ios-deep-linking`)
- `chore/<task-name>` (e.g., `chore/phase-0-scaffold`)
- `phase/<phase-number>-<name>` (e.g., `phase/1-app-shell`)
