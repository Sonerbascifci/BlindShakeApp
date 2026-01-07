// BlindShake Edge Function: Start Shaking
// Replaces Firebase Cloud Function: startShaking
//
// This function handles when a user starts shaking to find matches.
// Uses PostGIS for proximity-based matching (much better than geohash!)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface StartShakingRequest {
    latitude: number
    longitude: number
}

interface ActiveShaker {
    id: string
    user_id: string
    display_name: string | null
    photo_url: string | null
    distance_meters: number
    created_at: string
}

serve(async (req) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // Initialize Supabase client with auth header
        const supabaseUrl = Deno.env.get('SUPABASE_URL')!
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

        const authHeader = req.headers.get('Authorization')
        if (!authHeader) {
            return new Response(
                JSON.stringify({ error: 'Missing authorization header' }),
                { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Create client with user's auth token for RLS
        const supabaseClient = createClient(supabaseUrl, supabaseKey, {
            global: { headers: { Authorization: authHeader } }
        })

        // Get authenticated user
        const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
        if (authError || !user) {
            return new Response(
                JSON.stringify({ error: 'User must be authenticated' }),
                { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Parse request body
        const { latitude, longitude }: StartShakingRequest = await req.json()

        // Validate location
        if (!latitude || !longitude || latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
            return new Response(
                JSON.stringify({ error: 'Invalid location provided' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Get user profile
        const { data: userProfile, error: userError } = await supabaseClient
            .from('users')
            .select('display_name, photo_url')
            .eq('id', user.id)
            .single()

        if (userError) {
            console.error('User profile not found:', userError)
            return new Response(
                JSON.stringify({ error: 'User profile not found' }),
                { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Calculate geohash for backwards compatibility (reduced precision for privacy)
        const geohash = encodeGeohash(latitude, longitude, 5)
        const expiresAt = new Date(Date.now() + 30000) // 30 seconds TTL

        // Upsert active shaker entry (PostGIS point)
        const { error: shakerError } = await supabaseClient
            .from('active_shakers')
            .upsert({
                user_id: user.id,
                location: `POINT(${longitude} ${latitude})`, // PostGIS format: lng lat
                geohash,
                display_name: userProfile.display_name,
                photo_url: userProfile.photo_url,
                expires_at: expiresAt.toISOString(),
            }, {
                onConflict: 'user_id'
            })

        if (shakerError) {
            console.error('Error adding shaker:', shakerError)
            return new Response(
                JSON.stringify({ error: 'Failed to start shaking' }),
                { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Find nearby matches using PostGIS
        const { data: nearbyShakers, error: searchError } = await supabaseClient
            .rpc('find_nearby_shakers', {
                lat: latitude,
                lng: longitude,
                radius_meters: 1000000, // 1000km max radius
                exclude_user_id: user.id
            })

        if (searchError) {
            console.error('Error finding matches:', searchError)
            // Continue without match - user is still in the pool
            return new Response(
                JSON.stringify({
                    success: true,
                    geohash,
                    match: null,
                    message: 'Searching for matches...'
                }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // If we found potential matches, create a match with the closest one
        if (nearbyShakers && nearbyShakers.length > 0) {
            const matchedShaker = nearbyShakers[0] as ActiveShaker

            // Create match using transaction
            const match = await createMatch(supabaseClient, user.id, matchedShaker.user_id)

            if (match) {
                // Remove both users from active shakers
                await supabaseClient
                    .from('active_shakers')
                    .delete()
                    .in('user_id', [user.id, matchedShaker.user_id])

                return new Response(
                    JSON.stringify({
                        success: true,
                        geohash,
                        match: {
                            matchId: match.id,
                            otherUser: {
                                id: matchedShaker.user_id,
                                displayName: 'Anonymous', // Don't reveal during anonymous phase
                                photoURL: null,
                            },
                            anonymousPhaseEnds: match.anonymous_phase_ends,
                        }
                    }),
                    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                )
            }
        }

        // No match found yet
        return new Response(
            JSON.stringify({
                success: true,
                geohash,
                match: null,
                message: 'Added to matching pool. Waiting for matches...'
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        console.error('Error in start-shaking:', error)
        return new Response(
            JSON.stringify({ error: 'Internal server error' }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }
})

// Helper: Create a match between two users
async function createMatch(
    supabase: ReturnType<typeof createClient>,
    user1Id: string,
    user2Id: string
) {
    const anonymousPhaseEnds = new Date(Date.now() + 15 * 60 * 1000) // 15 minutes

    const { data: match, error } = await supabase
        .from('matches')
        .insert({
            participants: [user1Id, user2Id],
            status: 'anonymous',
            anonymous_phase_ends: anonymousPhaseEnds.toISOString(),
            participant_info: {
                [user1Id]: { joinedAt: new Date().toISOString() },
                [user2Id]: { joinedAt: new Date().toISOString() },
            }
        })
        .select()
        .single()

    if (error) {
        console.error('Error creating match:', error)
        return null
    }

    // Update both users with current match
    await supabase
        .from('users')
        .update({
            current_match_id: match.id,
            last_match_at: new Date().toISOString()
        })
        .in('id', [user1Id, user2Id])

    return match
}

// Simple geohash encoder (for backwards compatibility)
function encodeGeohash(lat: number, lng: number, precision: number): string {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz'
    let minLat = -90, maxLat = 90
    let minLng = -180, maxLng = 180
    let hash = ''
    let bit = 0
    let ch = 0
    let isLng = true

    while (hash.length < precision) {
        if (isLng) {
            const mid = (minLng + maxLng) / 2
            if (lng >= mid) {
                ch |= 1 << (4 - bit)
                minLng = mid
            } else {
                maxLng = mid
            }
        } else {
            const mid = (minLat + maxLat) / 2
            if (lat >= mid) {
                ch |= 1 << (4 - bit)
                minLat = mid
            } else {
                maxLat = mid
            }
        }
        isLng = !isLng
        if (bit < 4) {
            bit++
        } else {
            hash += base32[ch]
            bit = 0
            ch = 0
        }
    }
    return hash
}
