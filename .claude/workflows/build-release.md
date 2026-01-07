---
description: Build release APK and IPA
---

# Build Release

Build production-ready APK (Android) or IPA (iOS).

## Prerequisites

- [ ] Firebase configuration files in place
- [ ] Version number updated in `pubspec.yaml`
- [ ] All tests passing
- [ ] Code generation up to date

## Android (APK)

### 1. Generate Keystore (first time only)

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Configure Signing

Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=upload-keystore.jks
```

### 3. Build APK

// turbo
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 4. Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## iOS (IPA)

### 1. Open Xcode for signing

```bash
open ios/Runner.xcworkspace
```

### 2. Configure Signing
- Select Runner target
- Choose your Team
- Set Bundle Identifier

### 3. Build IPA

```bash
flutter build ipa --release
```

Output: `build/ios/ipa/blind_shake.ipa`

## Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
# 1.0.0 = version name
# +1 = build number (increment for each release)
```

## Notes

> [!IMPORTANT]
> Never commit `key.properties` or keystore files to git.
> Add them to `.gitignore`.

> [!WARNING]
> Test the release build on real devices before publishing.
