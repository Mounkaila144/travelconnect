# TravelConnect App

Application mobile TravelConnect, construite avec Flutter 3.16+ et Clean Architecture avec BLoC.

## Prerequisites

- **Flutter** 3.16+
- **Dart** 3.2+
- **Android Studio** or **Xcode** (for emulators)

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd travelconnect-app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment

Create a `.env` file at the project root:

```bash
cp .env.example .env
```

Edit `.env` with your values:

```
API_BASE_URL=http://localhost:8000/api/v1
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### 4. Run the application

```bash
# Android
flutter run

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `API_BASE_URL` | Backend API base URL |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key for map features |

## Project Architecture

This project follows **Clean Architecture** with **BLoC** pattern for state management.

```
lib/
├── main.dart           # Entry point
├── app.dart            # App widget configuration
├── injection.dart      # Dependency injection (GetIt)
├── core/
│   ├── api/            # API client configuration (Dio)
│   ├── constants/      # App-wide constants
│   ├── error/          # Error handling & failures
│   ├── theme/          # Material Design 3 theme
│   ├── utils/          # Utility functions
│   └── widgets/        # Shared widgets
├── features/
│   ├── auth/           # Authentication feature
│   ├── map/            # Map & location feature
│   ├── questions/      # Q&A feature
│   ├── profile/        # User profile feature
│   └── notifications/  # Push notifications feature
└── routes/             # App routing (GoRouter)
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (BLoC pattern) |
| `dio` | HTTP client for API calls |
| `get_it` | Dependency injection |
| `equatable` | Value equality for BLoC states/events |
| `go_router` | Declarative routing |

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/example_test.dart
```

### Test Structure

```
test/
├── unit/           # Unit tests (services, repositories, blocs)
├── widget/         # Widget tests (UI components)
└── integration/    # Integration tests (full flows)
```
