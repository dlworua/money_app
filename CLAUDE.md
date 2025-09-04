# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
```bash
flutter run                    # Hot reload development
flutter run --release         # Production build testing
flutter analyze               # Static analysis with flutter_lints
flutter test                   # Run tests (needs custom setup for AdMob integration)
```

### Code Generation (for future modular architecture)
```bash
dart run build_runner build   # Generate freezed/json models
dart run build_runner watch   # Watch mode for development
```

### Build Commands
```bash
flutter build apk             # Android APK
flutter build ios             # iOS build
```

## Architecture

This is a **revenue-generating Flutter app** using MVVM pattern with Riverpod state management and Google AdMob integration.

### Current State: Transitional Architecture
- **Monolithic Phase**: All code consolidated in `lib/main.dart` (420 lines) for rapid prototyping
- **Modular Files Ready**: Separate architecture files exist but are commented out
- **Migration Path**: Moving from monolithic to clean MVVM structure

### Key Components

**Data Layer**:
- `UserModel`: User data with coins, premium status, ad cooldowns
- `UserRepository`: SharedPreferences-based local persistence  
- Ad integration through Google Mobile Ads (banner, interstitial, rewarded)

**Business Logic**:
- `HomeViewModel`: StateNotifier managing app state
- `HomeState`: Immutable state with user/loading/ad states
- Riverpod providers for dependency injection

**Presentation**:
- `HomeView`: ConsumerWidget with reactive UI updates
- Material Design 3 theming

### Monetization Features
- **Rewarded ads**: 50 coins per view (1-hour cooldown)
- **Interstitial ads**: 10 coins on completion
- **Banner ads**: Persistent bottom placement
- **Premium subscription**: Ad-free experience (payment integration pending)
- **Daily rewards**: 100 coins per day check-in

### State Management Flow
1. `HomeViewModel` initializes user data and ads on startup
2. Riverpod providers automatically trigger UI updates
3. Ad repository pattern handles loading/showing ads
4. SharedPreferences provides offline-first persistence

### Development Notes
- **Test Ad IDs**: Currently using Google's test ad units - need production IDs for release
- **Primary Development**: Edit `main.dart` for most changes during prototype phase
- **Future Migration**: Uncomment modular files when ready to scale
- **AdMob Testing**: Requires physical devices for proper ad testing
- **Code Generation**: Freezed/json_serializable ready but not active until modular transition