-- Migration: 20260929120002_create_moment_groups.sql
-- Description: Creates public.moment_groups table, indexes, updated_at trigger, and RLS.

create table public.moment_groups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  description text,
  cover_thumbnail_url text,
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.moment_groups is 'Playlists and collections of Moments created by users.';

-- 1. Indexes
create index moment_groups_user_id_idx on public.moment_groups(user_id);
create index moment_groups_public_created_at_idx on public.moment_groups(is_public, created_at desc);

-- 2. Trigger for updated_at
create trigger set_moment_groups_updated_at
  before update on public.moment_groups
  for each row execute function public.set_updated_at();

-- 3. Row-Level Security (RLS)
alter table public.moment_groups enable row level security;

-- Owner can read their own groups; public groups visible to all
create policy "moment_groups_select_own_or_public"
  on public.moment_groups
  for select
  using ((auth.uid() = user_id) or (is_public = true));

-- Owners can create groups
create policy "moment_groups_insert_own"
  on public.moment_groups
  for insert
  with check (auth.uid() = user_id);

-- Owners can update their groups
create policy "moment_groups_update_own"
  on public.moment_groups
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Owners can delete their groups
create policy "moment_groups_delete_own"
  on public.moment_groups
  for delete
  using (auth.uid() = user_id);
