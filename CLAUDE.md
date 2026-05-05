# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run -d iPhone      # iOS simulator
flutter run -d android     # Android emulator

# Code analysis
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test

# Run single test file
flutter test test/path/to/test_file.dart

# Regenerate app icons (after modifying assets/icon/icon.png)
dart run flutter_launcher_icons
```

### Supabase Edge Function Deployment

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase secrets set OPENAI_API_KEY=your-key
supabase functions deploy analyze-receipt
```

## Architecture Overview

This is **카쎔 (CarSSEM)** - an AI-powered car maintenance management Flutter app. Users photograph maintenance receipts, GPT-4 Vision extracts the data, and the app stores maintenance records per vehicle.

### Tech Stack
- **Frontend**: Flutter (iOS/Android)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Serverless**: Supabase Edge Functions (Deno)
- **AI**: OpenAI GPT-4 Vision API
- **State Management**: Riverpod
- **Routing**: GoRouter

### Project Structure

```
lib/
├── core/
│   ├── constants/app_constants.dart  # Storage buckets, edge function names
│   ├── router/app_router.dart        # GoRouter with auth guards
│   ├── theme/                        # Material 3 theme
│   └── widgets/main_scaffold.dart    # Bottom nav wrapper
├── features/                         # Feature-first modules
│   ├── auth/screens/                 # Login, signup, splash
│   ├── car/screens/                  # Car list, car form
│   ├── home/screens/                 # Main dashboard
│   ├── maintenance/screens/          # Maintenance list/detail
│   ├── scan/screens/                 # Receipt scan, AI analysis result
│   ├── garage/screens/               # Repair shop management
│   └── profile/screens/              # User profile
├── models/                           # Data models with fromJson/toJson
├── providers/                        # Riverpod providers
├── services/                         # Business logic & Supabase API
└── main.dart
```

### State Management Pattern (Riverpod)

Services are wrapped in providers for dependency injection:
- `*ServiceProvider` → Service singleton
- `*Provider` → FutureProvider for data fetching
- `*NotifierProvider` → Handles mutations (create/update/delete)

Key providers:
- `authStateProvider` - Stream of Supabase auth state
- `carsProvider` - User's cars list
- `selectedCarIdProvider` / `selectedCarProvider` - Current car selection
- `maintenanceRecordsProvider` - Family provider parameterized by carId
- `scanNotifierProvider` - Receipt scan state (image, analysis result)

### Routing

GoRouter with auth redirect logic:
- Protected routes redirect to `/login` if unauthenticated
- Auth routes redirect to `/maintenance` if already authenticated
- ShellRoute wraps main tabs with `MainScaffold` (bottom navigation)

### Core Feature: Receipt Analysis Flow

1. `ScanScreen` captures image via camera/gallery
2. `ReceiptAnalysisService.analyzeReceipt()`:
   - Uploads image to `receipts` storage bucket
   - Invokes `analyze-receipt` Edge Function
   - Edge Function calls GPT-4 Vision API
   - Returns parsed `ReceiptAnalysisResult`
3. `AnalysisResultScreen` displays editable extracted data
4. User saves → creates `maintenance_record` + `maintenance_items`

### Database Tables

- `users` - User profiles
- `cars` - Vehicles (brand, model, year, license_plate, mileage)
- `maintenance_records` - Service history (car_id, garage_id, date, mileage, total_cost)
- `maintenance_items` - Line items (category, name, quantity, unit_price)
- `garages` - Repair shops
- `reviews` - Garage ratings

### Storage Buckets

- `receipts/` - Maintenance receipt images
- `cars/` - Car photos
- `profiles/` - User profile pictures

## Environment Setup

Create `.env` file:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Edge Function requires `OPENAI_API_KEY` secret in Supabase.
