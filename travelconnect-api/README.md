# TravelConnect API

Backend API pour l'application TravelConnect, construit avec Laravel 11.x.

## Prerequisites

- **PHP** 8.2+
- **Composer** 2.x
- **MySQL** 8.0+

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd travelconnect-api
```

### 2. Install dependencies

```bash
composer install
```

### 3. Configure environment

```bash
cp .env.example .env
php artisan key:generate
```

Edit `.env` and configure your database credentials:

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=travelconnect
DB_USERNAME=root
DB_PASSWORD=
```

### 4. Create the database

```bash
mysql -u root -p -e "CREATE DATABASE travelconnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### 5. Run migrations

```bash
php artisan migrate
```

### 6. Start the development server

```bash
php artisan serve
```

The API will be available at `http://localhost:8000`.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_NAME` | Application name | TravelConnect |
| `APP_ENV` | Environment (local/production) | local |
| `APP_DEBUG` | Debug mode | true |
| `APP_URL` | Application URL | http://localhost:8000 |
| `DB_CONNECTION` | Database driver | mysql |
| `DB_HOST` | Database host | 127.0.0.1 |
| `DB_PORT` | Database port | 3306 |
| `DB_DATABASE` | Database name | travelconnect |
| `DB_USERNAME` | Database username | root |
| `DB_PASSWORD` | Database password | |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key (restrict by platform) | |

## API Endpoints

### Health Check

```
GET /api/health
```

Returns the API health status.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2026-02-04T12:00:00.000000Z"
}
```

## Testing

```bash
# Run all tests
php artisan test

# Run specific test
php artisan test --filter=HealthCheckTest
```

## Project Structure

```
app/
├── Console/
├── Events/
├── Http/
│   ├── Controllers/
│   │   ├── Api/
│   │   └── Admin/
│   ├── Middleware/
│   ├── Requests/
│   └── Resources/
├── Listeners/
├── Models/
├── Observers/
├── Repositories/
└── Services/
```
