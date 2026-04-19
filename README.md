<<<<<<< HEAD
# Local Service Finder

A Flutter mobile app that connects **customers** with **local service providers** (two-sided marketplace). Features include Firebase Authentication, Cloud Firestore for users/providers/bookings, Google Maps for locations, role-based navigation (user vs. provider), booking with date and time, and animated Material 3 UI with light/dark themes.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart SDK compatible with `pubspec.yaml`)
- [Android Studio](https://developer.android.com/studio) or Xcode (for iOS)
- A [Firebase](https://console.firebase.google.com/) project with **Authentication (Email/Password)** and **Cloud Firestore** enabled
- **Google Maps API key** enabled for Maps SDK for Android / iOS (and billing enabled on Google Cloud if required)

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/YOUR_USERNAME/LocalServiceFinder.git
   cd LocalServiceFinder
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase configuration**

   - Register Android and iOS apps in the Firebase console with package IDs matching this project (`android/app` `applicationId` / iOS bundle ID).
   - Download `google-services.json` → place in `android/app/`.
   - Download `GoogleService-Info.plist` → place in `ios/Runner/`.
   - Regenerate or edit `lib/firebase_options.dart` to match your Firebase project (or run `flutterfire configure`).

4. **Google Maps**

   - **Android:** Set `com.google.android.geo.API_KEY` in `android/app/src/main/AndroidManifest.xml`.
   - **iOS:** Add the Maps API key per [google_maps_flutter iOS setup](https://pub.dev/packages/google_maps_flutter#ios) (e.g. `AppDelegate` / `Info.plist` as documented).

5. **Run the app**

   ```bash
   flutter run
   ```

   Or pick a device: `flutter devices` then `flutter run -d <device_id>`.

## Building release binaries

```bash
flutter build apk --release
# iOS (on macOS, with signing configured)
flutter build ios --release
```

## Project structure (high level)

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Firebase init, `MultiProvider`, routes |
| `lib/controllers/` | `AuthController`, theme controller usage |
| `lib/services/` | Firebase Auth + Firestore access |
| `lib/models/` | User, provider, booking models |
| `lib/screens/` | Auth, user, provider, settings screens |
| `assets/` | Images, animations, icons |

## Documentation

- Full academic **project report** (sections for PDF submission): [`docs/PROJECT_REPORT.md`](docs/PROJECT_REPORT.md).

## Security note for public repositories

Do **not** commit production API keys or private Firebase files if the repository is public. Use placeholders in `firebase_options.dart` and platform config files, and document setup steps above so others can plug in their own Firebase project.

## License

*[Add a license if required by your course — e.g. MIT — or state “Educational use only.”]*
=======
# Local-Service-Finder-Android-App-Using-Flutter
Local Service Finder Android App Using Flutter
>>>>>>> 3f1db7889d531a19cb7b8b8e9e6e01201dc1587b
