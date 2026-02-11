# Enhanced Splash Screen

This folder contains the enhanced splash screen implementation for the Jibble app.

## Features

✨ **Lottie Animation**: Beautiful handshake loop animation from `assets/Loffie Animations/Handshake Loop.json`

🎨 **Gradient Background**: Multi-color blue gradient for a premium look
- Deep blue (#1E3A8A)
- Bright blue (#3B82F6)
- Light blue (#60A5FA)
- Very light blue (#93C5FD)

📝 **Animated Text Elements**:
- App name "Jibble" with shader mask effect
- Tagline: "Connect. Collaborate. Celebrate."
- Subtitle: "Your campus community awaits"
- Loading indicator with text

🎭 **Smooth Animations**:
- Fade-in animation for text (1200ms)
- Slide-up animation for text (1000ms)
- Page transition to AuthGate (800ms fade)

⏱️ **Auto-Navigation**: Automatically navigates to AuthGate after 4 seconds

## File Structure

```
lib/screens/splash/
├── splash_screen.dart    # Main enhanced splash screen widget
└── README.md            # This documentation file
```

## Usage

The splash screen is automatically shown on first app launch. It's integrated in `main.dart`:

```dart
import 'screens/splash/splash_screen.dart';

// In MyApp widget
home: FutureBuilder<bool>(
  future: FirstLaunchService().isFirstLaunch(),
  builder: (context, snapshot) {
    final isFirstLaunch = snapshot.data ?? false;
    return isFirstLaunch ? const EnhancedSplashScreen() : const AuthGate();
  },
),
```

## Dependencies

- `lottie: ^3.2.1` - For Lottie animations
- `google_fonts: ^8.0.1` - For Poppins font family

## Customization

You can customize the splash screen by modifying:

1. **Animation Duration**: Change the delay in `_navigateToAuth()` method
2. **Colors**: Modify the gradient colors in the `Container` decoration
3. **Text Content**: Update the text strings in the build method
4. **Animation**: Replace the Lottie file path with a different animation
