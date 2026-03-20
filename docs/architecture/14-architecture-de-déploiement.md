# 14. Architecture de Déploiement

## 14.1 Stratégie de Déploiement

**Frontend (Mobile) :**
- **Plateforme :** App Store (iOS) + Google Play (Android)
- **Build Command :** `flutter build appbundle --release` / `flutter build ios --release`
- **Distribution :** Téléchargement direct stores

**Backend (API) :**
- **Plateforme :** OVH VPS avec Nginx + PHP-FPM
- **Build Command :** `composer install --no-dev --optimize-autoloader`
- **Méthode de Déploiement :** Git pull + artisan down/up + migrate

## 14.2 Pipeline CI/CD

```yaml
# .github/workflows/ci.yml (Backend)
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: travelconnect_test
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: mbstring, dom, fileinfo, mysql, gd
          coverage: xdebug

      - name: Install dependencies
        run: composer install --prefer-dist --no-progress

      - name: Copy .env
        run: cp .env.example .env && php artisan key:generate

      - name: Run tests
        run: php artisan test --coverage-clover=coverage.xml
        env:
          DB_CONNECTION: mysql
          DB_HOST: 127.0.0.1
          DB_DATABASE: travelconnect_test
          DB_USERNAME: root
          DB_PASSWORD: password

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage.xml

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
      - run: composer install --prefer-dist --no-progress
      - run: ./vendor/bin/pint --test
      - run: ./vendor/bin/phpstan analyse --memory-limit=2G
```

```yaml
# .github/workflows/deploy.yml (Backend)
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Deploy to production
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /var/www/travelconnect-api
            php artisan down
            git pull origin main
            composer install --no-dev --optimize-autoloader
            php artisan migrate --force
            php artisan config:cache
            php artisan route:cache
            php artisan view:cache
            php artisan up
```

## 14.3 Environnements

| Environnement | Frontend URL | Backend URL | Objectif |
|---------------|--------------|-------------|----------|
| Development | localhost | http://localhost:8000/api/v1 | Développement local |
| Staging | TestFlight / Internal Testing | https://staging-api.travelconnect.app/api/v1 | Tests pré-production |
| Production | App Store / Google Play | https://api.travelconnect.app/api/v1 | Environnement live |
