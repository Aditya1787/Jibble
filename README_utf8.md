# Jibble

Jibble is a cross-platform social networking application built with Flutter and Supabase. It allows users to connect, share content, join groups, and match based on shared skills and interests.

## 🚀 Features

### 👤 User Profiles & Social Graph
- **Customizable Profiles**: Users can update their Profile Picture, Username, and Bio.
- **Follow System**: Ability to Follow/Unfollow users and view Follower/Following lists.
- **Settings & Management**: Comprehensive drawer menu for account management, categories, skills matching, and logout.

### 📱 Content & Feed
- **Home Feed**: Instagram-style post grid and scrollable feed showing content from followed users and relevant circles.
- **Content Types**:
  - **Standard Posts**: Text + Images (up to 5MB).
  - **Reels**: Short-form video content.
  - **Events**: Date/time specific postings.
  - **Confessions**: Anonymous posts.
- **Bottom Navigation Bar**: Quick access to Home, Search, Upload, Reels, and Chat.
- **Skills Matching**: Targeted feed or recommendation engine connecting users with complementary skills.

### 💬 Real-Time Chat & Groups
- **Direct Messaging (1-to-1)**: Real-time private text interactions.
- **Group Chats**:
  - Ability to create groups, set group names, and upload group icons.
  - Role management (Owner, Members).
  - Features to transfer ownership, add/remove members, and exit groups.
- **Chat UI**: A tabbed interface cleanly separating DMs and Group Chats.

### 🔍 Search & Discovery
- **User Search**: Dynamic search page to find other users, displaying their info and a "Follow" button.
- **Explore**: Content discovery based on categories, topics, and subtopics.

### 🔐 Admin & Moderation
- **Admin Forms**: Web-based (or in-app gated) forms to manage topics, subtopics, content, and dynamic questions.
- **UI Behaviour**: Admin modals hide the main navbar when open to reduce clutter and improve form alignment/UX.

## 🛠️ Tech Stack

- **Frontend App**: Flutter, Dart
- **Backend/BaaS**: Supabase (Authentication, PostgreSQL Database, Real-time sub, Storage)
- **State Management**: Provider / Riverpod / Bloc (as dictated by codebase standards)
- **Design Assets**: Lottie (Animations), Google Fonts

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version specified in `pubspec.yaml`)
- Dart SDK (version specified in `pubspec.yaml`)
- Supabase Account (for backend services)

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd Application
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Supabase:
   - Create a Supabase project at [supabase.com](https://supabase.com).
   - Copy your Supabase project URL and anon key to the Flutter app configuration.
   - Run database migrations to set up tables and RLS policies.

### Running the App
```bash
flutter run
```

## 📂 Project Structure

```
Application/
├── lib/
│   ├── main.dart                # App entry point
│   ├── core/                    # Core utilities, constants, and services
│   ├── data/                    # Data layer (repositories, models)
│   ├── domain/                  # Business logic layer
│   ├── presentation/            # UI layer (screens, widgets, providers)
│   └── utils/                   # Utility functions and helpers
├── assets/                      # Static assets (images, lottie files)
├── test/                        # Unit and widget tests
├── pubspec.yaml                 # Project dependencies and metadata
└── README.md                    # Project documentation
```

## 📝 Development Guidelines

### Coding Standards
- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide.
- Use `const` constructors where possible for performance.
- Keep widgets small and focused.
- Use descriptive variable and function names.

### State Management
- [Provider/Riverpod/Bloc] - Choose the appropriate state management solution for the feature.

### Database & Supabase
- Use Supabase client for all database operations.
- Implement Row Level Security (RLS) policies for all tables.
- Use Supabase Storage for file uploads (images, videos).
- Leverage Supabase Realtime for real-time features (chat, notifications).

### Performance
- Implement local image caching to reduce network calls.
- Use optimized widget rebuilds (e.g., `const` widgets, `Selector`, `BlocBuilder`).
- Debounce API calls where appropriate.

## 🧪 Testing

Run tests using:
```bash
flutter test
```

## 🤝 Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## 📄 License

[License Name] - See the [LICENSE](LICENSE) file for details.
