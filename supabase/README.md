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
Serverless TypeScript functions that run on Deno:
- YouTube Data API v3 integration runs exclusively in Supabase Edge Functions (`supabase/functions/youtube-search/`) so the YouTube API key never ships inside the mobile client.
- Test function locally:
  ```bash
  supabase functions serve
  ```
- Deploy function to remote project:
  ```bash
  supabase functions deploy <function_name>
  ```
- Set remote secrets:
  ```bash
  supabase secrets set YOUTUBE_API_KEY=your_key_here
  ```
