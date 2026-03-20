# 13. Workflow de Développement

## 13.1 Prérequis

```bash
# Backend
php --version        # 8.2+
composer --version   # 2.x
mysql --version      # 8.0+

# Mobile
flutter --version    # 3.16+
dart --version       # 3.2+
```

## 13.2 Setup Initial

```bash
# === Backend (travelconnect-api) ===

# Cloner et installer
git clone git@github.com:org/travelconnect-api.git
cd travelconnect-api
composer install

# Configuration
cp .env.example .env
php artisan key:generate

# Base de données
mysql -u root -p -e "CREATE DATABASE travelconnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
# Configurer .env avec les credentials MySQL

# Migrations
php artisan migrate
php artisan db:seed  # Données de test (optionnel)

# Démarrer le serveur
php artisan serve


# === Mobile (travelconnect-app) ===

# Cloner et installer
git clone git@github.com:org/travelconnect-app.git
cd travelconnect-app
flutter pub get

# Configuration
cp .env.example .env
# Configurer l'URL de l'API locale

# Lancer sur émulateur
flutter run
```

## 13.3 Commandes de Développement

```bash
# === Backend ===

# Démarrer tous les services
php artisan serve                    # API sur localhost:8000

# Tests
php artisan test                     # Tous les tests
php artisan test --filter=AuthTest   # Tests spécifiques
php artisan test --coverage          # Avec couverture

# Qualité de code
./vendor/bin/pint                    # Laravel Pint (code style)
./vendor/bin/phpstan analyse         # Analyse statique

# Base de données
php artisan migrate:fresh --seed     # Reset + seed
php artisan tinker                   # Console interactive


# === Mobile ===

# Démarrer l'app
flutter run                          # Device par défaut
flutter run -d chrome                # Web (debug)
flutter run -d ios                   # iOS simulator
flutter run -d android               # Android emulator

# Tests
flutter test                         # Tests unitaires + widget
flutter test integration_test/       # Tests d'intégration
flutter test --coverage              # Avec couverture

# Qualité de code
flutter analyze                      # Analyse statique
dart format lib/                     # Formatage

# Build
flutter build apk --release          # APK Android
flutter build appbundle --release    # AAB Android (Play Store)
flutter build ios --release          # iOS
```

## 13.4 Variables d'Environnement

```bash
# === Backend (.env) ===

APP_NAME=TravelConnect
APP_ENV=local
APP_KEY=base64:xxx
APP_DEBUG=true
APP_URL=http://localhost:8000

# Base de données
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=travelconnect
DB_USERNAME=root
DB_PASSWORD=

# Sanctum
SANCTUM_STATEFUL_DOMAINS=localhost

# Google OAuth
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=xxx

# Apple Sign-In
APPLE_CLIENT_ID=com.travelconnect.app
APPLE_TEAM_ID=xxx
APPLE_KEY_ID=xxx
APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"

# Firebase
FIREBASE_PROJECT_ID=travelconnect-xxx
FIREBASE_CREDENTIALS=/path/to/service-account.json

# OVH Object Storage
OVH_ENDPOINT=https://s3.gra.cloud.ovh.net
OVH_ACCESS_KEY=xxx
OVH_SECRET_KEY=xxx
OVH_BUCKET=travelconnect-avatars
OVH_REGION=gra


# === Mobile (.env) ===

API_BASE_URL=http://localhost:8000/api/v1
GOOGLE_MAPS_API_KEY=xxx

# Production
# API_BASE_URL=https://api.travelconnect.app/api/v1
```
