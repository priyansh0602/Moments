# Moments Architecture & System Design

Moments is a cross-platform mobile and web application that enables users to curate, organize, play, and share precise musical snippets ("Moments") from songs hosted on YouTube.

---

## 1. Architectural Philosophy & Core Principles

### Core Principle 1: Moments are Timestamped References, Never Media Downloads
> **A Moment is strictly a lightweight metadata reference:**
> `(videoId, startSeconds, endSeconds, title, artist, ...)`
> 
> Moments **never** downloads, extracts, strips, converts, stores, or re-hosts YouTube audio or video files. All media playback occurs directly inside official YouTube IFrame players, strictly respecting copyright, content licensing, and YouTube's Terms of Service.

### Core Principle 2: Zero Client-Side Secret Exposure
> **The YouTube Data API v3 key never ships inside the mobile client or frontend bundle.**
> 
> All YouTube queries, searches, and metadata lookups are proxied through an authenticated **Supabase Edge Function** (`supabase/functions/search-songs`). The mobile app calls this Edge Function using its Supabase client (`client.functions.invoke('search-songs', ...)`). The API key is securely stored in Supabase Secrets (`YOUTUBE_API_KEY`).

---

## 2. Tech Stack Overview

```
+-----------------------------------------------------------------------------------+
|                                  MOMENTS MONOREPO                                 |
+-----------------------------------------+-----------------------------------------+
|                MOBILE                   |                   WEB                   |
|  Flutter (Dart) • Material 3            |  Next.js (App Router, TypeScript)       |
|  State: Riverpod (Generators & Lint)    |  Deployment: Vercel                     |
|  Navigation: go_router                  |  Purpose: Landing + /m/[id] & /g/[id]   |
|  Player: YouTube IFrame Player (Visual) |           share previews                |
+-----------------------------------------+-----------------------------------------+
                                     |
                                     v
+-----------------------------------------------------------------------------------+
|                              BACKEND & DATA LAYER                                 |
|                       Supabase (Managed PostgreSQL 15)                            |
|  - PostgreSQL Database with Row Level Security (RLS) policies                     |
|  - Supabase Auth (Google OAuth, Session Tokens)                                   |
|  - Supabase Storage (Group covers, avatars)                                       |
|  - Supabase Edge Functions (`search-songs` Deno / TypeScript runtime)             |
|  - Quota-aware `search_cache` & `search_rate_limit` tables                        |
+-----------------------------------------------------------------------------------+
                                     |
                                     v
+-----------------------------------------------------------------------------------+
|                             EXTERNAL THIRD-PARTY APIs                             |
|  - YouTube Data API v3 (Queried ONLY via Supabase Edge Function)                   |
|  - PostHog (Product analytics, privacy-compliant event telemetry)                 |
+-----------------------------------------------------------------------------------+
```

---

## 3. High-Level Data Flow

```mermaid
sequenceDiagram
    autonumber
    actor User as User (Mobile App)
    participant Edge as Supabase Edge Function (search-songs)
    participant DB as Supabase PostgreSQL (Cache & RLS)
    participant YT as YouTube Data API v3

    %% Search Flow
    Note over User,YT: Song Search Flow (Phase 4)
    User->>Edge: POST /functions/v1/search-songs { query, pageToken? }
    Edge->>DB: Check rate limit for user_id (max 15/min)
    alt Rate limit exceeded
        Edge-->>User: 429 Too Many Requests
    end
    opt First page query (no pageToken)
        Edge->>DB: SELECT results FROM search_cache WHERE query_key = normalized(query)
        alt Cache hit (< 24h old)
            Edge-->>User: 200 OK (cached: true, 0 quota units consumed)
        end
    end
    Edge->>YT: search.list (Music category, maxResults=15) [100 quota units]
    YT-->>Edge: YouTube video items (snippets, thumbnails)
    Edge->>YT: videos.list?part=contentDetails&id=batch_ids [1 quota unit]
    YT-->>Edge: Duration content details
    Edge->>DB: UPSERT search_cache (query_key, results, now)
    Edge-->>User: 200 OK { items: [Song], nextPageToken, cached: false }
```

---

## 4. Key Subsystems

### Mobile Client (`app/`)
- **Flutter & Material 3**: Provides high-performance 60/120 FPS native UI with modern Material Design tokens.
- **Riverpod Architecture**: State separation into functional feature slices (`data/`, `domain/`, `presentation/`).
- **go_router**: Declarative route hierarchy with deep linking support for `/m/:id` and `/g/:id`.
- **Playback**: Embedded visible `youtube_player_flutter` / webview controller ensuring player visibility at all times.

### Web Client (`web/`)
- **Next.js App Router**: Optimized for fast server-side rendering (SSR), high performance, and dynamic OpenGraph/meta tag generation for social sharing.
- **Dynamic Routes**:
  - `/m/[id]`: Preview and play individual timestamped Moments.
  - `/g/[id]`: Preview and sequentially play curated Groups of Moments.

