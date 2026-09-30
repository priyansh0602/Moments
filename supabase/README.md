# Supabase Backend Configuration

This directory contains database migrations, Edge Functions, local seeds, and Supabase CLI configuration for the Moments application.

## Prerequisites & CLI Installation

The Supabase CLI is used to develop locally, manage database migrations, and deploy Edge Functions.

### Installation

- **macOS / Linux (Homebrew)**:
  ```bash
  brew install supabase/tap/supabase
  ```

- **Windows (Scoop or npm)**:
  ```powershell
  # Using Scoop
  scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
  scoop install supabase

  # Or using npm
  npm install -g supabase
  ```

## Authentication & Linking Projects

1. **Log in to Supabase CLI**:
   ```bash
   supabase login
   ```
   This generates a personal access token in your browser to authenticate CLI commands.

2. **Link to Remote Project**:
   ```bash
   supabase link --project-ref <your-project-ref>
   ```
   Retrieve your project reference ID from your Supabase dashboard URL: `https://supabase.com/dashboard/project/<project-ref>`.

## Development Workflow

### Local Development
```bash
# Start local containers (Postgres, Studio, Auth, Storage, Edge Runtime)
supabase start

# Stop local containers
supabase stop
```
When running locally:
- **Studio URL**: `http://localhost:54323`
- **API URL**: `http://localhost:54321`

### Database Migrations (Phase 2+)
Database schema changes are stored as sequential timestamped SQL migrations in `supabase/migrations/`:
- **Create new migration**:
  ```bash
  supabase migration new <migration_name>
  ```
- **Apply migrations to linked remote project**:
  ```bash
  supabase db push
  ```
- **Apply migrations sequentially**:
  ```bash
  supabase migration up
  ```
- **Apply via Supabase Dashboard SQL Editor**:
  You can run the migration files sequentially in the [Supabase SQL Editor](https://supabase.com/dashboard/project/syrzrwbbmpenqurkcaon/sql/new).

### Generating Dart Client Types for Flutter (Phase 3+)
Generate strongly-typed Dart data models matching your live Postgres schema:
```bash
# Generate types from linked remote Supabase project
supabase gen types dart --linked > app/lib/core/data/schema.dart

# Or generate types directly using project reference
supabase gen types dart --project-id syrzrwbbmpenqurkcaon --schema public > app/lib/core/data/schema.dart
```
*(We will consume and bind these generated types in Phase 3 repositories).*

### Edge Functions (Phase 4+)
Serverless TypeScript functions that run on Deno (Supabase Edge Runtime):

- **Function Name**: `search-songs` (`supabase/functions/search-songs/index.ts`)
- **Purpose**: Proxies YouTube Data API v3 calls, enriches video duration via batch `videos.list`, caches results in `search_cache` (24h TTL), and enforces rate limits via `search_rate_limit`.

#### 1. Set Remote Secrets
Set the YouTube API key in your remote Supabase project:
```bash
# Using Supabase CLI
supabase secrets set YOUTUBE_API_KEY=<your_youtube_data_api_v3_key>

# Verify secrets list
supabase secrets list
```
*(Alternatively, configure `YOUTUBE_API_KEY` under **Project Settings &rarr; Edge Functions &rarr; Secrets** in your Supabase Dashboard).*

#### 2. Apply Database Migration
Apply the `search_cache` and `search_rate_limit` schema migration:
```bash
# Via Supabase CLI (if linked)
supabase db push

# Or execute SQL directly in Supabase SQL Editor:
# Copy contents of supabase/migrations/20260930120000_create_search_cache_and_rate_limit.sql
# into https://supabase.com/dashboard/project/syrzrwbbmpenqurkcaon/sql/new
```

#### 3. Test Function Locally
```bash
# Serve Edge Functions locally with test env vars
supabase functions serve search-songs --env-file supabase/.env.local
```

#### 4. Deploy Function to Remote Project
```bash
# Initial deployment
supabase functions deploy search-songs --project-ref syrzrwbbmpenqurkcaon

# Redeploy after edits
supabase functions deploy search-songs --no-verify-jwt
```

#### 5. Test Function via cURL
```bash
# Test POST invocation
curl -i --location --request POST 'https://syrzrwbbmpenqurkcaon.supabase.co/functions/v1/search-songs' \
  --header 'Authorization: Bearer <anon_or_user_jwt>' \
  --header 'Content-Type: application/json' \
  --data '{"query":"after dark"}'
```
