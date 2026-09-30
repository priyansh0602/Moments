-- Migration: Create search_cache and search_rate_limit tables
-- Purpose: Quota-aware caching (100 units/search) and per-user abuse prevention for YouTube API v3 proxying

-- 1. Search Cache Table
create table if not exists public.search_cache (
  query_key text primary key,
  results jsonb not null,
  fetched_at timestamptz not null default now()
);

comment on table public.search_cache is 'Cached YouTube search responses keyed by normalized search query string to conserve API quota.';

-- Enable Row Level Security
alter table public.search_cache enable row level security;

-- Cache reads are harmless: allow select to all authenticated and anon users
create policy "search_cache_select_public"
  on public.search_cache
  for select
  using (true);

-- Cache writes restricted strictly to service_role only (used internally by Edge Functions)
create policy "search_cache_service_role_all"
  on public.search_cache
  for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

-- Index on fetched_at for TTL lookups and cache cleanup queries
create index if not exists idx_search_cache_fetched_at
  on public.search_cache (fetched_at);

-- 2. Search Rate Limit Table
create table if not exists public.search_rate_limit (
  user_id uuid primary key references auth.users(id) on delete cascade,
  request_count int not null default 1,
  window_start timestamptz not null default now()
);

comment on table public.search_rate_limit is 'Per-user search rate limiting records managed by Edge Functions to prevent quota exhaustion.';

-- Enable Row Level Security
alter table public.search_rate_limit enable row level security;

-- Rate limiting records restricted strictly to service_role (clients cannot bypass)
create policy "search_rate_limit_service_role_only"
  on public.search_rate_limit
  for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');
