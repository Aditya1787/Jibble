-- Database Indexing for Performance
-- These indexes will vastly speed up queries on posts and likes

-- 1. Index on posts user_id
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts (user_id);

-- 2. Index on posts type (for standard vs event vs confession lookups)
CREATE INDEX IF NOT EXISTS idx_posts_type ON posts (type);

-- 3. Index on posts created_at for ordering home feeds and circle feeds
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts (created_at DESC);

-- 4. Index on post_likes (post_id, user_id) for faster checking if a user liked a post
-- Note: It already has a primary key so an implicit index exists, 
-- but ensuring explicit index on post_id if queried separately is helpful.
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON post_likes (post_id);

-- 5. Index on post_comments post_id
CREATE INDEX IF NOT EXISTS idx_post_comments_post_id ON post_comments (post_id);
