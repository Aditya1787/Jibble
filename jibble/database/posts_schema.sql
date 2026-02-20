-- ============================================
-- Posts, Events & Confessions System
-- ============================================

-- 1. CREATE TABLES

-- Posts table
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE, -- Nullable for absolute anonymity
    type TEXT NOT NULL CHECK (type IN ('standard', 'event', 'confession')),
    caption TEXT,
    image_url TEXT,
    college_name TEXT, -- Used for Circle scope
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Post Likes table
CREATE TABLE IF NOT EXISTS post_likes (
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (post_id, user_id)
);

-- Post Comments table
CREATE TABLE IF NOT EXISTS post_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ENABLE ROW LEVEL SECURITY

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;

-- 3. RLS POLICIES

-- Posts
-- Public 'standard' posts are visible to everyone
CREATE POLICY "Public posts are visible to everyone" ON posts
    FOR SELECT USING (type = 'standard');

-- 'event' and 'confession' posts are visible to members of the same college circle
CREATE POLICY "Circle posts are visible to circle members" ON posts
    FOR SELECT USING (
        type IN ('event', 'confession') AND
        college_name = (SELECT p.college_name FROM profiles p WHERE p.id = auth.uid())
    );

-- Users can insert posts
CREATE POLICY "Users can create posts" ON posts
    FOR INSERT WITH CHECK (
        (auth.uid() = user_id OR (type = 'confession' AND user_id IS NULL))
        AND
        (type = 'standard' OR college_name = (SELECT p.college_name FROM profiles p WHERE p.id = auth.uid()))
    );

-- Users can update their own posts
CREATE POLICY "Users can update their own posts" ON posts
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete their own posts" ON posts
    FOR DELETE USING (auth.uid() = user_id);

-- Likes
CREATE POLICY "Likes visible if post visible" ON post_likes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM posts WHERE posts.id = post_likes.post_id
        )
    );

CREATE POLICY "Users can like posts" ON post_likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike posts" ON post_likes
    FOR DELETE USING (auth.uid() = user_id);

-- Comments
CREATE POLICY "Comments visible if post visible" ON post_comments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM posts WHERE posts.id = post_comments.post_id
        )
    );

CREATE POLICY "Users can comment" ON post_comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments" ON post_comments
    FOR DELETE USING (auth.uid() = user_id);
