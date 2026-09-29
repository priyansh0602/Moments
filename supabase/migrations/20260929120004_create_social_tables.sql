-- Migration: 20260929120004_create_social_tables.sql
-- Description: Creates likes, saves, and follows tables with indexes, constraints, and RLS.

-- =============================================================================
-- 1. LIKES TABLE (Likes on Moments)
-- =============================================================================
create table public.likes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  moment_id uuid not null references public.moments(id) on delete cascade,
  created_at timestamptz not null default now(),

  constraint likes_user_moment_unique unique (user_id, moment_id)
);

comment on table public.likes is 'User likes on Moments snippets.';

create index likes_moment_id_idx on public.likes(moment_id);
create index likes_user_id_idx on public.likes(user_id);

alter table public.likes enable row level security;

-- Open read access for like counters and status checks
create policy "likes_select_all"
  on public.likes
  for select
  using (true);

-- Authenticated users can insert their own likes
create policy "likes_insert_own"
  on public.likes
  for insert
  with check (auth.uid() = user_id);

-- Authenticated users can remove their own likes
create policy "likes_delete_own"
  on public.likes
  for delete
  using (auth.uid() = user_id);


-- =============================================================================
-- 2. SAVES TABLE (Private Bookmarks of Moments)
-- =============================================================================
create table public.saves (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  moment_id uuid not null references public.moments(id) on delete cascade,
  created_at timestamptz not null default now(),

  constraint saves_user_moment_unique unique (user_id, moment_id)
);

comment on table public.saves is 'Private library bookmarks of Moments created by other users.';

create index saves_user_id_idx on public.saves(user_id);
create index saves_moment_id_idx on public.saves(moment_id);

alter table public.saves enable row level security;

-- Strictly private: users only see what they saved
create policy "saves_select_own"
  on public.saves
  for select
  using (auth.uid() = user_id);

-- Users can save moments to their personal library
create policy "saves_insert_own"
  on public.saves
  for insert
  with check (auth.uid() = user_id);

-- Users can unsave/remove bookmarks from their library
create policy "saves_delete_own"
  on public.saves
  for delete
  using (auth.uid() = user_id);


-- =============================================================================
-- 3. FOLLOWS TABLE (User to User Social Graph)
-- =============================================================================
create table public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),

  primary key (follower_id, following_id),
  constraint follows_no_self_follow check (follower_id <> following_id)
);

comment on table public.follows is 'Social follow graph between user profiles.';

create index follows_following_id_idx on public.follows(following_id);

alter table public.follows enable row level security;

-- Open read access for followers/following lists and count metrics
create policy "follows_select_all"
  on public.follows
  for select
  using (true);

-- Authenticated users can follow others
create policy "follows_insert_own"
  on public.follows
  for insert
  with check (auth.uid() = follower_id);

-- Authenticated users can unfollow others
create policy "follows_delete_own"
  on public.follows
  for delete
  using (auth.uid() = follower_id);
