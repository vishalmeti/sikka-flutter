# Sikka Flutter App

## Stack
- Flutter 3.27+ / Dart 3.6+
- Custom icon system (CustomPainter, no icon packs)
- Google Fonts: Space Grotesk (numbers/headers), Inter (body)
- go_router for navigation
- provider for state management (planned)

## Architecture
```
lib/
  core/               # App-wide configuration
    theme/             # AppColors, AppTypography, AppTheme
    constants/         # AppConstants (coin rates, radii, grid)
    utils/             # Formatters (Indian number format, rupee)
  features/            # Feature modules (screens + widgets)
    onboarding/        # Welcome, Login, Register screens
    customer/          # Home, Scan, Wallet, Redeem, You (profile)
    owner/             # Dashboard, Create Offer
  shared/              # Cross-feature code
    widgets/           # Design system widgets (Sk* prefix)
    navigation/        # Router, CustomerShell (tab nav)
    models/            # Shared data models (planned)
```

## Design System
- All colors in `AppColors` — exact tokens from design spec
- Widgets prefixed `Sk`: SkCard, SkButton, SkLabel, SkBigNumber, SkPill, SkAvatar, SkTierRing, SkBottomNav, SkTopBar, SkIcon
- Icons: custom `SkIcon` widget with `SkIconData` enum, drawn via `CustomPainter` (24×24 viewBox, 1.6px stroke)
- Max border radius: 16px on surfaces, 14px on buttons, 999px on pills
- Dark mode only: bg #0A0A0F, surface #13131A
- Gold (#C9A84C) for coins, teal (#4C9A84) for rupees, coral (#FF5C3A) for streaks

## Commands
- `flutter pub get` — install dependencies
- `flutter run` — run on connected device/emulator
- `flutter analyze` — static analysis
- `flutter test` — run tests

## Routes
- `/welcome` → Welcome screen (role selection)
- `/login` → Username + password sign in
- `/register` → Username + password sign up
- `/customer` → Customer tab shell (Home, Wallet, You + Scan modal)
- `/redeem` → Redeem screen
- `/owner` → Owner dashboard
- `/create-offer` → Create offer form