### Supabase Backend (`supabase/`)
- **Row Level Security (RLS)**: Enforces zero-trust data access directly in Postgres. Users can only edit/delete their own moments, groups, and sessions.
- **Edge Functions**: Isolates external API keys and performs server-side validation.

---

## 5. Database Schema & Row-Level Security (RLS)

### Database Tables Summary
- **`profiles`**: Public user identity, handles, avatars, bios, and denormalized `moments_count` maintained via trigger.
- **`moments`**: Core snippet references with YouTube `video_id`, timestamp boundaries (`start_seconds`, `end_seconds`), metadata, and privacy flag (`is_public`).
- **`moment_groups`**: User-curated playlists and snippet collections with privacy controls (`is_public`).
- **`moment_group_items`**: Ordered join table linking moments into groups by `position` (omits strict `UNIQUE(group_id, position)` to facilitate smooth drag-and-drop batch reordering).
- **`likes`**: Social likes on Moments with composite uniqueness on `(user_id, moment_id)`.
- **`saves`**: Private personal bookmarks of other creators' Moments into a user's library.
- **`follows`**: Directed social follow graph edges between user profiles with self-follow prevention.
- **`search_cache`**: Quota-aware cache storing sanitized YouTube search results indexed by normalized query text.
- **`search_rate_limit`**: Per-user sliding-window request tracker restricting search frequency to prevent quota drain.

### Row-Level Security (RLS) Philosophy
Every table has Row-Level Security (`ENABLE ROW LEVEL SECURITY`) activated unconditionally:
- **Public vs. Private Split**: Rows with `is_public = true` are readable by anyone (including anonymous web previewers for deep link previews). Rows with `is_public = false` are strictly restricted to the owning creator (`auth.uid() = user_id`).
- **Zero-Trust Writes**: Only authenticated owners can `INSERT`, `UPDATE`, or `DELETE` their own entities. Profile inserts are strictly automated via `auth.users` trigger with `SECURITY DEFINER`.
- **Group Isolation**: `moment_group_items` inherit access rules dynamically through an `EXISTS` subquery verifying the parent `moment_groups` ownership or public visibility.
- **Private Bookmarks**: `saves` are strictly private to the user (`auth.uid() = user_id`), while `likes` and `follows` permit open reads for counters and social discovery.
- **Service Role Restriction**: `search_cache` allows public `SELECT` reads while reserving writes strictly to `service_role`. `search_rate_limit` is 100% service-role isolated.

---

## 6. YouTube Song Search Proxy Architecture (Phase 4)

### 6.1 Edge-Function-in-the-Middle Pattern
To protect third-party credentials, the mobile client never communicates with YouTube Data API v3 directly:
1. The client invokes Supabase Edge Function `search-songs`.
2. The Edge Function runs securely in Deno with server-side access to `YOUTUBE_API_KEY` stored exclusively in Supabase Secrets.
3. Upstream errors, quota limits, and raw YouTube API payloads are sanitized before returning clean, standardized song DTOs to the app.

### 6.2 Quota Analysis & Caching Strategy
- **YouTube API Quota Cost**:
  - `search.list` costs **100 quota units** per call.
  - `videos.list` (batch duration lookup) costs **1 quota unit** per call.
  - Total per unique search = **101 quota units**.
  - Default daily free tier quota = **10,000 units/day**.
  - Without caching: ~99 searches/day would exhaust the entire project's quota.
- **24-Hour Cache Window (`search_cache`)**:
  - Music video titles, channel names, and durations are virtually immutable for published tracks.
  - Queries are normalized (`query.toLowerCase().trim()`) and cached in PostgreSQL JSONB for 24 hours (`86,400,000 ms`).
  - Cache hits consume **0 YouTube quota units**, responding with sub-100ms latency.
  - With heavy clustering around trending songs, artist names, and popular tracks, caching enables hundreds to thousands of daily searches while remaining within free tier limits.

### 6.3 Rate Limiting / Abuse Guard
- Any authenticated user could potentially loop search queries if a client-side defect occurs.
- `search_rate_limit` tracks rolling 60-second windows per `auth.uid()`, capping queries at **15 searches per minute**.
- Exceeded thresholds immediately reject with HTTP 429 (`Too Many Requests`), halting upstream quota burns.

---

## 7. Playback Engine Architecture (Phase 5)

### 7.1 Single Persistent PlatformView Pattern (`PersistentPlayerHost`)
- **YouTube Terms of Service Compliance**:
  YouTube ToS mandates that playback must occur within official IFrame players and remain visibly rendered on screen at all times (no audio extraction or hidden background execution).
