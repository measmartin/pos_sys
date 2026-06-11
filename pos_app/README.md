# POS App - Flutter Frontend

A Flutter mobile/desktop frontend for the POS system.

## Features

- **Flutter** cross-platform (Android, iOS, Web, Desktop)
- **JWT Authentication** with login/register
- **API Key Fallback** for backward compatibility
- **Auto-logout** on 401 responses
- **Dashboard** with sales overview and charts
- **Product Management** with categories and units
- **Sales POS** with cart and checkout
- **Reports** with date range filtering
- **Customer Management**
- **Printer Support** for receipts

## Getting Started

### Prerequisites

- Flutter SDK 3.27+
- Android Studio / Xcode (for mobile)
- .NET backend running at `http://localhost:5010`

### Installation

```bash
cd pos_app
flutter pub get
```

### Configuration

The API base URL is configured in `lib/main.dart`:

- **Web**: `http://localhost:5010`
- **Android Emulator**: `http://10.0.2.2:5010`
- **iOS Simulator**: `http://localhost:5010`

You can also set via environment variable:
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:5010
```

### Running the Application

```bash
# For development
flutter run

# For Android emulator
flutter run -d emulator

# For iOS simulator
flutter run -d ios
```

### Building

```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Authentication

The app supports JWT authentication:

1. **Login**: Enter username and password on the login screen
2. **Register**: Toggle to register mode on the login screen
3. **Auto-logout**: The app automatically logs out on 401 responses
4. **API Key Fallback**: If no JWT token is present, the API key is used for backward compatibility
5. **Token Storage**: JWT tokens are stored securely using `SharedPreferences`

## Project Structure

```
pos_app/
├── lib/
│   ├── data/
│   │   ├── models/      # Data models
│   │   └── services/    # API service
│   ├── providers/       # State management (ChangeNotifier)
│   ├── screens/           # Screen widgets
│   ├── core/             # Theme, printing
│   └── utils/            # Utilities
└── pubspec.yaml
```

## API Service

The `ApiService` (`lib/data/services/api_service.dart`) automatically:
- Attaches JWT `Authorization` header when authenticated
- Falls back to `X-API-Key` header when no token is present
- Triggers logout on 401 responses
- Stores tokens in `SharedPreferences`

## License

Internal use only.
