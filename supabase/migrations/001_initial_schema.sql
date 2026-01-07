-- BlindShake Supabase Initial Schema
-- Migration: 001_initial_schema.sql
-- Description: Create core tables with PostGIS support for geospatial queries

-- Enable PostGIS for geospatial queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- =============================================================================
-- USERS TABLE
-- Stores user profiles, replaces Firebase Firestore 'users' collection
-- =============================================================================
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  email TEXT,
  photo_url TEXT,
  current_match_id UUID,
  last_match_at TIMESTAMPTZ,
  stats JSONB DEFAULT '{"totalMatches": 0, "revealedMatches": 0, "archivedMatches": 0}'::jsonb,
  stats_updated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- MATCHES TABLE
-- Stores match sessions between users with PostGIS geometry
-- Replaces Firebase Firestore 'matches' collection
-- =============================================================================
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participants UUID[] NOT NULL,
  status TEXT NOT NULL DEFAULT 'anonymous' CHECK (status IN ('anonymous', 'revealed', 'archived')),
  anonymous_phase_ends TIMESTAMPTZ NOT NULL,
  reveal_requested_by UUID REFERENCES users(id),
  revealed_at TIMESTAMPTZ,
  archived_at TIMESTAMPTZ,
  archived_reason TEXT CHECK (archived_reason IN ('reveal_declined', 'auto_expired', 'manual')),
  participant_info JSONB DEFAULT '{}'::jsonb,
  revealed_participant_info JSONB,
  last_message JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER update_matches_updated_at
  BEFORE UPDATE ON matches
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Indexes for matches
CREATE INDEX matches_status_idx ON matches(status);
CREATE INDEX matches_participants_idx ON matches USING GIN(participants);
CREATE INDEX matches_anonymous_phase_ends_idx ON matches(anonymous_phase_ends) WHERE status = 'anonymous';
CREATE INDEX matches_archived_at_idx ON matches(archived_at) WHERE status = 'archived';

-- =============================================================================
-- MESSAGES TABLE
-- Stores chat messages within matches
-- Replaces Firebase Firestore 'matches/{id}/messages' subcollection
-- =============================================================================
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  sender_id TEXT NOT NULL, -- 'system' or user UUID string
  content TEXT NOT NULL CHECK (char_length(content) <= 1000),
  type TEXT NOT NULL DEFAULT 'text' CHECK (type IN ('text', 'system', 'reveal_request')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for messages
CREATE INDEX messages_match_id_idx ON messages(match_id);
CREATE INDEX messages_created_at_idx ON messages(match_id, created_at);

-- =============================================================================
-- ACTIVE SHAKERS TABLE
-- Stores users currently "shaking" to find matches, with PostGIS location
-- Replaces Firebase Realtime Database 'active_shakers/{geohash}/{userId}'
-- =============================================================================
CREATE TABLE active_shakers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  location GEOGRAPHY(POINT, 4326) NOT NULL, -- PostGIS geography for accurate distance
  geohash TEXT NOT NULL, -- Kept for backwards compatibility / debugging
  display_name TEXT,
  photo_url TEXT,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id) -- One active shaker entry per user
);

-- Spatial index for proximity queries (most important!)
CREATE INDEX active_shakers_location_gist_idx ON active_shakers USING GIST(location);
CREATE INDEX active_shakers_geohash_idx ON active_shakers(geohash);
CREATE INDEX active_shakers_expires_idx ON active_shakers(expires_at);
CREATE INDEX active_shakers_user_idx ON active_shakers(user_id);

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

-- Function to find nearby shakers using PostGIS (replaces geohash-based search)
CREATE OR REPLACE FUNCTION find_nearby_shakers(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_meters DOUBLE PRECISION DEFAULT 1000000, -- 1000km default
  exclude_user_id UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  display_name TEXT,
  photo_url TEXT,
  distance_meters DOUBLE PRECISION,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.user_id,
    a.display_name,
    a.photo_url,
    ST_Distance(a.location, ST_MakePoint(lng, lat)::geography) AS distance_meters,
    a.created_at
  FROM active_shakers a
  WHERE 
    a.expires_at > NOW()
    AND (exclude_user_id IS NULL OR a.user_id != exclude_user_id)
    AND ST_DWithin(
      a.location, 
      ST_MakePoint(lng, lat)::geography, 
      radius_meters
    )
  ORDER BY distance_meters ASC, a.created_at ASC;
END;
$$ LANGUAGE plpgsql;

-- Function to create user profile on signup (called via trigger)
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO users (id, email, display_name, photo_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create user profile on auth signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
