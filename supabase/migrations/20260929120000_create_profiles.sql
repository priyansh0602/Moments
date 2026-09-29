-- Migration: 20260929120000_create_profiles.sql
-- Description: Creates public.profiles table, updated_at trigger, and auth.users signup handler.

-- 1. Generic updated_at trigger function
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- 2. Profiles table linked 1:1 with auth.users
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  display_name text,
  avatar_url text,
  bio text,
  moments_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is 'Public user profile information and denormalized counter for Moments.';
comment on column public.profiles.moments_count is 'Denormalized count of moments created by user, kept in sync via trigger.';

-- 3. Trigger to maintain updated_at on profiles
create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- 4. Automatic profile generation on auth.users signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  derived_username text;
begin
  -- Derive username from metadata, or fallback to email prefix + short UUID
  derived_username := coalesce(
    new.raw_user_meta_data->>'username',
    split_part(coalesce(new.email, 'user'), '@', 1) || '_' || substr(new.id::text, 1, 5)
  );

  insert into public.profiles (
    id,
    username,
    display_name,
    avatar_url
  ) values (
    new.id,
    derived_username,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', split_part(coalesce(new.email, 'User'), '@', 1)),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

-- Bind trigger to auth.users
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 5. Row-Level Security (RLS)
alter table public.profiles enable row level security;

-- Anyone (including anon users) can view profile cards
create policy "profiles_select_public"
  on public.profiles
  for select
  using (true);

-- Authenticated users can only update their own profile
create policy "profiles_update_own"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);
