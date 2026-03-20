# 12. Structure Unifiée du Projet

## 12.1 Repository Backend (travelconnect-api)

```
travelconnect-api/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Tests + Lint
│       └── deploy.yml          # Déploiement production
│
├── app/
│   ├── Console/
│   ├── Events/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/
│   │   │   └── Admin/
│   │   ├── Middleware/
│   │   ├── Requests/
│   │   └── Resources/
│   ├── Listeners/
│   ├── Models/
│   ├── Observers/
│   ├── Repositories/
│   └── Services/
│
├── bootstrap/
├── config/
├── database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
│
├── public/
├── resources/
│   └── views/
│       └── admin/              # Views admin Blade
│
├── routes/
│   ├── api.php
│   ├── admin.php
│   └── web.php
│
├── storage/
├── tests/
│   ├── Feature/
│   │   ├── Auth/
│   │   ├── Questions/
│   │   └── Answers/
│   └── Unit/
│       ├── Services/
│       └── Repositories/
│
├── .env.example
├── artisan
├── composer.json
├── phpunit.xml
└── README.md
```

## 12.2 Repository Mobile (travelconnect-app)

```
travelconnect-app/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Tests Flutter
│       ├── build-android.yml   # Build AAB
│       └── build-ios.yml       # Build IPA
│
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── kotlin/
│   │   │       └── AndroidManifest.xml
│   │   └── build.gradle
│   └── build.gradle
│
├── ios/
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── AppDelegate.swift
│   └── Podfile
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── injection.dart
│   ├── core/
│   │   ├── api/
│   │   ├── constants/
│   │   ├── error/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   ├── features/
│   │   ├── auth/
│   │   ├── map/
│   │   ├── questions/
│   │   ├── profile/
│   │   └── notifications/
│   └── routes/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── .env.example
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```
