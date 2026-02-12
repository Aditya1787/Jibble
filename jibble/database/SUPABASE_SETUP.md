# Supabase Dashboard Setup Guide

Follow these exact steps to configure your Supabase project for the chat system.

## 1. Run the Database Script
This step creates the required tables (`conversations`, `messages`) and sets up security policies.

1.  Open the file `database/chat_schema.sql` in your project folder.
2.  **Copy** the entire content of the file.
3.  Go to your **Supabase Dashboard** and click on the **SQL Editor** icon (`>_` in the sidebar).
4.  Click **New Query**.
5.  **Paste** the code you copied.
6.  Click **Run** (bottom right).
    *   *You should see a success message.*

## 2. Enable Real-Time Messages
This step ensures messages appear instantly in the chat without refreshing.

1.  Go to **Database** → **Replication** in the left sidebar.
2.  Find the `messages` table in the list.
3.  Toggle the switch to **ON** (labeled "Source" or "Insert").

## 3. Verify Setup
1.  Go to the **Table Editor** (grid icon in the sidebar).
2.  Verify that `conversations` and `messages` tables now exist.
3.  Check that they have "RLS Enabled" badges.

## Troubleshooting
- **If the SQL script fails**: Ensure you already have a `profiles` table in your database, as the chat system links to it.
- **If messages don't appear instantly**: Double-check that Realtime is enabled for the `messages` table as described in Step 2.

Once these steps are done, restart your app to ensure everything connects properly!
