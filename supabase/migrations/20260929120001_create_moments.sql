-- Migration: 20260929120001_create_moments.sql
-- Description: Creates public.moments table, check constraints, indexes, counter triggers, and RLS.

create table public.moments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  video_id text not null,
  song_title text not null,
  artist text,
  thumbnail_url text,
  start_seconds numeric not null,
  end_seconds numeric not null,
  is_public boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint moments_start_seconds_non_negative check (start_seconds >= 0),
  constraint moments_end_greater_than_start check (end_seconds > start_seconds)
);

comment on table public.moments is 'Saved YouTube song snippet boundaries (Moments) without storing audio media.';

-- 1. Indexes for fast retrieval
create index moments_user_id_idx on public.moments(user_id);
create index moments_video_id_idx on public.moments(video_id);
create index moments_public_created_at_idx on public.moments(is_public, created_at desc);

-- 2. Trigger for updated_at
create trigger set_moments_updated_at
  before update on public.moments
  for each row execute function public.set_updated_at();

-- 3. Trigger to maintain profiles.moments_count in sync
create or replace function public.handle_moment_count_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (tg_op = 'INSERT') then
    update public.profiles
    set moments_count = moments_count + 1
    where id = new.user_id;
    return new;
  elsif (tg_op = 'DELETE') then
    update public.profiles
    set moments_count = greatest(0, moments_count - 1)
    where id = old.user_id;
    return old;
  end if;
  return null;
end;
$$;

create trigger on_moment_inserted
  after insert on public.moments
  for each row execute function public.handle_moment_count_change();

create trigger on_moment_deleted
  after delete on public.moments
  for each row execute function public.handle_moment_count_change();

-- 4. Row-Level Security (RLS)
alter table public.moments enable row level security;

-- Owner can read their own (including private), others can read public moments
create policy "moments_select_own_or_public"
  on public.moments
  for select
  using ((auth.uid() = user_id) or (is_public = true));

-- Authenticated users can insert their own moments
create policy "moments_insert_own"
  on public.moments
  for insert
  with check (auth.uid() = user_id);

-- Owners can update their own moments
create policy "moments_update_own"
  on public.moments
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Owners can delete their own moments
create policy "moments_delete_own"
  on public.moments
  for delete
  using (auth.uid() = user_id);
