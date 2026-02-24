# Product Requirements Document (PRD)

## 1. Product Overview
**Product Name:** Jibble  
**Platform:** Cross-platform Mobile Application (iOS & Android) built with Flutter  
**Backend:** Supabase (Authentication, PostgreSQL Database, Real-time sub, Storage)  
**Objective:** To build a high-performance, engaging social media and community platform that allows users to connect, share content, join groups, message in real-time, and match based on shared skills/interests.

## 2. Target Audience
- Individuals looking for a modern, feature-rich social networking experience.
- Communities, students, and professionals interested in skill-matching, group discussions, and content sharing (events, anonymous confessions, standard posts, and reels).

## 3. Key Scenarios & Use Cases
1. **User Onboarding:** A new user downloads the app, goes through a smooth splash screen with Lottie animations, and signs up with a unique username.
2. **Content Browsing & Interaction:** A user opens the app to the Home feed, sees an Instagram-style grid of posts, likes/comments on them, and uses the bottom navigation bar to switch between Home, Search, Upload, Reels, and Chat.
3. **Content Creation:** A user taps "Upload", selects "Post", attaches an image (under 5MB), and publishes it. Alternatively, they post an anonymous confession or an event to a specific "circle".
4. **Networking:** A user searches for a peer, views their profile (bio, profile picture, posts), and taps "Follow".
5. **Messaging:** A user opens the Chat tab, creates a new Group Chat, adds friends, sets a group icon, and starts exchanging real-time messages.
6. **Administration:** An admin logs into the web/admin portal to manage topics, subtopics, questions, and reports to maintain community guidelines.

## 4. Feature Requirements

### 4.1. Authentication & Onboarding
- **User Registration/Login:** Secure email/password or OAuth login via Supabase Auth.
- **Unique Usernames:** Logic to ensure usernames are globally unique at registration.
- **Splash Screen:** Engaging custom splash screen featuring Lottie animations.

### 4.2. User Profiles & Social Graph
- **Customizable Profiles:** Users can update their Profile Picture, Username, and Bio.
- **Settings & Management:** Drawer menu handling Account Information, Categories, Skills Matching, and Logout configuration.
- **Follow System:** Ability to Follow/Unfollow users, view Follower/Following lists.

### 4.3. Content & Feed (Home)
- **Home Feed:** Instagram-style post grid and scrollable feed showing content from followed users and relevant circles.
- **Content Types:** 
  - Standard Posts (Text + Images up to 5MB)
  - Reels (Short-form video content)
  - Events (Date/time specific postings)
  - Confessions (Anonymous posts)
- **Bottom Navigation Bar:** Quick access to Home, Search, Upload, Reels, and Chat.
- **Skills Matching:** A targeted feed or recommendation engine connecting users with complementary skills.

### 4.4. Real-Time Chat & Groups
- **Direct Messaging (1-to-1):** Real-time private text interactions.
- **Group Chats:** 
  - Ability to create groups, set group names, and upload group icons.
  - Role management (Owner, Members).
  - Features to transfer ownership, add/remove members, and exit groups.
- **Chat UI:** A tabbed interface cleanly separating DMs and Group Chats.

### 4.5. Search & Discovery
- **User Search:** Dynamic search page to find other users, displaying their info and a "Follow" button.
- **Explore:** Content discovery based on categories, topics, and subtopics.

### 4.6. Admin & Moderation
- **Admin Forms:** Web-based (or in-app gated) forms to manage topics, subtopics, content, and dynamic questions.
- **UI Behaviour:** Admin modals hide the main navbar when open to reduce clutter and improve form alignment/UX.

## 5. Non-Functional Requirements (NFR)

### 5.1. Performance
- **Image Caching:** Implement local image caching to reduce network calls and speed up feed rendering.
- **Optimized UI:** Extensive use of `const` widgets and optimized widget rebuilds to ensure 60fps scrolling.
- **Network Efficiency:** Debounced API calls and optimized query structures using Supabase.

### 5.2. Security & Data Integrity
- **Supabase RLS (Row Level Security):** Strict policies ensuring users can only edit/delete their own posts and that `post_images` storage buckets are secure from unauthorized uploads/modifications.
- **File Validation:** Enforce global 5MB limits on image uploads to prevent storage bloat.

### 5.3. Design & UX/UI
- **Brand Identity:** Premium, modern aesthetics featuring the app name "Jibble" in "Dancing Script" font.
- **Color Consistency:** Cohesive color palettes across screens with soft shadows and rounded corners (comparable to modern social platforms).

## 6. Future Scope & Roadmap
- Implement advanced video rendering for Reels.
- Add voice notes and media sharing within Chat.
- Introduce advanced group matching and personalized event recommendations based on user skills.
- Push Notifications for likes, comments, and messages.

## 7. Tech Stack Overview
- **Frontend App:** Flutter, Dart
- **Backend/BaaS:** Supabase (Database, Auth, Storage, Edge Functions if needed)
- **State Management:** Provider / Riverpod / Bloc (as dictated by codebase standards)
- **Design Assets:** Lottie (Animations), Google Fonts
