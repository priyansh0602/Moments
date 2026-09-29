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
