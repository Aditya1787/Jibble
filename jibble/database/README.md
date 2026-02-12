# Database Setup Instructions

## Chat System Database Setup

Follow these steps to set up the chat system database in Supabase:

### Step 1: Run the SQL Script

1. Go to your Supabase Dashboard: https://app.supabase.com
2. Select your project
3. Navigate to **SQL Editor** (in the left sidebar)
4. Click **New Query**
5. Copy the entire contents of `chat_schema.sql`
6. Paste it into the SQL Editor
7. Click **Run** (or press Ctrl+Enter)

### Step 2: Enable Realtime

1. In your Supabase Dashboard, navigate to **Database** → **Replication**
2. Find the `messages` table in the list
3. Toggle the switch to **enable** realtime for the `messages` table
4. This allows real-time message delivery in the chat

### Step 3: Verify Setup

1. Navigate to **Database** → **Tables**
2. Verify these tables exist:
   - `conversations`
   - `messages`
3. Click on each table and verify:
   - RLS is enabled (should show "RLS enabled" badge)
   - Policies are created (check the Policies tab)

### Troubleshooting

**If you get errors about missing `profiles` table:**
- The chat system requires the `profiles` table to exist
- Make sure you've already set up user profiles in your app

**If RLS policies fail:**
- Make sure you're running the script as the database owner
- Check that the `auth.uid()` function is available

**If realtime doesn't work:**
- Verify realtime is enabled for the `messages` table
- Check your Supabase project's realtime settings
- Ensure your Flutter app has the correct Supabase configuration

### Testing the Database

You can test the database by running these queries in the SQL Editor:

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('conversations', 'messages');

-- Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('conversations', 'messages');

-- Check policies exist
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('conversations', 'messages');
```

All queries should return results confirming the setup is complete.
