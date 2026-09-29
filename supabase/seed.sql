-- =============================================================================
-- MOMENTS LOCAL DEVELOPMENT SEED SCRIPT
-- =============================================================================
-- WARNING: This seed script is for LOCAL / DEV TESTING ONLY.
-- DO NOT RUN THIS AGAINST PRODUCTION ENVIRONMENTS.
-- =============================================================================

do $$
declare
  user1_id uuid := '00000000-0000-0000-0000-000000000001';
  user2_id uuid := '00000000-0000-0000-0000-000000000002';
  user3_id uuid := '00000000-0000-0000-0000-000000000003';
  m1_id uuid := '10000000-0000-0000-0000-000000000001';
  m2_id uuid := '10000000-0000-0000-0000-000000000002';
  m3_id uuid := '10000000-0000-0000-0000-000000000003';
  m4_id uuid := '10000000-0000-0000-0000-000000000004';
  g1_id uuid := '20000000-0000-0000-0000-000000000001';
begin
  -- 1. Create Mock Auth Users (required for profile foreign keys)
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at)
  values
    (user1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'priyansh@moments.app', '$2a$10$w09u.123fakehashforlocaldevonly1234567890', now(), '{"username":"priyansh","name":"Priyansh"}'::jsonb, now(), now()),
    (user2_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'elena@moments.app', '$2a$10$w09u.123fakehashforlocaldevonly1234567890', now(), '{"username":"synth_elena","name":"Elena Rostova"}'::jsonb, now(), now()),
    (user3_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'marcus@moments.app', '$2a$10$w09u.123fakehashforlocaldevonly1234567890', now(), '{"username":"marcus_lofi","name":"Marcus Chen"}'::jsonb, now(), now())
  on conflict (id) do nothing;

  -- 2. Upsert Profiles (in case trigger did not run during raw SQL)
  insert into public.profiles (id, username, display_name, bio)
  values
    (user1_id, 'priyansh', 'Priyansh', 'Building Moments. Late night synth & memory collector.'),
    (user2_id, 'synth_elena', 'Elena Rostova', 'Synthwave & cyberpunk soundtrack archivist.'),
    (user3_id, 'marcus_lofi', 'Marcus Chen', 'Lo-Fi beats and ambient hooks to code to.')
  on conflict (id) do update set
    username = excluded.username,
    display_name = excluded.display_name,
    bio = excluded.bio;

  -- 3. Seed Moments
  insert into public.moments (id, user_id, video_id, song_title, artist, thumbnail_url, start_seconds, end_seconds, is_public)
  values
    (m1_id, user1_id, 'sVx1mJDeUj8', 'After Dark (Drop)', 'Mr.Kitty', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400', 62.0, 88.0, true),
    (m2_id, user1_id, 'dX3k_QDnzHE', 'Midnight City (Sax Solo)', 'M83', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400', 182.0, 215.0, true),
    (m3_id, user2_id, '8GW6sLrK40k', 'Resonance (Wave)', 'HOME', 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400', 0.0, 32.0, true),
    (m4_id, user3_id, 'MV_3Dpw-BRY', 'Nightcall (Chorus)', 'Kavinsky', 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400', 58.0, 89.0, false)
  on conflict (id) do nothing;

  -- 4. Seed Moment Group
  insert into public.moment_groups (id, user_id, name, description, is_public)
  values
    (g1_id, user1_id, 'Late Night Drives', 'Atmospheric night highway synth snippets.', true)
  on conflict (id) do nothing;

  -- 5. Seed Moment Group Items
  insert into public.moment_group_items (group_id, moment_id, position)
  values
    (g1_id, m1_id, 0),
    (g1_id, m2_id, 1),
    (g1_id, m3_id, 2)
  on conflict (group_id, moment_id) do nothing;

  -- 6. Seed Likes & Saves
  insert into public.likes (user_id, moment_id)
  values
    (user1_id, m3_id),
    (user2_id, m1_id),
    (user3_id, m1_id)
  on conflict (user_id, moment_id) do nothing;

  insert into public.saves (user_id, moment_id)
  values
    (user1_id, m3_id)
  on conflict (user_id, moment_id) do nothing;

  -- 7. Seed Follow
  insert into public.follows (follower_id, following_id)
  values
    (user2_id, user1_id)
  on conflict (follower_id, following_id) do nothing;

end $$;
