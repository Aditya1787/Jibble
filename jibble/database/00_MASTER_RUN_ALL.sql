-- ============================================================
-- MASTER SCHEMA — Run ALL tables in one go
-- ============================================================
-- This file combines all schemas in the correct order.
-- Safe to run multiple times (uses IF NOT EXISTS / OR REPLACE).
-- Run in: Supabase Dashboard → SQL Editor → New Query → Run
-- ============================================================


-- ===========================================================
-- 01. PROFILES
-- ===========================================================

CREATE TABLE IF NOT EXISTS profiles (
    id                  UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email               TEXT,
    username            TEXT        UNIQUE NOT NULL,
    name                TEXT,
    bio                 TEXT        CHECK (char_length(bio) <= 160),
    date_of_birth       DATE,
    college_name        TEXT,
    profile_picture_url TEXT,
    profile_completed   BOOLEAN     DEFAULT FALSE,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_username       ON profiles (username);
CREATE INDEX IF NOT EXISTS idx_profiles_username_lower ON profiles (lower(username));
CREATE INDEX IF NOT EXISTS idx_profiles_college_name   ON profiles (college_name);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='profiles' AND policyname='Profiles are publicly viewable') THEN
    CREATE POLICY "Profiles are publicly viewable" ON profiles FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='profiles' AND policyname='Users can insert their own profile') THEN
    CREATE POLICY "Users can insert their own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='profiles' AND policyname='Users can update their own profile') THEN
    CREATE POLICY "Users can update their own profile" ON profiles FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='profiles' AND policyname='Users can delete their own profile') THEN
    CREATE POLICY "Users can delete their own profile" ON profiles FOR DELETE USING (auth.uid() = id);
  END IF;
END $$;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_profiles_updated_at ON profiles;
CREATE TRIGGER trigger_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ===========================================================
-- 02. FOLLOWS
-- ===========================================================

CREATE TABLE IF NOT EXISTS follows (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id  UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    following_id UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_follow  UNIQUE (follower_id, following_id),
    CONSTRAINT no_self_follow CHECK  (follower_id != following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_following_id      ON follows (following_id);
CREATE INDEX IF NOT EXISTS idx_follows_follower_id       ON follows (follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_follower_following ON follows (follower_id, following_id);

ALTER TABLE follows ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='follows' AND policyname='Follows are viewable by authenticated users') THEN
    CREATE POLICY "Follows are viewable by authenticated users" ON follows FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='follows' AND policyname='Users can follow others') THEN
    CREATE POLICY "Users can follow others" ON follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='follows' AND policyname='Users can unfollow') THEN
    CREATE POLICY "Users can unfollow" ON follows FOR DELETE USING (auth.uid() = follower_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='follows' AND policyname='Users can remove followers') THEN
    CREATE POLICY "Users can remove followers" ON follows FOR DELETE USING (auth.uid() = following_id);
  END IF;
END $$;


-- ===========================================================
-- 03. CONVERSATIONS
-- ===========================================================

CREATE TABLE IF NOT EXISTS conversations (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id        UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    user2_id        UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    last_message    TEXT,
    last_message_at TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT user_order          CHECK  (user1_id < user2_id),
    CONSTRAINT unique_conversation UNIQUE (user1_id, user2_id)
);

CREATE INDEX IF NOT EXISTS idx_conversations_user1           ON conversations (user1_id);
CREATE INDEX IF NOT EXISTS idx_conversations_user2           ON conversations (user2_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON conversations (last_message_at DESC);

ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='conversations' AND policyname='Users can view their own conversations') THEN
    CREATE POLICY "Users can view their own conversations" ON conversations FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='conversations' AND policyname='Users can create conversations') THEN
    CREATE POLICY "Users can create conversations" ON conversations FOR INSERT WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='conversations' AND policyname='Users can update their own conversations') THEN
    CREATE POLICY "Users can update their own conversations" ON conversations FOR UPDATE USING (auth.uid() = user1_id OR auth.uid() = user2_id);
  END IF;
END $$;


-- ===========================================================
-- 04. MESSAGES
-- ===========================================================

CREATE TABLE IF NOT EXISTS messages (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID        NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id       UUID        NOT NULL REFERENCES profiles(id)      ON DELETE CASCADE,
    content         TEXT        NOT NULL,
    is_read         BOOLEAN     DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages (conversation_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages (conversation_id, sender_id, is_read) WHERE is_read = FALSE;

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='messages' AND policyname='Users can view messages from their conversations') THEN
    CREATE POLICY "Users can view messages from their conversations" ON messages FOR SELECT
      USING (EXISTS (SELECT 1 FROM conversations WHERE conversations.id = messages.conversation_id AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='messages' AND policyname='Users can send messages to their conversations') THEN
    CREATE POLICY "Users can send messages to their conversations" ON messages FOR INSERT
      WITH CHECK (auth.uid() = sender_id AND EXISTS (SELECT 1 FROM conversations WHERE conversations.id = messages.conversation_id AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='messages' AND policyname='Users can update messages in their conversations') THEN
    CREATE POLICY "Users can update messages in their conversations" ON messages FOR UPDATE
      USING (EXISTS (SELECT 1 FROM conversations WHERE conversations.id = messages.conversation_id AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())));
  END IF;
END $$;


-- ===========================================================
-- 05. TRIGGER: Auto-update conversation last_message
-- ===========================================================

CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET last_message = NEW.content, last_message_at = NEW.created_at
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_update_conversation_last_message ON messages;
CREATE TRIGGER trigger_update_conversation_last_message
    AFTER INSERT ON messages
    FOR EACH ROW EXECUTE FUNCTION update_conversation_last_message();


-- ===========================================================
-- 06. REALTIME (enable for live chat)
-- ===========================================================
-- If this fails, go to: Database → Replication → messages → toggle ON
ALTER PUBLICATION supabase_realtime ADD TABLE messages;


-- ===========================================================
-- STORAGE: profile-pictures bucket
-- ===========================================================
-- Create the bucket manually first:
--   Storage → New Bucket → Name: profile-pictures → Public: ON
-- Then run these policies:

CREATE POLICY IF NOT EXISTS "Public profile pictures viewable by everyone"
    ON storage.objects FOR SELECT USING (bucket_id = 'profile-pictures');

CREATE POLICY IF NOT EXISTS "Users can upload their own profile picture"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'profile-pictures' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY IF NOT EXISTS "Users can update their own profile picture"
    ON storage.objects FOR UPDATE
    USING (bucket_id = 'profile-pictures' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY IF NOT EXISTS "Users can delete their own profile picture"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'profile-pictures' AND auth.uid()::text = (storage.foldername(name))[1]);


-- ===========================================================
-- VERIFICATION
-- ===========================================================

SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('profiles', 'follows', 'conversations', 'messages')
ORDER BY table_name;

SELECT tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'follows', 'conversations', 'messages')
ORDER BY tablename;

SELECT column_name, data_type FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'profiles'
ORDER BY ordinal_position;