- **Zero-Teardown WebView Preservation**:
  In Flutter, WebViews (`PlatformViewLink` / `AndroidView`) instantiate native Android/iOS view hierarchies. Destroying or re-mounting the widget tears down the Chromium web context and stops audio playback.
- **Top-Level Dynamic Geometry**:
  `PersistentPlayerHost` wraps the root router tree in `MaterialApp.router`'s `builder`. A single `YoutubePlayer` instance is instantiated once and smoothly animates its geometry via `AnimatedPositioned` between:
  1. **Mini-player mode**: 46x46 square thumbnail docked at bottom-left inside `MiniPlayerBar` (passes touches through).
  2. **Full-player mode**: 16:9 widescreen video frame centered at top of `FullPlayerScreen` (interactive gestures enabled).
  Transitions between mini and full players (and between tabs) preserve identical playback state without reload or stutter.

### 7.2 OS Media Session Proxy Pattern (`audio_service`)
- WebViews cannot natively broadcast OS media session state to Android MediaNotification or iOS Control Center.
- `MomentsAudioHandler` (`audio_service`) acts as an external **state proxy / mirror**:
  - **Single Source of Truth**: The `PlayerController` stream drives all state. The proxy handler listens to playback updates and synchronizes them outward to the OS via `playbackState` and `mediaItem`.
  - **No Real Audio in Proxy**: `audio_service` plays zero audio itself; it solely mirrors track title, artist, artwork (`artUri`), duration, and playback status into OS notifications.
  - **Bi-directional Action Forwarding**: Tapping notification play/pause/seek controls calls `MomentsAudioHandler` methods (`play()`, `pause()`, `seek()`), which route directly back into `PlayerController`.

### 7.3 Real Device Backgrounding Behavior Report
- **Android Platform Behavior**:
  - The Android system Media Notification is sustained via `foregroundServiceType="mediaPlayback"` with `WAKE_LOCK`. The app process and notification persist reliably without OS task termination.
  - **Standard Chromium WebView Pausing**: When the user backgrounds the application (e.g. presses Home or switches to another app), Android's WebKit/Chromium engine automatically halts frame rendering and suspends JavaScript execution/timers to conserve battery and CPU. Consequently, YouTube IFrame video and audio playback pauses while backgrounded.
  - **Instant Resumption**: Track position, video ID, and player state remain fully preserved in memory. Resuming the application or tapping the notification instantly re-activates the player from the exact millisecond without reloading.

### 7.4 iOS Configuration Requirements
- **Info.plist**: `UIBackgroundModes` with `<string>audio</string>` is configured in `ios/Runner/Info.plist`.
- **Xcode Manual Setting Note**: On iOS devices, the "Audio, AirPlay, and Picture in Picture" capability must be toggled in Xcode's "Signing & Capabilities" tab for production App Store provisioning profiles.

---

## 8. Moment Trimming Engine Architecture (Phase 6)

### 8.1 Trimming Domain Model & Pure Validation (`TrimSelection`)
- **Immutable Freezed Domain Model**:
  `TrimSelection` models the exact start, end, and duration bounds of a proposed clip.
- **Pure Validation Boundary (`validateTrim`)**:
  - Enforces minimum clip length: **3.0 seconds** (`TrimSelection.minClipSeconds`).
  - Enforces maximum clip length: **60.0 seconds** (`TrimSelection.maxClipSeconds`).
  - Strict boundary assertions: start $\ge$ 0, end > start, end $\le$ total song duration.
  - Zero side effects; pure function enables fast, deterministic unit test coverage.

### 8.2 Boundary-Constrained Loop Preview Engine
- **PlayerController Range Enforcement**:
  - `setPreviewRange({startSeconds, endSeconds, loop: true})` configures playback boundaries on `YoutubePlayerControllerImpl`.
  - Background polling timer (250ms interval) tracks live playback position.
  - When playback position reaches or exceeds `endSeconds`, the controller immediately seeks back to `startSeconds` (`seekTo(start); play();`) creating a seamless audio loop.
  - Calling `clearPreviewRange()` halts loop tracking and restores full track playback.

### 8.3 Dual-Handle Waveform Range Slider (`MomentRangeSlider`)
- **Custom Grab Handles**: Custom `RangeSliderThumbShape` with dual-layer circular borders and center grip indicators.
- **Waveform Equalizer Visualization**: Custom painted responsive equalizer bars that dynamically change color and opacity inside vs. outside the active clip range.
- **Live Playhead Indicator**: Real-time white playhead position bar superimposed over the timeline ruler and waveform.

### 8.4 State Management Isolation
- `TrimSelectionNotifier` reads initial track duration from `PlayerPlaybackState` once upon mount and listens strictly for `videoId` switches.
- Position ticks from normal song playback never trigger rebuilds or wipe out active drag adjustments.
- Dedicated capture triggers ("Set Start Here", "Set End Here") and micro-steppers (-1s / +1s) allow single-tap millisecond precision.

