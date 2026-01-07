-- BlindShake Supabase Row Level Security Policies
-- Migration: 002_rls_policies.sql
-- Description: Enable RLS and create access policies for all tables

-- =============================================================================
-- ENABLE ROW LEVEL SECURITY
-- =============================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE active_shakers ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- USERS POLICIES
-- =============================================================================

-- Users can view their own profile
CREATE POLICY "users_select_own" ON users
  FOR SELECT 
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "users_update_own" ON users
  FOR UPDATE 
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Users can insert their own profile (handled by trigger, but allow manual)
CREATE POLICY "users_insert_own" ON users
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

-- Users can view other users' basic info (for revealed matches)
CREATE POLICY "users_select_revealed_participants" ON users
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM matches m
      WHERE m.status = 'revealed'
      AND auth.uid() = ANY(m.participants)
      AND users.id = ANY(m.participants)
    )
  );

-- =============================================================================
-- MATCHES POLICIES
-- =============================================================================

-- Participants can view their own matches
CREATE POLICY "matches_select_participant" ON matches
  FOR SELECT 
  USING (auth.uid() = ANY(participants));

-- Matches are created by Edge Functions (service role), not directly by clients
-- But we allow updates from participants for reveal/decline
CREATE POLICY "matches_update_participant" ON matches
  FOR UPDATE 
  USING (auth.uid() = ANY(participants))
  WITH CHECK (auth.uid() = ANY(participants));

-- =============================================================================
-- MESSAGES POLICIES
-- =============================================================================

-- Participants can view messages in their matches
CREATE POLICY "messages_select_participant" ON messages
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM matches m
      WHERE m.id = messages.match_id
      AND auth.uid() = ANY(m.participants)
    )
  );

-- Participants can insert messages in active (non-archived) matches
CREATE POLICY "messages_insert_participant" ON messages
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM matches m
      WHERE m.id = match_id
      AND auth.uid() = ANY(m.participants)
      AND m.status != 'archived'
    )
    AND (sender_id = auth.uid()::text OR sender_id = 'system')
  );

-- =============================================================================
-- ACTIVE SHAKERS POLICIES
-- =============================================================================

-- Users can view all active shakers (needed for matching display)
CREATE POLICY "active_shakers_select_authenticated" ON active_shakers
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Users can only insert/update their own shaker entry
CREATE POLICY "active_shakers_insert_own" ON active_shakers
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "active_shakers_update_own" ON active_shakers
  FOR UPDATE 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own shaker entry
CREATE POLICY "active_shakers_delete_own" ON active_shakers
  FOR DELETE 
  USING (auth.uid() = user_id);

-- =============================================================================
-- SERVICE ROLE BYPASS
-- Note: Service role (used by Edge Functions) automatically bypasses RLS
-- This ensures Edge Functions can perform any operation needed
-- =============================================================================
