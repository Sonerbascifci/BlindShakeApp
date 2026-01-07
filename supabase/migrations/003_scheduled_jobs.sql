-- BlindShake Supabase Scheduled Jobs
-- Migration: 003_scheduled_jobs.sql
-- Description: pg_cron scheduled jobs for cleanup tasks (replaces Firebase Cloud Functions scheduled triggers)

-- Enable pg_cron extension for scheduled jobs
-- Note: This must be enabled by Supabase dashboard or via SQL Editor with superuser
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- =============================================================================
-- CLEANUP EXPIRED SHAKERS
-- Runs every minute to remove stale shakers (replaces cleanupStaleShakers)
-- =============================================================================
SELECT cron.schedule(
  'cleanup-expired-shakers',
  '* * * * *', -- Every minute
  $$
    DELETE FROM active_shakers 
    WHERE expires_at < NOW()
  $$
);

-- =============================================================================
-- AUTO-ARCHIVE EXPIRED MATCHES
-- Runs every 5 minutes (replaces autoArchiveExpiredMatches)
-- Archives matches where anonymous phase ended 24+ hours ago with no reveal request
-- =============================================================================
SELECT cron.schedule(
  'auto-archive-matches',
  '*/5 * * * *', -- Every 5 minutes
  $$
    WITH archived AS (
      UPDATE matches 
      SET 
        status = 'archived', 
        archived_at = NOW(), 
        archived_reason = 'auto_expired',
        updated_at = NOW()
      WHERE 
        status = 'anonymous' 
        AND anonymous_phase_ends < NOW() - INTERVAL '24 hours'
        AND reveal_requested_by IS NULL
      RETURNING id, participants
    )
    INSERT INTO messages (match_id, sender_id, content, type)
    SELECT 
      id, 
      'system', 
      'This chat has been automatically archived after 24 hours of inactivity.',
      'system'
    FROM archived
  $$
);

-- =============================================================================
-- CLEANUP OLD ARCHIVED DATA
-- Runs daily to remove old archived matches (replaces cleanupOldData)
-- Deletes matches archived more than 30 days ago
-- =============================================================================
SELECT cron.schedule(
  'cleanup-old-data',
  '0 0 * * *', -- Daily at midnight
  $$
    DELETE FROM matches 
    WHERE 
      status = 'archived' 
      AND archived_at < NOW() - INTERVAL '30 days'
  $$
);

-- =============================================================================
-- UPDATE USER STATISTICS
-- Runs daily to recalculate user match statistics (replaces updateUserStats)
-- =============================================================================
SELECT cron.schedule(
  'update-user-stats',
  '0 1 * * *', -- Daily at 1 AM
  $$
    UPDATE users u
    SET 
      stats = jsonb_build_object(
        'totalMatches', COALESCE(stats_data.total, 0),
        'revealedMatches', COALESCE(stats_data.revealed, 0),
        'archivedMatches', COALESCE(stats_data.archived, 0)
      ),
      stats_updated_at = NOW()
    FROM (
      SELECT 
        unnest(m.participants) AS user_id,
        COUNT(*) AS total,
        COUNT(*) FILTER (WHERE m.status = 'revealed') AS revealed,
        COUNT(*) FILTER (WHERE m.status = 'archived') AS archived
      FROM matches m
      GROUP BY unnest(m.participants)
    ) AS stats_data
    WHERE u.id = stats_data.user_id
  $$
);

-- =============================================================================
-- HELPER: View scheduled jobs (for debugging)
-- =============================================================================
-- SELECT * FROM cron.job;

-- =============================================================================
-- HELPER: Unschedule jobs (if needed)
-- =============================================================================
-- SELECT cron.unschedule('cleanup-expired-shakers');
-- SELECT cron.unschedule('auto-archive-matches');
-- SELECT cron.unschedule('cleanup-old-data');
-- SELECT cron.unschedule('update-user-stats');
