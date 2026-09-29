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
-- Migration: 20260929120003_create_moment_group_items.sql
-- Description: Creates public.moment_group_items ordered join table, composite indexes, and RLS.

create table public.moment_group_items (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.moment_groups(id) on delete cascade,
  moment_id uuid not null references public.moments(id) on delete cascade,
  position integer not null default 0,
  added_at timestamptz not null default now(),

  -- Prevents duplicate entries of the exact same moment in the same group
  constraint moment_group_items_group_moment_unique unique (group_id, moment_id)
);

comment on table public.moment_group_items is 'Ordered join table linking moments into collections/groups.';
comment on column public.moment_group_items.position is 'Sequential playback and visual ordering index. Note: UNIQUE(group_id, position) is intentionally omitted to prevent transient collision errors during drag-and-drop batch reordering.';

-- 1. Index on (group_id, position) for fast ordered retrieval
create index moment_group_items_group_position_idx on public.moment_group_items(group_id, position);
create index moment_group_items_moment_id_idx on public.moment_group_items(moment_id);

-- 2. Row-Level Security (RLS)
alter table public.moment_group_items enable row level security;

-- Visible if the parent group is public or owned by requester
create policy "moment_group_items_select_visible"
  on public.moment_group_items
  for select
  using (
    exists (
      select 1 from public.moment_groups mg
      where mg.id = moment_group_items.group_id
        and ((mg.user_id = auth.uid()) or (mg.is_public = true))
    )
  );

-- Only owner of the parent group can add moments
create policy "moment_group_items_insert_own_group"
  on public.moment_group_items
  for insert
  with check (
    exists (
      select 1 from public.moment_groups mg
      where mg.id = moment_group_items.group_id
        and mg.user_id = auth.uid()
    )
  );

-- Only owner of the parent group can update ordering / positions
create policy "moment_group_items_update_own_group"
  on public.moment_group_items
  for update
  using (
    exists (
      select 1 from public.moment_groups mg
      where mg.id = moment_group_items.group_id
        and mg.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.moment_groups mg
      where mg.id = moment_group_items.group_id
        and mg.user_id = auth.uid()
    )
  );

-- Only owner of the parent group can remove moments from the group
create policy "moment_group_items_delete_own_group"
  on public.moment_group_items
  for delete
  using (
    exists (
      select 1 from public.moment_groups mg
      where mg.id = moment_group_items.group_id
        and mg.user_id = auth.uid()
    )
  );
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
