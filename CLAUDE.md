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
- **Modular Architecture**: Fully migrated from monolithic to MVVM + Riverpod structure
- **AdMob Testing**: Requires physical devices for proper ad testing
- **Code Generation**: Freezed/json_serializable ready for future use

## 🔥 CRITICAL Development Rules

### 1. Git Workflow (MANDATORY)
```bash
# 작은 단위로 바로바로 커밋하기
git add .
git commit -m "feat: 간결하고 명확한 커밋 메시지"
# AI 생성 문구는 반드시 제거할 것
```

### 2. Documentation Updates (MANDATORY)
- **커밋 후 즉시**: PROGRESS.md 파일 업데이트 필수
- 진행상황을 실시간으로 반영

### 3. Code Quality Standards (MANDATORY)
- **중복 코드 금지**: DRY 원칙 엄격히 준수
- **UI 컴포넌트화**: 복잡한 코드 방지, 재사용성 극대화
- **주석 필수**: 모든 코드에 설명 주석 작성

### 4. Architecture Compliance (MANDATORY)
- **MVVM + Riverpod**: 구조 절대 엇나가지 않기
- **레이어 분리**: Data → Domain → Presentation 순서 준수
- **Provider 패턴**: 모든 상태는 Riverpod으로 관리

### 5. Cross-Platform Compatibility (MANDATORY)
- **Android + iOS**: 모든 기능이 양쪽 플랫폼에서 완벽 동작
- **반응형 디자인**: ResponsiveUtils 활용
- **Safe Area**: SafeAreaUtils로 안전 영역 처리

### 6. Current Project Status
- **완성도**: 85% (MVP 출시 가능 수준)
- **주요 완료**: 가계부, 게임 시스템, AI 코칭, 포인트 시스템
- **개선 필요**: 광고 프로덕션 ID, 결제 시스템, 예산 관리 UI