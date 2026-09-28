# Moments Project Roadmap & Phases

- [x] **Phase 0: Foundation & Scaffolding**
  - Monorepo folder setup (`app/`, `web/`, `supabase/`, `docs/`)
  - Flutter app creation with Riverpod, go_router, Supabase Flutter, environment setup
  - Analysis options with custom linting and build_runner verification
  - Next.js 16 Web app initialization with App Router, TypeScript, and placeholder dynamic routes
  - Supabase local structure, CLI config, and migration guidelines
  - Architectural documentation and contributor guidelines

- [ ] **Phase 1: App Shell & Design System**
  - Theme definitions (Light / Dark mode Material 3 palette, typography, shapes)
  - Scaffold, bottom navigation bar, responsive layout shell
  - Reusable core UI components and design tokens

- [ ] **Phase 2: Database & Row Level Security (RLS)**
  - PostgreSQL tables: `profiles`, `moments`, `groups`, `group_moments`, `sessions`
  - RLS policies ensuring secure multi-tenant access control
  - Indexes and automated triggers (e.g. `updated_at`, profile creation on signup)
  - Supabase seed data for local development

- [ ] **Phase 3: Auth & Profiles**
  - Supabase Auth integration (email/password, OAuth providers)
  - Auth state management via Riverpod
  - Profile setup and edit flows

- [ ] **Phase 4: Song Search**
  - Supabase Edge Function `youtube-search` with server-side YouTube Data API v3 integration
  - Flutter search presentation, debounce, recent search caching
  - Video selection and metadata extraction

- [ ] **Phase 5: Song Player**
  - Visible YouTube IFrame player integration
  - Interactive playback controls, scrubber, and playback state tracking

- [ ] **Phase 6: Moment Creator**
  - Dual-handle waveform / timeline range selector for start and end timestamp trimming
  - Millisecond precision controls, loop preview of selected range
  - Moment metadata input (title, notes, tags)

- [ ] **Phase 7: Save & "Your Moments"**
  - Save Moment to database via Supabase client
  - Moments list / grid view with filters and sorting
  - Search and management within user's library

- [ ] **Phase 8: Moment Playback**
  - Seamless loop and boundary-enforced playback of saved Moments
  - Mini-player and full-screen player states

- [ ] **Phase 9: Groups**
  - Create and manage Moment Collections/Groups (playlists of timestamped snippets)
  - Reordering, adding, and removing Moments in a Group

- [ ] **Phase 10: Moment Sessions**
  - Sequential and continuous playback across Moments in a Group
  - Cross-fading or instant cueing to next timestamped section

- [ ] **Phase 11: Sharing & Deep Links**
  - Deep link configuration (Universal Links on iOS, App Links on Android)
  - Public Next.js web routes (`/m/[id]` and `/g/[id]`) with dynamic OpenGraph meta tags
  - Direct app fallback / redirection from web to mobile app

- [ ] **Phase 12: Profile & Saved Content**
  - Public user profile pages, bookmarks, and favorited groups
  - Storage buckets for custom avatars and group cover images

- [ ] **Phase 13: Analytics & Polish**
  - PostHog telemetry integration for key funnel events
  - Micro-animations, haptic feedback, and error state handling

- [ ] **Phase 14: Testing & Release**
  - End-to-end integration tests and widget test suites
  - CI/CD build pipelines, fastlane/app store provisioning, Vercel production deployment
