-- BlindShake Supabase Realtime Configuration
-- Migration: 004_realtime_config.sql
-- Description: Enable realtime subscriptions for messages and matches

-- =============================================================================
-- ENABLE REALTIME FOR TABLES
-- =============================================================================

-- Enable realtime for messages table (for live chat)
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Enable realtime for matches table (for match status updates)
ALTER PUBLICATION supabase_realtime ADD TABLE matches;

-- Enable realtime for active_shakers (optional, for UI updates during matching)
ALTER PUBLICATION supabase_realtime ADD TABLE active_shakers;

-- =============================================================================
-- NOTES ON REALTIME USAGE
-- =============================================================================
-- 
-- In Flutter, subscribe to messages like this:
-- 
-- final channel = supabase
--   .channel('messages:match_id=eq.$matchId')
--   .onPostgresChanges(
--     event: PostgresChangeEvent.insert,
--     schema: 'public',
--     table: 'messages',
--     filter: PostgresChangeFilter(
--       type: PostgresChangeFilterType.eq,
--       column: 'match_id',
--       value: matchId,
--     ),
--     callback: (payload) {
--       // Handle new message
--     },
--   )
--   .subscribe();
--
-- For match status updates:
--
-- final channel = supabase
--   .channel('matches:id=eq.$matchId')
--   .onPostgresChanges(
--     event: PostgresChangeEvent.update,
--     schema: 'public',
--     table: 'matches',
--     filter: PostgresChangeFilter(
--       type: PostgresChangeFilterType.eq,
--       column: 'id',
--       value: matchId,
--     ),
--     callback: (payload) {
--       // Handle match status change (revealed, archived, etc.)
--     },
--   )
--   .subscribe();
-- =============================================================================
