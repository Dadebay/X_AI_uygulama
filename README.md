# Pulse

Pulse is a Flutter app for following Turkish football posts, trends, teams, and transfer news from X in one place. It also supports Firebase sign-in, saved posts, and push notifications. The app UI supports Turkish, English, and Russian.

## Supported platforms

Android and iOS. The application ID and bundle ID are `com.gurbanov.xai`. No Google Play or App Store listing has been verified for this ID, and this repository does not contain a signed release.

## Setup

Install Flutter 3.47.8 or a compatible newer stable version, Android SDK, Java 17, and Xcode/CocoaPods for iOS. Then run:

```sh
flutter pub get
flutter run
```

The checked-in Firebase client configuration is for the existing Pulse project. To use another Firebase project, replace `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `lib/firebase_options.dart` with matching client configuration. Configure Google and Apple sign-in in that project before testing authentication.

Xquik access requires either a backend proxy or a development API key:

```sh
flutter run --dart-define=XQUIK_DEV_API_KEY=YOUR_DEVELOPMENT_KEY
```

A development key passed through `--dart-define` is embedded in the app and can be extracted. **Production builds must use a server-side proxy** that holds the Xquik credential and pass its HTTPS base URL with `--dart-define=XQUIK_API_BASE_URL=https://your-proxy.example/api/v1`. The old key once committed to this repository must be rotated by its owner.

The app's own API defaults to its legacy HTTP endpoint for local development. Production must supply an HTTPS endpoint with `--dart-define=APP_API_BASE_URL=https://your-api.example/api/`; release builds reject HTTP requests. The API owner should verify the device registration, FCM, About, and Privacy routes on that endpoint.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
flutter build ios --simulator --no-codesign --no-pub
```

CI runs these checks for pull requests and `main`. Android release signing is intentionally external to Git. See [release requirements](docs/RELEASE.md) before distributing an APK or submitting to a store.

## Project layout

- `lib/core/api/`: Xquik and app API clients
- `lib/core/services/`: Firebase authentication, Firestore, and notification storage
- `lib/modules/`: Home, Explore, Saved, Profile, and authentication screens
- `lib/widgets/`: shared UI components
- `test/`: feed pagination and error-state tests

## Current limitations

An API key was previously stored in Git history; removing it from current source does not invalidate the old credential. The owner must rotate it. A production HTTPS proxy, Android release signing key, store listing verification, and real-device smoke tests are still required. No license file is included in this repository.
