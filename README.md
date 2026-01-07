# BlindShake

> 🎯 Anonim eşleşme ve sohbet uygulaması. Salla, eşleş, tanış!

**Durum:** Aktif geliştirme - Major UI entegrasyon milestone tamamlandı (İyi 7 Ocak 2026)

## Konsept

Kullanıcılar telefonlarını sallayarak yakınlarındaki uygun kişilerle eşleşir. İlk 15 dakika **anonim** sohbet eder (isim, fotoğraf yok), ardından her iki taraf da devam edip etmemeye karar verir.

## ✅ Tamamlanan Özellikler (7 Ocak 2026)

- **Kimlik Doğrulama:** Google Sign-In ile tam entegrasyon
- **Eşleşme Sistemi:** Gerçek accelerometer tabanlı salla algılama
- **Konum Servisleri:** Kapsamlı izin yönetimi ve kullanıcı rehberliği
- **Gerçek Zamanlı Chat:** Firestore ile mesajlaşma, 15 dakika anonim sohbet
- **Kimlik Açığa Çıkarma:** Karar modal'ı ile reveal/decline akışı
- **Cloud Functions:** TypeScript backend tam hazır
- **UI Entegrasyonu:** Gerçek servislerle bağlantılı ekranlar
- **Hata Yönetimi:** Kapsamlı kullanıcı dostu hata işleme
- **Riverpod:** Kod üretimiyle state management

## ⚠️ Sıradaki Adımlar

1. ✅ **Real-time Chat Implementation** - TAMAMLANDI (2 saat)
2. **Cloud Functions Deployment** (2-3 saat)
3. **Firebase Security Rules** (1-2 saat)
4. **Testing & Quality Assurance** (2-3 saat)

**Tahmini Kalan Süre:** 6-10 saat

**NOT:** Match Reveal/Decline Flow, chat implementation ile birlikte tamamlandı.

## Tech Stack

| Katman | Teknoloji |
|--------|-----------|
| Frontend | Flutter 3.x, Riverpod, go_router |
| Backend | Firebase (Auth, Firestore, Functions, FCM) |
| Location | geolocator, geoflutterfire_plus |
| Sensors | sensors_plus (accelerometer) |

## Proje Yapısı

```
lib/
├── main.dart                 # ✅ Firebase init + ProviderScope
├── firebase_options.dart     # ✅ Auto-generated config
└── src/
    ├── app/                  # ✅ App config, router, theme
    │   ├── router.dart      # ✅ go_router with auth redirects
    │   └── theme/           # ✅ Material 3 dark theme
    ├── core/                 # ✅ Services implemented
    │   └── services/        # ✅ Location, shake, app setup
    ├── features/             # ✅ Feature modules
    │   ├── auth/            # ✅ Complete Google Sign-In
    │   ├── matching/        # ✅ UI integrated with Cloud Functions
    │   ├── chat/            # ⚠️ Backend ready, UI needs work
    │   └── profile/         # ✅ Settings screen
    └── shared/               # ✅ Reusable components
        └── widgets/         # ✅ ShakeButton, etc.

functions/                    # ✅ Complete TypeScript backend
├── src/
│   ├── matching/            # ✅ Real-time proximity matching
│   ├── chat/               # ✅ Anonymous chat + reveal logic
│   └── cleanup/            # ✅ Scheduled maintenance
└── package.json            # ✅ Dependencies configured
```

## Kurulum

```bash
# 1. Dependencies
flutter pub get

# 2. Code generation (Riverpod için)
dart run build_runner build --delete-conflicting-outputs

# 3. Firebase CLI (eğer yoksa)
npm install -g firebase-tools
firebase login

# 4. FlutterFire configure (tamamlandı)
flutterfire configure

# 5. Run
flutter run
```

## Geliştirme Komutları

```bash
# Code generation watch mode
dart run build_runner watch --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Run tests
flutter test

# Build APK
flutter build apk --release
```

## Agent Dosyaları

AI agent'lar için kılavuzlar `.agent/agents/` klasöründe:

- `FRONTEND_AGENT.md` - UI/UX geliştirme
- `BACKEND_AGENT.md` - Cloud Functions
- `API_SERVICE_AGENT.md` - Repository pattern
- `AUTH_AGENT.md` - Kimlik doğrulama
- `MATCHING_AGENT.md` - Eşleşme algoritması
- `TESTER_AGENT.md` - Test stratejileri

## Workflows

Sık kullanılan komutlar `.agent/workflows/` klasöründe:

- `run-dev.md` - Geliştirme ortamı
- `build-release.md` - Release APK/IPA
- `setup-firebase.md` - Firebase kurulumu
- `deploy-functions.md` - Cloud Functions deploy

## Lisans

Proprietary - Tüm hakları saklıdır.
