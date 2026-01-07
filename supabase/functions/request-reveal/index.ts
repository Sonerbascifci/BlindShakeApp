// BlindShake Edge Function: Request Reveal
// Replaces Firebase Cloud Function: requestReveal
//
// Handles reveal request logic with PostgreSQL transactions

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface RequestRevealRequest {
    matchId: string
}

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseUrl = Deno.env.get('SUPABASE_URL')!
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

        const authHeader = req.headers.get('Authorization')
        if (!authHeader) {
            return new Response(
                JSON.stringify({ error: 'Missing authorization header' }),
                { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        const supabaseClient = createClient(supabaseUrl, supabaseKey, {
            global: { headers: { Authorization: authHeader } }
        })

        const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
        if (authError || !user) {
            return new Response(
                JSON.stringify({ error: 'User must be authenticated' }),
                { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        const { matchId }: RequestRevealRequest = await req.json()
        if (!matchId) {
            return new Response(
                JSON.stringify({ error: 'Match ID is required' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Get match data
        const { data: match, error: matchError } = await supabaseClient
            .from('matches')
            .select('*')
            .eq('id', matchId)
            .single()

        if (matchError || !match) {
            return new Response(
                JSON.stringify({ error: 'Match not found' }),
                { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Verify user is participant
        if (!match.participants.includes(user.id)) {
            return new Response(
                JSON.stringify({ error: 'User not participant in this match' }),
                { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Check if anonymous phase has ended
        if (new Date() < new Date(match.anonymous_phase_ends)) {
            return new Response(
                JSON.stringify({ error: 'Anonymous phase still active' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Check current status
        if (match.status !== 'anonymous') {
            return new Response(
                JSON.stringify({ error: 'Match is not in anonymous phase' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        let result: { revealed: boolean; waitingForOther?: boolean }

        if (match.reveal_requested_by) {
            // Someone already requested reveal
            if (match.reveal_requested_by === user.id) {
                return new Response(
                    JSON.stringify({ error: 'You already requested reveal' }),
                    { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                )
            }

            // Both users want to reveal - proceed!
            // Get participant details
            const { data: participants } = await supabaseClient
                .from('users')
                .select('id, display_name, photo_url, email')
                .in('id', match.participants)

            const revealedInfo: Record<string, any> = {}
            participants?.forEach(p => {
                revealedInfo[p.id] = {
                    displayName: p.display_name,
                    photoURL: p.photo_url,
                    email: p.email,
                }
            })

            // Update match to revealed
            await supabaseClient
                .from('matches')
                .update({
                    status: 'revealed',
                    revealed_at: new Date().toISOString(),
                    revealed_participant_info: revealedInfo,
                })
                .eq('id', matchId)

            // Add system message
            await supabaseClient
                .from('messages')
                .insert({
                    match_id: matchId,
                    sender_id: 'system',
                    content: 'Both users chose to reveal their identities! 🎉',
                    type: 'system',
                })

            result = { revealed: true }

        } else {
            // First reveal request
            await supabaseClient
                .from('matches')
                .update({ reveal_requested_by: user.id })
                .eq('id', matchId)

            // Add system message
            await supabaseClient
                .from('messages')
                .insert({
                    match_id: matchId,
                    sender_id: 'system',
                    content: 'One user wants to reveal identities. Waiting for the other to decide...',
                    type: 'system',
                })

            result = { revealed: false, waitingForOther: true }
        }

        console.log('Reveal requested:', { matchId, userId: user.id, result })

        return new Response(
            JSON.stringify({ success: true, ...result }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        console.error('Error in request-reveal:', error)
        return new Response(
            JSON.stringify({ error: 'Internal server error' }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }
})
