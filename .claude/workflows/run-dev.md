---
description: Run development server with hot reload
---

# Run Development Server

// turbo-all

Start the Flutter development server with hot reload enabled.

## Steps

1. Get dependencies (if not already done):
```bash
flutter pub get
```

2. Generate Riverpod code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

3. Run on connected device/emulator:
```bash
flutter run
```

## Device Selection

To select a specific device:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

## Hot Reload vs Hot Restart

- **Hot Reload** (r): Preserves state, faster
- **Hot Restart** (R): Full restart, clears state
- **Quit** (q): Stop the application

## Debug Options

```bash
# With verbose logging
flutter run -v

# With performance overlay
flutter run --profile
```
