// BlindShake Edge Function: Decline Reveal
// Replaces Firebase Cloud Function: declineReveal
//
// Handles when a user declines to reveal their identity, archiving the match

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface DeclineRevealRequest {
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

        const { matchId }: DeclineRevealRequest = await req.json()
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

        // Check if there's a reveal request to decline
        if (!match.reveal_requested_by || match.reveal_requested_by === user.id) {
            return new Response(
                JSON.stringify({ error: 'No reveal request to decline' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Archive the match
        await supabaseClient
            .from('matches')
            .update({
                status: 'archived',
                archived_at: new Date().toISOString(),
                archived_reason: 'reveal_declined',
            })
            .eq('id', matchId)

        // Add system message
        await supabaseClient
            .from('messages')
            .insert({
                match_id: matchId,
                sender_id: 'system',
                content: 'One user declined to reveal identities. The chat has ended.',
                type: 'system',
            })

        // Clear current match from both user profiles
        await supabaseClient
            .from('users')
            .update({ current_match_id: null })
            .in('id', match.participants)

        console.log('Reveal declined, match archived:', { matchId, userId: user.id })

        return new Response(
            JSON.stringify({ success: true, archived: true }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        console.error('Error in decline-reveal:', error)
        return new Response(
            JSON.stringify({ error: 'Internal server error' }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }
})
