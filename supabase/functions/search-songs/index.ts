// Supabase Edge Function: search-songs
// Purpose: Securely proxies YouTube Data API v3 searches with caching and rate limiting

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
};

// 24-hour cache TTL in milliseconds
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

// Maximum search requests per user per minute (rate limit)
const MAX_REQUESTS_PER_MINUTE = 15;

interface SearchRequest {
  query?: string;
  pageToken?: string;
}

interface SongItem {
  videoId: string;
  title: string;
  channelTitle: string;
  thumbnailUrl: string;
  durationSeconds: number | null;
}

// Unescape standard HTML entities present in YouTube titles/artist names
function unescapeHtml(text: string): string {
  return text
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&apos;/g, "'");
}

// Parse ISO 8601 duration (e.g. PT1H3M20S, PT4M15S, PT45S) into integer seconds
function parseIso8601Duration(iso: string): number | null {
  if (!iso || !iso.startsWith('PT')) return null;

  const regex = /PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/;
  const match = iso.match(regex);
  if (!match) return null;

  const hours = parseInt(match[1] || '0', 10);
  const minutes = parseInt(match[2] || '0', 10);
  const seconds = parseInt(match[3] || '0', 10);

  return hours * 3600 + minutes * 60 + seconds;
}

Deno.serve(async (req: Request) => {
  // 1. Handle CORS Preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    // 2. Parse Query and PageToken from Body or Query String
    let query = '';
    let pageToken: string | undefined;

    if (req.method === 'POST') {
      try {
        const body: SearchRequest = await req.json();
        query = (body.query || '').trim();
        pageToken = body.pageToken?.trim();
      } catch (_) {
        // Fallback to URL query params
      }
    }

    if (!query) {
      const url = new URL(req.url);
      query = (url.searchParams.get('query') || '').trim();
      pageToken = url.searchParams.get('pageToken')?.trim() || pageToken;
    }

    // Input Validation: Reject empty or single-character queries to conserve quota
    if (query.length < 2) {
      return new Response(
        JSON.stringify({
          error: 'Search query must be at least 2 characters long.',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // 3. Initialize Supabase Service Role Client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 4. Rate Limiting Check for Authenticated Users
    const authHeader = req.headers.get('Authorization');
    if (authHeader) {
      const token = authHeader.replace('Bearer ', '');
      const {
        data: { user },
      } = await supabase.auth.getUser(token);

      if (user) {
        const now = new Date();
        const { data: limitRow } = await supabase
          .from('search_rate_limit')
          .select('request_count, window_start')
          .eq('user_id', user.id)
          .maybeSingle();

        if (limitRow) {
          const windowStart = new Date(limitRow.window_start);
          const elapsedSec = (now.getTime() - windowStart.getTime()) / 1000;

          if (elapsedSec < 60) {
            if (limitRow.request_count >= MAX_REQUESTS_PER_MINUTE) {
              return new Response(
                JSON.stringify({
                  error:
                    'Rate limit exceeded. Please wait a minute before making more searches.',
                }),
                {
                  status: 429,
                  headers: {
                    ...corsHeaders,
                    'Content-Type': 'application/json',
                  },
                }
              );
            }

            await supabase
              .from('search_rate_limit')
              .update({ request_count: limitRow.request_count + 1 })
              .eq('user_id', user.id);
          } else {
            await supabase
              .from('search_rate_limit')
              .update({ request_count: 1, window_start: now.toISOString() })
              .eq('user_id', user.id);
          }
        } else {
          await supabase.from('search_rate_limit').insert({
            user_id: user.id,
            request_count: 1,
            window_start: now.toISOString(),
          });
        }
      }
    }

    // 5. Quota-Aware Cache Lookup (First page only)
    const normalizedKey = query.toLowerCase().trim();
    if (!pageToken) {
      const { data: cached } = await supabase
        .from('search_cache')
        .select('results, fetched_at')
        .eq('query_key', normalizedKey)
        .maybeSingle();

      if (cached && cached.results) {
        const fetchedAt = new Date(cached.fetched_at).getTime();
        const nowMs = Date.now();

        if (nowMs - fetchedAt < CACHE_TTL_MS) {
          return new Response(
            JSON.stringify({
              ...cached.results,
              cached: true,
            }),
            {
              status: 200,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          );
        }
      }
    }

    // 6. YouTube Data API v3 Execution
    const youtubeApiKey = Deno.env.get('YOUTUBE_API_KEY');
    if (!youtubeApiKey) {
      return new Response(
        JSON.stringify({
          error: 'YouTube API key is not configured on the server.',
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    const searchUrl = new URL(
      'https://www.googleapis.com/youtube/v3/search'
    );
    searchUrl.searchParams.set('part', 'snippet');
    searchUrl.searchParams.set('type', 'video');
    searchUrl.searchParams.set('videoCategoryId', '10'); // Music category
    searchUrl.searchParams.set('maxResults', '15');
    searchUrl.searchParams.set('q', query);
    searchUrl.searchParams.set('key', youtubeApiKey);
    if (pageToken) {
      searchUrl.searchParams.set('pageToken', pageToken);
    }

    const searchRes = await fetch(searchUrl.toString());

    if (!searchRes.ok) {
      if (searchRes.status === 403) {
        return new Response(
          JSON.stringify({
            error:
              'YouTube search quota exceeded for the day. Please try again later.',
          }),
          {
            status: 429,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        );
      }

      return new Response(
        JSON.stringify({
          error: 'Failed to retrieve songs from YouTube.',
        }),
        {
          status: 502,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    const searchData = await searchRes.json();
    const rawItems = searchData.items || [];

    // Extract video IDs for batch duration enrichment via videos.list
    const videoIds = rawItems
      .map((item: any) => item.id?.videoId)
      .filter((id: string | undefined): id is string => Boolean(id));

    const durationMap: Record<string, number | null> = {};

    if (videoIds.length > 0) {
      try {
        const videosUrl = new URL(
          'https://www.googleapis.com/youtube/v3/videos'
        );
        videosUrl.searchParams.set('part', 'contentDetails');
        videosUrl.searchParams.set('id', videoIds.join(','));
        videosUrl.searchParams.set('key', youtubeApiKey);

        const videosRes = await fetch(videosUrl.toString());
        if (videosRes.ok) {
          const videosData = await videosRes.json();
          for (const vidItem of videosData.items || []) {
            if (vidItem.id && vidItem.contentDetails?.duration) {
              durationMap[vidItem.id] = parseIso8601Duration(
                vidItem.contentDetails.duration
              );
            }
          }
        }
      } catch (err) {
        console.error('Error fetching video durations:', err);
        // Non-fatal: continue returning items with null duration
      }
    }

    // 7. Map to minimal clean response shape
    const songs: SongItem[] = rawItems
      .filter((item: any) => item.id?.videoId)
      .map((item: any) => {
        const videoId = item.id.videoId;
        const snippet = item.snippet || {};
        const thumbnails = snippet.thumbnails || {};
        const thumbnailUrl =
          thumbnails.medium?.url ||
          thumbnails.high?.url ||
          thumbnails.default?.url ||
          `https://i.ytimg.com/vi/${videoId}/mqdefault.jpg`;

        return {
          videoId,
          title: unescapeHtml(snippet.title || 'Untitled Song'),
          channelTitle: unescapeHtml(snippet.channelTitle || 'Unknown Artist'),
          thumbnailUrl,
          durationSeconds: durationMap[videoId] ?? null,
        };
      });

    const responsePayload = {
      items: songs,
      nextPageToken: searchData.nextPageToken || null,
      cached: false,
    };

    // 8. Cache response if it is the first page of results
    if (!pageToken && songs.length > 0) {
      try {
        await supabase.from('search_cache').upsert({
          query_key: normalizedKey,
          results: {
            items: songs,
            nextPageToken: searchData.nextPageToken || null,
          },
          fetched_at: new Date().toISOString(),
        });
      } catch (cacheErr) {
        console.error('Error updating search cache:', cacheErr);
      }
    }

    // 9. Return JSON Response
    return new Response(JSON.stringify(responsePayload), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Unhandled Edge Function error:', error);
    return new Response(
      JSON.stringify({
        error: 'An internal server error occurred while searching songs.',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
