# TravelConnect - Document d'Architecture Fullstack

---

## 1. Introduction

Ce document décrit l'architecture technique complète de TravelConnect, une application mobile communautaire connectant les voyageurs avec des locaux et voyageurs expérimentés pour obtenir des conseils en temps réel géolocalisés.

Cette architecture est conçue pour supporter les objectifs du MVP :
- 10 000 utilisateurs actifs mensuels (MAU)
- 500+ Local Supporters vérifiés dans 10 destinations
- Temps de réponse moyen < 2 heures pour 80% des questions
- Budget de développement : 3 000€ HT

### 1.1 Starter Template ou Projet Existant

**N/A - Projet Greenfield**

Ce projet démarre de zéro avec deux repositories distincts :
- `travelconnect-api` : Backend Laravel
- `travelconnect-app` : Application mobile Flutter

### 1.2 Journal des Modifications

| Date | Version | Description | Auteur |
|------|---------|-------------|--------|
| 2026-01-31 | 1.0 | Création initiale du document d'architecture | Winston (Architect) |

---

## 2. Architecture de Haut Niveau

### 2.1 Résumé Technique

TravelConnect adopte une architecture **monolithe modulaire** avec une application mobile Flutter cross-platform communiquant via API REST avec un backend Laravel. Cette approche pragmatique maximise la vélocité de développement pour un développeur solo tout en maintenant une séparation claire des responsabilités. L'infrastructure est hébergée sur OVH (VPS + Object Storage) pour optimiser les coûts, avec MySQL 8 exploitant les extensions spatiales pour les requêtes géolocalisées. Firebase Cloud Messaging assure les notifications push critiques pour l'engagement utilisateur, et Google Maps SDK fournit la cartographie interactive.

### 2.2 Plateforme et Infrastructure

**Plateforme :** OVH Cloud (Europe)

**Services Clés :**
- OVH VPS (Starter ou Essential) - Serveur applicatif
- OVH Object Storage - Stockage des photos de profil
- MySQL 8.0+ - Base de données avec extensions spatiales
- Firebase (Google Cloud) - FCM + Analytics + Crashlytics

**Régions de Déploiement :**
- Production : OVH Gravelines (France) - Latence acceptable pour le Japon via CDN
- Firebase : Région Asie-Pacifique pour les notifications

**Justification :** OVH offre le meilleur rapport qualité/prix pour le budget MVP, avec des serveurs européens conformes RGPD. La latence vers le Japon (~200ms) est acceptable pour une API REST avec mise en cache appropriée.

### 2.3 Structure des Repositories

**Structure : Polyrepo (2 repositories séparés)**

| Repository | Technologie | Description |
|------------|-------------|-------------|
| `travelconnect-api` | Laravel 11 (PHP 8.2+) | Backend API REST, Admin |
| `travelconnect-app` | Flutter 3.x (Dart 3.0+) | Application mobile iOS/Android |

**Justification :**
- Séparation claire backend/mobile
- Déploiement indépendant
- Pipelines CI/CD distincts
- Facilite l'ajout d'équipes séparées ultérieurement

### 2.4 Diagramme d'Architecture de Haut Niveau

```mermaid
graph TB
    subgraph "Clients Mobiles"
        iOS[iOS App<br/>Flutter]
        Android[Android App<br/>Flutter]
    end

    subgraph "Services Externes"
        GoogleAuth[Google OAuth]
        AppleAuth[Apple Sign-In]
        FCM[Firebase Cloud Messaging]
        GoogleMaps[Google Maps SDK]
        Firebase[Firebase Analytics<br/>Crashlytics]
    end

    subgraph "OVH Infrastructure"
        subgraph "VPS Server"
            Nginx[Nginx<br/>Reverse Proxy]
            Laravel[Laravel 11<br/>API REST]
            Admin[Laravel Admin<br/>Interface]
        end
        MySQL[(MySQL 8.0<br/>Spatial)]
        Storage[OVH Object Storage<br/>Photos]
    end

    iOS --> |HTTPS| Nginx
    Android --> |HTTPS| Nginx
    iOS --> GoogleMaps
    Android --> GoogleMaps
    iOS --> Firebase
    Android --> Firebase

    Nginx --> Laravel
    Nginx --> Admin

    Laravel --> MySQL
    Laravel --> Storage
    Laravel --> FCM
    Laravel --> GoogleAuth
    Laravel --> AppleAuth

    FCM --> iOS
    FCM --> Android
```

### 2.5 Patterns Architecturaux

| Pattern | Description | Justification |
|---------|-------------|---------------|
| **Monolithe Modulaire** | Backend Laravel organisé en modules (Auth, Questions, Profils, Notifications) | Simplicité de déploiement, rapidité de développement pour un solo dev |
| **API REST** | Communication client-serveur via endpoints REST JSON | Standard mature, excellente documentation, outillage riche |
| **Repository Pattern** | Abstraction de l'accès aux données via Eloquent Repositories | Testabilité, flexibilité pour évolution future |
| **Service Layer** | Logique métier isolée dans des classes Service | Séparation des responsabilités, réutilisabilité |
| **BLoC Pattern (Flutter)** | Gestion d'état avec Business Logic Components | Pattern recommandé Flutter, séparation UI/logique |
| **Feature-First Structure** | Organisation du code Flutter par fonctionnalité | Scalabilité, maintenabilité |

---

## 3. Stack Technologique

### 3.1 Table des Technologies

| Catégorie | Technologie | Version | Objectif | Justification |
|-----------|-------------|---------|----------|---------------|
| **Langage Mobile** | Dart | 3.2+ | Développement Flutter | Langage natif Flutter, null-safety |
| **Framework Mobile** | Flutter | 3.16+ | App iOS/Android | Cross-platform performant, UI riche, écosystème mature |
| **Langage Backend** | PHP | 8.2+ | API Laravel | Performance, typage strict, match expressions |
| **Framework Backend** | Laravel | 11.x | API REST + Admin | Framework PHP robuste, écosystème riche, Eloquent ORM |
| **Base de données** | MySQL | 8.0+ | Stockage persistant | Extensions spatiales natives, fiabilité, performances |
| **Cache** | Laravel File Cache | - | Cache applicatif MVP | Suffisant pour MVP, migration Redis ultérieure possible |
| **Stockage Fichiers** | OVH Object Storage | S3-compatible | Photos de profil | Coût maîtrisé, API S3 compatible |
| **Authentification** | Laravel Sanctum | 4.x | Tokens API | Léger, adapté SPA/Mobile, intégré Laravel |
| **OAuth** | Laravel Socialite | 5.x | Google/Apple Sign-In | Support multi-providers, intégration simple |
| **Push Notifications** | Firebase Cloud Messaging | - | Notifications iOS/Android | Gratuit, fiable, intégration Flutter native |
| **Cartes** | Google Maps SDK | Latest | Carte interactive | Fiabilité, familiarité utilisateurs japonais |
| **Tests Backend** | PHPUnit | 10.x | Tests unitaires/intégration | Standard Laravel, couverture complète |
| **Tests Flutter** | Flutter Test | Built-in | Tests widgets/unitaires | Framework de test intégré Flutter |
| **Tests E2E** | Integration Tests Flutter | Built-in | Tests end-to-end mobile | Tests sur device réel/émulateur |
| **Build Tool Backend** | Composer | 2.x | Gestion dépendances PHP | Standard PHP |
| **Build Tool Mobile** | Flutter CLI | 3.x | Build iOS/Android | Toolchain Flutter officielle |
| **CI/CD** | GitHub Actions | - | Automatisation builds/tests | Gratuit repos privés, intégration native |
| **Monitoring** | Firebase Crashlytics | - | Crash reporting | Gratuit, dashboard détaillé |
| **Analytics** | Firebase Analytics | - | Tracking utilisateur | Gratuit, intégration native Flutter |
| **Logging Backend** | Laravel Log (Monolog) | - | Logs applicatifs | Intégré Laravel, rotation automatique |
| **CSS/UI Mobile** | Material Design 3 | - | Design system Flutter | Standard Flutter, widgets riches |

---

## 4. Modèles de Données

### 4.1 User (Utilisateur)

**Objectif :** Représente un utilisateur de l'application (Voyageur ou Local Supporter)

**Attributs Clés :**
- `id`: bigint - Identifiant unique auto-incrémenté
- `email`: string - Email unique (peut être relayé Apple)
- `name`: string - Nom d'affichage
- `avatar_url`: string|null - URL de la photo de profil
- `bio`: string|null - Bio courte (max 150 caractères)
- `country_code`: string - Code pays ISO (JP, FR, etc.)
- `user_type`: enum - 'traveler' ou 'local_supporter'
- `trust_score`: decimal(3,2) - Score de confiance calculé (0.00-5.00)
- `is_new`: boolean - Nouveau utilisateur (< 3 réponses notées)
- `provider`: string - Fournisseur OAuth (google, apple)
- `provider_id`: string - ID unique du provider
- `fcm_token`: string|null - Token Firebase Cloud Messaging
- `notification_zone_lat`: decimal|null - Latitude zone de notification
- `notification_zone_lng`: decimal|null - Longitude zone de notification
- `notification_zone_radius`: int|null - Rayon en km
- `is_banned`: boolean - Utilisateur banni
- `created_at`: timestamp
- `updated_at`: timestamp

```typescript
// Interface TypeScript (pour documentation)
interface User {
  id: number;
  email: string;
  name: string;
  avatar_url: string | null;
  bio: string | null;
  country_code: string;
  user_type: 'traveler' | 'local_supporter';
  trust_score: number;
  is_new: boolean;
  provider: 'google' | 'apple';
  provider_id: string;
  fcm_token: string | null;
  notification_zone_lat: number | null;
  notification_zone_lng: number | null;
  notification_zone_radius: number | null;
  is_banned: boolean;
  created_at: string;
  updated_at: string;
}
```

**Relations :**
- Has many Questions
- Has many Answers
- Has many Ratings (given)
- Has many Notifications
- Has many Reports (submitted)

---

### 4.2 Question

**Objectif :** Représente une question géolocalisée posée par un voyageur

**Attributs Clés :**
- `id`: bigint - Identifiant unique
- `user_id`: bigint - Auteur de la question (FK)
- `title`: string - Titre (max 100 caractères)
- `description`: text|null - Description détaillée (max 500 caractères)
- `latitude`: decimal(10,8) - Latitude
- `longitude`: decimal(11,8) - Longitude
- `location_name`: string|null - Nom du lieu (reverse geocoded)
- `city`: string|null - Ville pour filtrage
- `answers_count`: int - Compteur dénormalisé
- `has_unread_answers`: boolean - Pour l'auteur
- `is_deleted`: boolean - Soft delete
- `created_at`: timestamp
- `updated_at`: timestamp

```typescript
interface Question {
  id: number;
  user_id: number;
  title: string;
  description: string | null;
  latitude: number;
  longitude: number;
  location_name: string | null;
  city: string | null;
  answers_count: number;
  has_unread_answers: boolean;
  is_deleted: boolean;
  created_at: string;
  updated_at: string;
  // Relations
  user?: User;
  answers?: Answer[];
}
```

**Relations :**
- Belongs to User
- Has many Answers
- Has many Reports

---

### 4.3 Answer (Réponse)

**Objectif :** Représente une réponse à une question

**Attributs Clés :**
- `id`: bigint - Identifiant unique
- `question_id`: bigint - Question associée (FK)
- `user_id`: bigint - Auteur de la réponse (FK)
- `content`: text - Contenu (max 1000 caractères)
- `average_rating`: decimal(2,1)|null - Note moyenne
- `ratings_count`: int - Nombre de notes
- `is_deleted`: boolean - Soft delete
- `created_at`: timestamp
- `updated_at`: timestamp

```typescript
interface Answer {
  id: number;
  question_id: number;
  user_id: number;
  content: string;
  average_rating: number | null;
  ratings_count: number;
  is_deleted: boolean;
  created_at: string;
  updated_at: string;
  // Relations
  user?: User;
  question?: Question;
  user_rating?: number; // Note donnée par l'utilisateur courant
}
```

**Relations :**
- Belongs to Question
- Belongs to User
- Has many Ratings
- Has many Reports

---

### 4.4 Rating (Note)

**Objectif :** Note donnée à une réponse

**Attributs Clés :**
- `id`: bigint - Identifiant unique
- `answer_id`: bigint - Réponse notée (FK)
- `user_id`: bigint - Utilisateur qui note (FK)
- `score`: tinyint - Note de 1 à 5
- `created_at`: timestamp
- `updated_at`: timestamp

```typescript
interface Rating {
  id: number;
  answer_id: number;
  user_id: number;
  score: 1 | 2 | 3 | 4 | 5;
  created_at: string;
  updated_at: string;
}
```

**Relations :**
- Belongs to Answer
- Belongs to User

**Contrainte :** Un utilisateur ne peut noter une réponse qu'une seule fois (unique: answer_id, user_id)

---

### 4.5 Report (Signalement)

**Objectif :** Signalement de contenu inapproprié

**Attributs Clés :**
- `id`: bigint - Identifiant unique
- `reporter_id`: bigint - Utilisateur signalant (FK)
- `reportable_type`: string - Type de contenu (Question, Answer)
- `reportable_id`: bigint - ID du contenu signalé
- `reason`: enum - spam, offensive, false_info, other
- `comment`: text|null - Commentaire optionnel
- `status`: enum - pending, approved, rejected
- `admin_note`: text|null - Note de l'admin
- `processed_at`: timestamp|null
- `processed_by`: bigint|null - Admin qui a traité (FK)
- `created_at`: timestamp
- `updated_at`: timestamp

```typescript
interface Report {
  id: number;
  reporter_id: number;
  reportable_type: 'Question' | 'Answer';
  reportable_id: number;
  reason: 'spam' | 'offensive' | 'false_info' | 'other';
  comment: string | null;
  status: 'pending' | 'approved' | 'rejected';
  admin_note: string | null;
  processed_at: string | null;
  processed_by: number | null;
  created_at: string;
  updated_at: string;
}
```

**Relations :**
- Belongs to User (reporter)
- Morphs to Question or Answer (reportable)
- Belongs to Admin (processed_by)

---

### 4.6 Notification

**Objectif :** Notification utilisateur

**Attributs Clés :**
- `id`: uuid - Identifiant unique UUID
- `user_id`: bigint - Destinataire (FK)
- `type`: string - Type de notification
- `title`: string - Titre affiché
- `body`: string - Corps du message
- `data`: json - Données additionnelles (question_id, etc.)
- `read_at`: timestamp|null
- `created_at`: timestamp

```typescript
interface Notification {
  id: string;
  user_id: number;
  type: 'new_answer' | 'nearby_question';
  title: string;
  body: string;
  data: {
    question_id?: number;
    answer_id?: number;
  };
  read_at: string | null;
  created_at: string;
}
```

**Relations :**
- Belongs to User

---

### 4.7 Admin

**Objectif :** Compte administrateur (séparé des utilisateurs)

**Attributs Clés :**
- `id`: bigint - Identifiant unique
- `email`: string - Email unique
- `password`: string - Hash bcrypt
- `name`: string - Nom
- `last_login_at`: timestamp|null
- `created_at`: timestamp
- `updated_at`: timestamp

---

### 4.8 Diagramme Entité-Relation

```mermaid
erDiagram
    User ||--o{ Question : creates
    User ||--o{ Answer : writes
    User ||--o{ Rating : gives
    User ||--o{ Report : submits
    User ||--o{ Notification : receives

    Question ||--o{ Answer : has
    Question ||--o{ Report : "can have"

    Answer ||--o{ Rating : receives
    Answer ||--o{ Report : "can have"

    Admin ||--o{ Report : processes

    User {
        bigint id PK
        string email UK
        string name
        string avatar_url
        string bio
        string country_code
        enum user_type
        decimal trust_score
        boolean is_new
        string provider
        string provider_id
        string fcm_token
        decimal notification_zone_lat
        decimal notification_zone_lng
        int notification_zone_radius
        boolean is_banned
        timestamp created_at
        timestamp updated_at
    }

    Question {
        bigint id PK
        bigint user_id FK
        string title
        text description
        decimal latitude
        decimal longitude
        string location_name
        string city
        int answers_count
        boolean has_unread_answers
        boolean is_deleted
        timestamp created_at
        timestamp updated_at
    }

    Answer {
        bigint id PK
        bigint question_id FK
        bigint user_id FK
        text content
        decimal average_rating
        int ratings_count
        boolean is_deleted
        timestamp created_at
        timestamp updated_at
    }

    Rating {
        bigint id PK
        bigint answer_id FK
        bigint user_id FK
        tinyint score
        timestamp created_at
        timestamp updated_at
    }

    Report {
        bigint id PK
        bigint reporter_id FK
        string reportable_type
        bigint reportable_id
        enum reason
        text comment
        enum status
        text admin_note
        timestamp processed_at
        bigint processed_by FK
        timestamp created_at
        timestamp updated_at
    }

    Notification {
        uuid id PK
        bigint user_id FK
        string type
        string title
        string body
        json data
        timestamp read_at
        timestamp created_at
    }

    Admin {
        bigint id PK
        string email UK
        string password
        string name
        timestamp last_login_at
        timestamp created_at
        timestamp updated_at
    }
```

---

## 5. Spécification API REST

### 5.1 Vue d'Ensemble

```yaml
openapi: 3.0.3
info:
  title: TravelConnect API
  version: 1.0.0
  description: API REST pour l'application TravelConnect
servers:
  - url: https://api.travelconnect.app/api/v1
    description: Production
  - url: http://localhost:8000/api/v1
    description: Development
```

### 5.2 Authentification

Tous les endpoints (sauf auth/*) nécessitent un Bearer Token dans le header :
```
Authorization: Bearer {sanctum_token}
```

### 5.3 Endpoints

#### 5.3.1 Health Check

```
GET /health
```
**Réponse :** `200 OK`
```json
{
  "status": "ok",
  "timestamp": "2026-01-31T10:30:00Z"
}
```

---

#### 5.3.2 Authentification

**Google Sign-In**
```
POST /auth/google
```
**Body :**
```json
{
  "id_token": "google_id_token_here"
}
```
**Réponse :** `200 OK`
```json
{
  "user": { /* User object */ },
  "token": "sanctum_token_here",
  "is_new_user": true
}
```

---

**Apple Sign-In**
```
POST /auth/apple
```
**Body :**
```json
{
  "identity_token": "apple_identity_token",
  "authorization_code": "apple_auth_code",
  "full_name": {
    "given_name": "John",
    "family_name": "Doe"
  }
}
```
**Réponse :** `200 OK` (même format que Google)

---

**Déconnexion**
```
POST /auth/logout
```
**Réponse :** `204 No Content`

---

#### 5.3.3 Profil Utilisateur

**Obtenir le profil courant**
```
GET /user/profile
```
**Réponse :** `200 OK`
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "Tanaka Yuki",
    "avatar_url": "https://storage.../avatar.jpg",
    "bio": "Voyageur passionné",
    "country_code": "JP",
    "user_type": "traveler",
    "trust_score": 4.2,
    "is_new": false,
    "questions_count": 5,
    "answers_count": 12
  }
}
```

---

**Mettre à jour le profil**
```
PUT /user/profile
```
**Body :**
```json
{
  "name": "Nouveau Nom",
  "bio": "Nouvelle bio",
  "country_code": "JP",
  "user_type": "local_supporter"
}
```
**Réponse :** `200 OK` (User object mis à jour)

---

**Upload photo de profil**
```
POST /user/avatar
Content-Type: multipart/form-data
```
**Body :** `avatar` (file, image/jpeg ou image/png, max 5MB)

**Réponse :** `200 OK`
```json
{
  "avatar_url": "https://storage.../new-avatar.jpg"
}
```

---

**Enregistrer token FCM**
```
POST /user/fcm-token
```
**Body :**
```json
{
  "fcm_token": "firebase_token_here"
}
```
**Réponse :** `204 No Content`

---

**Configurer zone de notification**
```
PUT /user/notification-zone
```
**Body :**
```json
{
  "latitude": 35.6762,
  "longitude": 139.6503,
  "radius_km": 10
}
```
**Réponse :** `204 No Content`

---

#### 5.3.4 Questions

**Lister les questions (géolocalisées)**
```
GET /questions?lat={lat}&lng={lng}&radius={km}&page={page}
```
**Paramètres :**
- `lat` (required): Latitude du centre
- `lng` (required): Longitude du centre
- `radius` (optional, default 10): Rayon en km (max 50)
- `page` (optional, default 1): Page de pagination

**Réponse :** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "title": "Meilleur ramen près de Shibuya ?",
      "description": "Je cherche un bon restaurant...",
      "latitude": 35.6595,
      "longitude": 139.7004,
      "location_name": "Shibuya, Tokyo",
      "city": "Tokyo",
      "answers_count": 3,
      "created_at": "2026-01-31T08:00:00Z",
      "user": {
        "id": 1,
        "name": "Tanaka",
        "avatar_url": "...",
        "user_type": "traveler",
        "trust_score": 3.5
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 20,
    "total": 100
  }
}
```

---

**Lister les questions (fil d'actualité)**
```
GET /questions?sort=recent&city={city}&page={page}
```
**Paramètres :**
- `sort` (optional): recent (default), popular
- `city` (optional): Filtrer par ville

---

**Mes questions**
```
GET /user/questions?page={page}
```
**Réponse :** Liste paginée des questions de l'utilisateur connecté

---

**Créer une question**
```
POST /questions
```
**Body :**
```json
{
  "title": "Meilleur ramen près de Shibuya ?",
  "description": "Je cherche un bon restaurant de ramen authentique...",
  "latitude": 35.6595,
  "longitude": 139.7004
}
```
**Validation :**
- `title`: required, string, max:100
- `description`: nullable, string, max:500
- `latitude`: required, numeric, between:-90,90
- `longitude`: required, numeric, between:-180,180

**Réponse :** `201 Created`
```json
{
  "data": { /* Question object complet */ }
}
```

---

**Détail d'une question**
```
GET /questions/{id}
```
**Réponse :** `200 OK`
```json
{
  "data": {
    "id": 1,
    "title": "...",
    "description": "...",
    "latitude": 35.6595,
    "longitude": 139.7004,
    "location_name": "Shibuya, Tokyo",
    "answers_count": 3,
    "created_at": "2026-01-31T08:00:00Z",
    "user": { /* User object */ },
    "answers": [
      {
        "id": 1,
        "content": "Je recommande Ichiran...",
        "average_rating": 4.5,
        "ratings_count": 10,
        "created_at": "2026-01-31T09:00:00Z",
        "user": { /* User object */ },
        "user_rating": 5
      }
    ]
  }
}
```

---

#### 5.3.5 Réponses

**Créer une réponse**
```
POST /questions/{id}/answers
```
**Body :**
```json
{
  "content": "Je recommande Ichiran, c'est délicieux et ouvert tard !"
}
```
**Validation :**
- `content`: required, string, max:1000

**Réponse :** `201 Created`
```json
{
  "data": { /* Answer object */ }
}
```

---

**Noter une réponse**
```
POST /answers/{id}/rate
```
**Body :**
```json
{
  "score": 5
}
```
**Validation :**
- `score`: required, integer, between:1,5
- L'utilisateur ne peut pas noter sa propre réponse

**Réponse :** `200 OK`
```json
{
  "average_rating": 4.3,
  "ratings_count": 11
}
```

---

#### 5.3.6 Signalements

**Signaler un contenu**
```
POST /reports
```
**Body :**
```json
{
  "reportable_type": "Question",
  "reportable_id": 1,
  "reason": "spam",
  "comment": "Publicité déguisée"
}
```
**Validation :**
- `reportable_type`: required, in:Question,Answer
- `reportable_id`: required, exists
- `reason`: required, in:spam,offensive,false_info,other
- `comment`: nullable, string, max:500
- Un utilisateur ne peut signaler le même contenu qu'une fois

**Réponse :** `201 Created`

---

#### 5.3.7 Notifications

**Lister les notifications**
```
GET /notifications?page={page}
```
**Réponse :** `200 OK`
```json
{
  "data": [
    {
      "id": "uuid-here",
      "type": "new_answer",
      "title": "Nouvelle réponse",
      "body": "Tanaka a répondu à votre question",
      "data": {
        "question_id": 1,
        "answer_id": 5
      },
      "read_at": null,
      "created_at": "2026-01-31T10:00:00Z"
    }
  ],
  "meta": { /* pagination */ },
  "unread_count": 3
}
```

---

**Marquer comme lue**
```
POST /notifications/{id}/read
```
**Réponse :** `204 No Content`

---

**Marquer toutes comme lues**
```
POST /notifications/read-all
```
**Réponse :** `204 No Content`

---

### 5.4 Codes d'Erreur

| Code | Signification |
|------|---------------|
| 200 | Succès |
| 201 | Ressource créée |
| 204 | Succès sans contenu |
| 400 | Requête invalide |
| 401 | Non authentifié |
| 403 | Non autorisé |
| 404 | Ressource non trouvée |
| 422 | Erreur de validation |
| 429 | Trop de requêtes (rate limit) |
| 500 | Erreur serveur |

**Format d'erreur :**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Les données fournies sont invalides",
    "details": {
      "title": ["Le titre est requis"]
    },
    "timestamp": "2026-01-31T10:00:00Z",
    "request_id": "req_abc123"
  }
}
```

---

## 6. Composants

### 6.1 Backend - Laravel API

#### 6.1.1 Auth Module

**Responsabilité :** Gestion de l'authentification OAuth et des sessions

**Interfaces Clés :**
- `AuthController` : Endpoints Google/Apple Sign-In, logout
- `AuthService` : Logique de vérification tokens, création utilisateurs
- `SocialiteProviders` : Configuration Google/Apple

**Dépendances :** Laravel Sanctum, Socialite

**Technologies :** PHP 8.2, Laravel 11

---

#### 6.1.2 Questions Module

**Responsabilité :** CRUD questions, requêtes géospatiales

**Interfaces Clés :**
- `QuestionController` : Endpoints REST
- `QuestionService` : Logique métier
- `QuestionRepository` : Accès données avec requêtes spatiales

**Dépendances :** MySQL Spatial Functions

**Technologies :** Eloquent ORM, MySQL 8 Spatial

---

#### 6.1.3 Answers Module

**Responsabilité :** Réponses et système de notation

**Interfaces Clés :**
- `AnswerController` : Endpoints REST
- `AnswerService` : Logique métier, calcul moyennes
- `RatingService` : Gestion des notes, mise à jour trust score

**Dépendances :** Questions Module

---

#### 6.1.4 Notifications Module

**Responsabilité :** Envoi notifications push, stockage historique

**Interfaces Clés :**
- `NotificationController` : Endpoints REST
- `NotificationService` : Logique d'envoi
- `FCMService` : Intégration Firebase Cloud Messaging

**Dépendances :** Firebase Admin SDK

---

#### 6.1.5 Admin Module

**Responsabilité :** Interface d'administration

**Interfaces Clés :**
- `AdminController` : Dashboard, login
- `ModerationController` : Gestion signalements
- `UserManagementController` : Gestion utilisateurs

**Dépendances :** Laravel Blade (views)

---

### 6.2 Frontend - Flutter App

#### 6.2.1 Auth Feature

**Responsabilité :** Écrans login, gestion tokens

**Composants :**
- `LoginScreen` : UI login
- `AuthBloc` : Gestion état authentification
- `AuthRepository` : Communication API auth

**Dépendances :** google_sign_in, sign_in_with_apple, flutter_secure_storage

---

#### 6.2.2 Map Feature

**Responsabilité :** Carte interactive, marqueurs questions

**Composants :**
- `MapScreen` : Vue carte principale
- `MapBloc` : Gestion état carte
- `QuestionMarker` : Widget marqueur personnalisé
- `LocationService` : Gestion géolocalisation

**Dépendances :** google_maps_flutter, geolocator

---

#### 6.2.3 Questions Feature

**Responsabilité :** Liste questions, détail, création

**Composants :**
- `QuestionListScreen` : Fil d'actualité
- `QuestionDetailScreen` : Détail question + réponses
- `CreateQuestionScreen` : Formulaire création
- `QuestionsBloc` : Gestion état questions

---

#### 6.2.4 Profile Feature

**Responsabilité :** Profil utilisateur, édition

**Composants :**
- `ProfileScreen` : Vue profil
- `EditProfileScreen` : Édition profil
- `ProfileBloc` : Gestion état profil

---

#### 6.2.5 Notifications Feature

**Responsabilité :** Centre notifications, push

**Composants :**
- `NotificationCenterScreen` : Liste notifications
- `NotificationsBloc` : Gestion état
- `PushNotificationService` : Intégration FCM

**Dépendances :** firebase_messaging, flutter_local_notifications

---

### 6.3 Diagramme des Composants

```mermaid
graph TB
    subgraph "Flutter App"
        subgraph "Features"
            AuthF[Auth Feature]
            MapF[Map Feature]
            QuestionsF[Questions Feature]
            ProfileF[Profile Feature]
            NotifF[Notifications Feature]
        end

        subgraph "Core"
            ApiClient[API Client]
            LocalStorage[Secure Storage]
            Navigation[Router]
        end

        subgraph "Services"
            LocationSvc[Location Service]
            PushSvc[Push Service]
        end
    end

    subgraph "Laravel API"
        subgraph "Controllers"
            AuthC[Auth Controller]
            QuestionC[Question Controller]
            AnswerC[Answer Controller]
            NotifC[Notification Controller]
            ProfileC[Profile Controller]
        end

        subgraph "Services"
            AuthSvc[Auth Service]
            QuestionSvc[Question Service]
            AnswerSvc[Answer Service]
            FCMSvc[FCM Service]
            TrustSvc[Trust Score Service]
        end

        subgraph "Repositories"
            UserRepo[User Repository]
            QuestionRepo[Question Repository]
            AnswerRepo[Answer Repository]
        end
    end

    AuthF --> ApiClient
    MapF --> ApiClient
    QuestionsF --> ApiClient
    ProfileF --> ApiClient
    NotifF --> ApiClient

    MapF --> LocationSvc
    NotifF --> PushSvc

    ApiClient --> AuthC
    ApiClient --> QuestionC
    ApiClient --> AnswerC
    ApiClient --> NotifC
    ApiClient --> ProfileC

    AuthC --> AuthSvc
    QuestionC --> QuestionSvc
    AnswerC --> AnswerSvc
    NotifC --> FCMSvc

    QuestionSvc --> QuestionRepo
    AnswerSvc --> AnswerRepo
    AnswerSvc --> TrustSvc
    AuthSvc --> UserRepo
```

---

## 7. APIs Externes

### 7.1 Google OAuth 2.0

- **Objectif :** Authentification utilisateurs via compte Google
- **Documentation :** https://developers.google.com/identity
- **Base URL :** https://oauth2.googleapis.com
- **Authentification :** OAuth 2.0 ID Token
- **Rate Limits :** 10,000 requêtes/jour (gratuit)

**Endpoints Utilisés :**
- `POST /token` - Échange code d'autorisation
- `GET /tokeninfo` - Validation ID token

**Notes d'Intégration :** Utilisation de Laravel Socialite pour simplifier l'intégration. Le token ID est validé côté serveur.

---

### 7.2 Apple Sign-In

- **Objectif :** Authentification utilisateurs iOS via compte Apple
- **Documentation :** https://developer.apple.com/sign-in-with-apple
- **Base URL :** https://appleid.apple.com
- **Authentification :** Identity Token JWT
- **Rate Limits :** Pas de limite documentée

**Endpoints Utilisés :**
- `POST /auth/token` - Validation identity token
- `GET /auth/keys` - Clés publiques pour validation JWT

**Notes d'Intégration :** Obligatoire pour les apps iOS avec authentification sociale. Support de "Hide My Email".

---

### 7.3 Firebase Cloud Messaging (FCM)

- **Objectif :** Notifications push iOS et Android
- **Documentation :** https://firebase.google.com/docs/cloud-messaging
- **Base URL :** https://fcm.googleapis.com/v1
- **Authentification :** Service Account JWT
- **Rate Limits :** Pas de limite pour messages individuels

**Endpoints Utilisés :**
- `POST /projects/{project}/messages:send` - Envoi notification

**Notes d'Intégration :** Utilisation du package `kreait/firebase-php` pour Laravel. Configuration projet Firebase requise pour iOS (APNs) et Android.

---

### 7.4 Google Maps Platform

- **Objectif :** Affichage carte, markers, geocoding
- **Documentation :** https://developers.google.com/maps
- **Authentification :** API Key
- **Rate Limits :** Selon plan tarifaire (crédit mensuel gratuit de $200)

**Services Utilisés :**
- Maps SDK for iOS/Android - Carte interactive
- Geocoding API - Reverse geocoding pour location_name

**Notes d'Intégration :** API Key restreinte par package name (Android) et bundle ID (iOS). Optimisation des appels geocoding via cache.

---

### 7.5 OVH Object Storage (S3-compatible)

- **Objectif :** Stockage photos de profil
- **Documentation :** https://docs.ovh.com/gb/en/storage/object-storage-swift-api/
- **Base URL :** https://s3.{region}.cloud.ovh.net
- **Authentification :** AWS Signature V4 (S3 compatible)
- **Rate Limits :** Pas de limite, facturation à l'usage

**Opérations Utilisées :**
- `PUT /{bucket}/{key}` - Upload image
- `DELETE /{bucket}/{key}` - Suppression image

**Notes d'Intégration :** Utilisation du package `league/flysystem-aws-s3-v3` avec Laravel Filesystem.

---

## 8. Workflows Principaux

### 8.1 Authentification Google

```mermaid
sequenceDiagram
    participant U as User
    participant App as Flutter App
    participant Google as Google OAuth
    participant API as Laravel API
    participant DB as MySQL

    U->>App: Tap "Continuer avec Google"
    App->>Google: Demande authentification
    Google->>U: Affiche écran consentement
    U->>Google: Autorise
    Google->>App: Retourne ID Token
    App->>API: POST /auth/google {id_token}
    API->>Google: Valide ID Token
    Google->>API: Token valide + infos user

    alt Nouvel utilisateur
        API->>DB: Crée User
        DB->>API: User créé
        API->>App: {user, token, is_new_user: true}
        App->>U: Affiche écran complétion profil
    else Utilisateur existant
        API->>DB: Récupère User
        DB->>API: User data
        API->>App: {user, token, is_new_user: false}
        App->>U: Redirige vers carte
    end
```

---

### 8.2 Publication d'une Question

```mermaid
sequenceDiagram
    participant U as User
    participant App as Flutter App
    participant API as Laravel API
    participant DB as MySQL
    participant FCM as Firebase FCM
    participant LS as Local Supporters

    U->>App: Tap bouton "+" (FAB)
    App->>App: Affiche formulaire question
    U->>App: Remplit titre, description
    App->>App: Pré-remplit localisation GPS
    U->>App: Ajuste localisation si nécessaire
    U->>App: Tap "Publier"

    App->>API: POST /questions {title, description, lat, lng}
    API->>API: Valide données
    API->>DB: INSERT question
    DB->>API: Question créée
    API->>API: Reverse geocode → location_name
    API->>DB: UPDATE question (location_name, city)

    API->>DB: SELECT local_supporters WHERE zone contains(lat, lng)
    DB->>API: Liste Local Supporters

    loop Pour chaque Local Supporter
        API->>FCM: Envoie notification "Nouvelle question près de {city}"
        FCM->>LS: Push notification
    end

    API->>App: {question}
    App->>U: Affiche confirmation + question sur carte
```

---

### 8.3 Réponse et Notation

```mermaid
sequenceDiagram
    participant Traveler as Voyageur
    participant Local as Local Supporter
    participant App as Flutter App
    participant API as Laravel API
    participant DB as MySQL
    participant FCM as Firebase FCM

    Local->>App: Ouvre détail question
    Local->>App: Tap "Répondre"
    Local->>App: Écrit réponse
    Local->>App: Tap "Envoyer"

    App->>API: POST /questions/{id}/answers {content}
    API->>DB: INSERT answer
    DB->>API: Answer créée

    API->>DB: SELECT question.user
    DB->>API: Voyageur info
    API->>FCM: Notification "Nouvelle réponse"
    FCM->>Traveler: Push notification

    API->>DB: UPDATE question (answers_count++, has_unread_answers=true)
    API->>App: {answer}
    App->>Local: Affiche réponse publiée

    Note over Traveler: Plus tard...

    Traveler->>App: Ouvre notification
    App->>API: GET /questions/{id}
    API->>App: {question, answers}
    App->>Traveler: Affiche question + réponses

    Traveler->>App: Note réponse (5 étoiles)
    App->>API: POST /answers/{id}/rate {score: 5}
    API->>DB: INSERT/UPDATE rating
    API->>DB: RECALCULATE average_rating
    API->>DB: RECALCULATE user trust_score
    DB->>API: Nouvelles valeurs
    API->>App: {average_rating, ratings_count}
    App->>Traveler: Affiche note mise à jour
```

---

### 8.4 Calcul du Trust Score

```mermaid
sequenceDiagram
    participant API as Laravel API
    participant DB as MySQL

    Note over API: Après chaque nouvelle note reçue

    API->>DB: SELECT AVG(score) FROM ratings<br/>WHERE answer.user_id = {user_id}
    DB->>API: average_rating = 4.2

    API->>DB: SELECT COUNT(*) FROM ratings<br/>WHERE answer.user_id = {user_id}
    DB->>API: total_ratings = 15

    API->>API: trust_score = average_rating * log(total_ratings + 1)<br/>= 4.2 * log(16) ≈ 4.2 * 1.20 = 5.04<br/>Capped at 5.0

    API->>DB: UPDATE users SET trust_score = 5.0,<br/>is_new = false WHERE id = {user_id}

    Note over API: is_new = false quand ratings_count >= 3
```

---

## 9. Schéma de Base de Données

### 9.1 Migrations SQL

```sql
-- Users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(500) NULL,
    bio VARCHAR(150) NULL,
    country_code CHAR(2) NOT NULL DEFAULT 'JP',
    user_type ENUM('traveler', 'local_supporter') NOT NULL DEFAULT 'traveler',
    trust_score DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    is_new BOOLEAN NOT NULL DEFAULT TRUE,
    provider ENUM('google', 'apple') NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    fcm_token VARCHAR(500) NULL,
    notification_zone_lat DECIMAL(10,8) NULL,
    notification_zone_lng DECIMAL(11,8) NULL,
    notification_zone_radius INT UNSIGNED NULL,
    is_banned BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE INDEX idx_provider_id (provider, provider_id),
    INDEX idx_notification_zone (notification_zone_lat, notification_zone_lng)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Questions table with spatial index
CREATE TABLE questions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    location POINT NOT NULL SRID 4326,
    location_name VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    answers_count INT UNSIGNED NOT NULL DEFAULT 0,
    has_unread_answers BOOLEAN NOT NULL DEFAULT FALSE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    SPATIAL INDEX idx_location (location),
    INDEX idx_city (city),
    INDEX idx_created_at (created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Answers table
CREATE TABLE answers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    question_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    content TEXT NOT NULL,
    average_rating DECIMAL(2,1) NULL,
    ratings_count INT UNSIGNED NOT NULL DEFAULT 0,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_question_created (question_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ratings table
CREATE TABLE ratings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    answer_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    score TINYINT UNSIGNED NOT NULL CHECK (score BETWEEN 1 AND 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (answer_id) REFERENCES answers(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_answer_user (answer_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reports table
CREATE TABLE reports (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reporter_id BIGINT UNSIGNED NOT NULL,
    reportable_type VARCHAR(50) NOT NULL,
    reportable_id BIGINT UNSIGNED NOT NULL,
    reason ENUM('spam', 'offensive', 'false_info', 'other') NOT NULL,
    comment TEXT NULL,
    status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    admin_note TEXT NULL,
    processed_at TIMESTAMP NULL,
    processed_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (processed_by) REFERENCES admins(id) ON DELETE SET NULL,
    UNIQUE INDEX idx_reporter_reportable (reporter_id, reportable_type, reportable_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notifications table
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSON NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, read_at),
    INDEX idx_user_created (user_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admins table
CREATE TABLE admins (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Personal access tokens (Sanctum)
CREATE TABLE personal_access_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tokenable_type VARCHAR(255) NOT NULL,
    tokenable_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    abilities TEXT NULL,
    last_used_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_tokenable (tokenable_type, tokenable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 9.2 Requête Géospatiale Exemple

```sql
-- Trouver les questions dans un rayon de 10km
SELECT
    q.*,
    ST_Distance_Sphere(q.location, ST_SRID(POINT(139.6503, 35.6762), 4326)) AS distance_meters
FROM questions q
WHERE ST_Distance_Sphere(
    q.location,
    ST_SRID(POINT(139.6503, 35.6762), 4326)
) <= 10000  -- 10km en mètres
AND q.is_deleted = FALSE
ORDER BY q.created_at DESC
LIMIT 100;
```

---

## 10. Architecture Frontend (Flutter)

### 10.1 Organisation des Composants

```
lib/
├── main.dart                    # Point d'entrée
├── app.dart                     # Configuration MaterialApp
├── injection.dart               # Dependency injection (GetIt)
│
├── core/                        # Code partagé
│   ├── api/
│   │   ├── api_client.dart      # Client HTTP (Dio)
│   │   ├── api_interceptors.dart
│   │   └── api_exceptions.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_endpoints.dart
│   ├── error/
│   │   └── failures.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── loading_indicator.dart
│       ├── error_widget.dart
│       └── avatar_widget.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── auth_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_google.dart
│   │   │       └── sign_in_with_apple.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       └── widgets/
│   │           └── social_login_button.dart
│   │
│   ├── map/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── map_bloc.dart
│   │       ├── pages/
│   │       │   └── map_page.dart
│   │       └── widgets/
│   │           ├── question_marker.dart
│   │           └── question_info_window.dart
│   │
│   ├── questions/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── questions_bloc.dart
│   │       │   └── question_detail_bloc.dart
│   │       ├── pages/
│   │       │   ├── questions_feed_page.dart
│   │       │   ├── question_detail_page.dart
│   │       │   └── create_question_page.dart
│   │       └── widgets/
│   │           ├── question_card.dart
│   │           ├── answer_item.dart
│   │           └── rating_stars.dart
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── notifications/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── routes/
    └── app_router.dart          # GoRouter configuration
```

### 10.2 Template de Composant (BLoC)

```dart
// features/questions/presentation/bloc/questions_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'questions_event.dart';
part 'questions_state.dart';

class QuestionsBloc extends Bloc<QuestionsEvent, QuestionsState> {
  final GetNearbyQuestions _getNearbyQuestions;

  QuestionsBloc({
    required GetNearbyQuestions getNearbyQuestions,
  })  : _getNearbyQuestions = getNearbyQuestions,
        super(QuestionsInitial()) {
    on<LoadNearbyQuestions>(_onLoadNearbyQuestions);
    on<RefreshQuestions>(_onRefreshQuestions);
  }

  Future<void> _onLoadNearbyQuestions(
    LoadNearbyQuestions event,
    Emitter<QuestionsState> emit,
  ) async {
    emit(QuestionsLoading());

    final result = await _getNearbyQuestions(
      NearbyQuestionsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: event.radiusKm,
      ),
    );

    result.fold(
      (failure) => emit(QuestionsError(failure.message)),
      (questions) => emit(QuestionsLoaded(questions)),
    );
  }

  Future<void> _onRefreshQuestions(
    RefreshQuestions event,
    Emitter<QuestionsState> emit,
  ) async {
    // Refresh logic
  }
}
```

### 10.3 Gestion d'État

```dart
// Structure du state global avec plusieurs BLoCs

// AuthBloc - État authentification
abstract class AuthState extends Equatable {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
}
class Unauthenticated extends AuthState {}

// Pattern d'utilisation dans l'app
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => getIt<AuthBloc>()),
    BlocProvider(create: (_) => getIt<MapBloc>()),
    BlocProvider(create: (_) => getIt<QuestionsBloc>()),
    BlocProvider(create: (_) => getIt<ProfileBloc>()),
    BlocProvider(create: (_) => getIt<NotificationsBloc>()),
  ],
  child: const TravelConnectApp(),
)
```

### 10.4 Architecture de Routing

```dart
// routes/app_router.dart
final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is Authenticated;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) return '/login';
    if (isLoggedIn && isLoggingIn) return '/map';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapPage(),
        ),
        GoRoute(
          path: '/feed',
          builder: (context, state) => const QuestionsFeedPage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/question/:id',
      builder: (context, state) => QuestionDetailPage(
        questionId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/question/create',
      builder: (context, state) => const CreateQuestionPage(),
    ),
  ],
);
```

### 10.5 Route Protégée Pattern

```dart
// Middleware d'authentification via GoRouter redirect
redirect: (context, state) {
  final authBloc = context.read<AuthBloc>();
  final isAuthenticated = authBloc.state is Authenticated;

  // Routes publiques
  final publicRoutes = ['/login', '/onboarding'];
  final isPublicRoute = publicRoutes.contains(state.matchedLocation);

  if (!isAuthenticated && !isPublicRoute) {
    return '/login';
  }

  if (isAuthenticated && state.matchedLocation == '/login') {
    final user = (authBloc.state as Authenticated).user;
    // Rediriger vers onboarding si profil incomplet
    if (user.name.isEmpty) {
      return '/onboarding';
    }
    return '/map';
  }

  return null;
}
```

### 10.6 Layer Services Frontend

```dart
// core/api/api_client.dart
class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = ApiEndpoints.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParams}) {
    return _dio.get<T>(path, queryParameters: queryParams);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }
}
```

```dart
// features/questions/data/datasources/questions_remote_datasource.dart
class QuestionsRemoteDataSource {
  final ApiClient _apiClient;

  QuestionsRemoteDataSource(this._apiClient);

  Future<List<QuestionModel>> getNearbyQuestions({
    required double lat,
    required double lng,
    required int radiusKm,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      '/questions',
      queryParams: {
        'lat': lat,
        'lng': lng,
        'radius': radiusKm,
        'page': page,
      },
    );

    return (response.data['data'] as List)
        .map((json) => QuestionModel.fromJson(json))
        .toList();
  }

  Future<QuestionModel> createQuestion(CreateQuestionDto dto) async {
    final response = await _apiClient.post(
      '/questions',
      data: dto.toJson(),
    );

    return QuestionModel.fromJson(response.data['data']);
  }
}
```

---

## 11. Architecture Backend (Laravel)

### 11.1 Architecture des Services

```
app/
├── Console/
│   └── Commands/
│       └── CalculateTrustScores.php    # Commande scheduled
│
├── Http/
│   ├── Controllers/
│   │   ├── Api/
│   │   │   ├── AuthController.php
│   │   │   ├── QuestionController.php
│   │   │   ├── AnswerController.php
│   │   │   ├── ProfileController.php
│   │   │   ├── NotificationController.php
│   │   │   └── ReportController.php
│   │   └── Admin/
│   │       ├── DashboardController.php
│   │       ├── ModerationController.php
│   │       └── UserController.php
│   │
│   ├── Middleware/
│   │   ├── EnsureUserNotBanned.php
│   │   └── AdminAuthenticate.php
│   │
│   ├── Requests/
│   │   ├── CreateQuestionRequest.php
│   │   ├── CreateAnswerRequest.php
│   │   ├── RateAnswerRequest.php
│   │   └── UpdateProfileRequest.php
│   │
│   └── Resources/
│       ├── QuestionResource.php
│       ├── AnswerResource.php
│       ├── UserResource.php
│       └── NotificationResource.php
│
├── Models/
│   ├── User.php
│   ├── Question.php
│   ├── Answer.php
│   ├── Rating.php
│   ├── Report.php
│   ├── Notification.php
│   └── Admin.php
│
├── Repositories/
│   ├── Contracts/
│   │   ├── QuestionRepositoryInterface.php
│   │   └── UserRepositoryInterface.php
│   └── Eloquent/
│       ├── QuestionRepository.php
│       └── UserRepository.php
│
├── Services/
│   ├── AuthService.php
│   ├── QuestionService.php
│   ├── AnswerService.php
│   ├── TrustScoreService.php
│   ├── NotificationService.php
│   ├── FCMService.php
│   └── StorageService.php
│
├── Events/
│   ├── AnswerCreated.php
│   ├── QuestionCreated.php
│   └── AnswerRated.php
│
├── Listeners/
│   ├── SendNewAnswerNotification.php
│   ├── NotifyNearbyLocalSupporters.php
│   └── UpdateTrustScore.php
│
└── Observers/
    ├── AnswerObserver.php
    └── RatingObserver.php

routes/
├── api.php          # Routes API REST
├── admin.php        # Routes admin web
└── channels.php     # Broadcasting channels (si WebSocket futur)

config/
├── services.php     # Configuration services externes
├── firebase.php     # Configuration FCM
└── filesystems.php  # Configuration OVH Object Storage
```

### 11.2 Controller Template

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CreateQuestionRequest;
use App\Http\Resources\QuestionResource;
use App\Services\QuestionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class QuestionController extends Controller
{
    public function __construct(
        private readonly QuestionService $questionService
    ) {}

    /**
     * Liste des questions géolocalisées ou par fil d'actualité
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $request->validate([
            'lat' => 'required_without:sort|numeric|between:-90,90',
            'lng' => 'required_without:sort|numeric|between:-180,180',
            'radius' => 'nullable|integer|min:1|max:50',
            'sort' => 'nullable|in:recent,popular',
            'city' => 'nullable|string|max:100',
        ]);

        if ($request->has('lat') && $request->has('lng')) {
            $questions = $this->questionService->getNearbyQuestions(
                latitude: $request->float('lat'),
                longitude: $request->float('lng'),
                radiusKm: $request->integer('radius', 10),
                page: $request->integer('page', 1)
            );
        } else {
            $questions = $this->questionService->getFeedQuestions(
                sort: $request->string('sort', 'recent'),
                city: $request->string('city'),
                page: $request->integer('page', 1)
            );
        }

        return QuestionResource::collection($questions);
    }

    /**
     * Créer une nouvelle question
     */
    public function store(CreateQuestionRequest $request): JsonResponse
    {
        $question = $this->questionService->createQuestion(
            user: $request->user(),
            data: $request->validated()
        );

        return response()->json([
            'data' => new QuestionResource($question)
        ], 201);
    }

    /**
     * Détail d'une question avec ses réponses
     */
    public function show(int $id): JsonResponse
    {
        $question = $this->questionService->getQuestionWithAnswers($id);

        return response()->json([
            'data' => new QuestionResource($question)
        ]);
    }
}
```

### 11.3 Schéma et Data Access Layer

```php
<?php

namespace App\Repositories\Eloquent;

use App\Models\Question;
use App\Repositories\Contracts\QuestionRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class QuestionRepository implements QuestionRepositoryInterface
{
    public function __construct(
        private readonly Question $model
    ) {}

    /**
     * Récupère les questions dans un rayon géographique
     */
    public function findNearby(
        float $latitude,
        float $longitude,
        int $radiusKm,
        int $perPage = 20
    ): LengthAwarePaginator {
        $radiusMeters = $radiusKm * 1000;

        return $this->model
            ->select([
                'questions.*',
                DB::raw("ST_Distance_Sphere(
                    location,
                    ST_SRID(POINT({$longitude}, {$latitude}), 4326)
                ) as distance_meters")
            ])
            ->whereRaw("ST_Distance_Sphere(
                location,
                ST_SRID(POINT(?, ?), 4326)
            ) <= ?", [$longitude, $latitude, $radiusMeters])
            ->where('is_deleted', false)
            ->with(['user:id,name,avatar_url,user_type,trust_score'])
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }

    /**
     * Récupère les questions pour le fil d'actualité
     */
    public function findForFeed(
        string $sort = 'recent',
        ?string $city = null,
        int $perPage = 20
    ): LengthAwarePaginator {
        $query = $this->model
            ->where('is_deleted', false)
            ->with(['user:id,name,avatar_url,user_type,trust_score']);

        if ($city) {
            $query->where('city', $city);
        }

        if ($sort === 'popular') {
            $query->orderByDesc('answers_count');
        } else {
            $query->orderByDesc('created_at');
        }

        return $query->paginate($perPage);
    }

    /**
     * Crée une question avec point géographique
     */
    public function create(array $data): Question
    {
        // Créer le point spatial
        $data['location'] = DB::raw(
            "ST_SRID(POINT({$data['longitude']}, {$data['latitude']}), 4326)"
        );

        return $this->model->create($data);
    }
}
```

### 11.4 Authentification et Autorisation

```php
<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;
use Laravel\Socialite\Facades\Socialite;
use Laravel\Sanctum\NewAccessToken;

class AuthService
{
    /**
     * Authentification via Google ID Token
     */
    public function authenticateWithGoogle(string $idToken): array
    {
        // Valider le token avec Google
        $response = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $idToken,
        ]);

        if ($response->failed()) {
            throw new \InvalidArgumentException('Invalid Google token');
        }

        $googleUser = $response->json();

        // Vérifier l'audience (client ID)
        if ($googleUser['aud'] !== config('services.google.client_id')) {
            throw new \InvalidArgumentException('Invalid token audience');
        }

        return $this->findOrCreateUser(
            provider: 'google',
            providerId: $googleUser['sub'],
            email: $googleUser['email'],
            name: $googleUser['name'] ?? 'Utilisateur',
            avatarUrl: $googleUser['picture'] ?? null
        );
    }

    /**
     * Authentification via Apple Identity Token
     */
    public function authenticateWithApple(
        string $identityToken,
        string $authorizationCode,
        ?array $fullName = null
    ): array {
        // Utiliser Socialite pour valider le token Apple
        $appleUser = Socialite::driver('apple')
            ->stateless()
            ->userFromToken($identityToken);

        $name = 'Utilisateur';
        if ($fullName) {
            $name = trim(($fullName['given_name'] ?? '') . ' ' . ($fullName['family_name'] ?? ''));
            if (empty($name)) {
                $name = 'Utilisateur';
            }
        }

        return $this->findOrCreateUser(
            provider: 'apple',
            providerId: $appleUser->getId(),
            email: $appleUser->getEmail(),
            name: $name,
            avatarUrl: null
        );
    }

    /**
     * Trouve ou crée un utilisateur
     */
    private function findOrCreateUser(
        string $provider,
        string $providerId,
        string $email,
        string $name,
        ?string $avatarUrl
    ): array {
        $isNewUser = false;

        $user = User::where('provider', $provider)
            ->where('provider_id', $providerId)
            ->first();

        if (!$user) {
            // Vérifier si l'email existe déjà avec un autre provider
            $existingUser = User::where('email', $email)->first();

            if ($existingUser) {
                throw new \InvalidArgumentException(
                    'Un compte existe déjà avec cet email via un autre fournisseur'
                );
            }

            $user = User::create([
                'email' => $email,
                'name' => $name,
                'avatar_url' => $avatarUrl,
                'provider' => $provider,
                'provider_id' => $providerId,
                'user_type' => 'traveler',
            ]);

            $isNewUser = true;
        }

        // Vérifier si l'utilisateur est banni
        if ($user->is_banned) {
            throw new \InvalidArgumentException('Ce compte a été suspendu');
        }

        // Créer le token Sanctum
        $token = $user->createToken('mobile-app');

        return [
            'user' => $user,
            'token' => $token->plainTextToken,
            'is_new_user' => $isNewUser,
        ];
    }
}
```

### 11.5 Auth Flow Diagram

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant API as Laravel API
    participant Google as Google OAuth
    participant DB as MySQL

    App->>API: POST /auth/google {id_token}
    API->>Google: GET /tokeninfo?id_token=xxx
    Google->>API: {sub, email, name, picture}

    API->>API: Valide audience (client_id)
    API->>DB: SELECT * FROM users WHERE provider='google' AND provider_id=sub

    alt User exists
        DB->>API: User found
        API->>API: Check is_banned
    else New user
        DB->>API: Not found
        API->>DB: INSERT INTO users (...)
        DB->>API: User created
    end

    API->>DB: INSERT INTO personal_access_tokens (...)
    DB->>API: Token created

    API->>App: {user, token, is_new_user}
```

### 11.6 Auth Middleware

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserNotBanned
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->is_banned) {
            return response()->json([
                'error' => [
                    'code' => 'USER_BANNED',
                    'message' => 'Votre compte a été suspendu',
                ]
            ], 403);
        }

        return $next($request);
    }
}

// Enregistrement dans Kernel.php ou bootstrap/app.php (Laravel 11)
->withMiddleware(function (Middleware $middleware) {
    $middleware->api(prepend: [
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    ]);

    $middleware->alias([
        'auth.sanctum' => \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        'not.banned' => \App\Http\Middleware\EnsureUserNotBanned::class,
    ]);
})
```

---

## 12. Structure Unifiée du Projet

### 12.1 Repository Backend (travelconnect-api)

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

### 12.2 Repository Mobile (travelconnect-app)

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

---

## 13. Workflow de Développement

### 13.1 Prérequis

```bash
# Backend
php --version        # 8.2+
composer --version   # 2.x
mysql --version      # 8.0+

# Mobile
flutter --version    # 3.16+
dart --version       # 3.2+
```

### 13.2 Setup Initial

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

### 13.3 Commandes de Développement

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

### 13.4 Variables d'Environnement

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

---

## 14. Architecture de Déploiement

### 14.1 Stratégie de Déploiement

**Frontend (Mobile) :**
- **Plateforme :** App Store (iOS) + Google Play (Android)
- **Build Command :** `flutter build appbundle --release` / `flutter build ios --release`
- **Distribution :** Téléchargement direct stores

**Backend (API) :**
- **Plateforme :** OVH VPS avec Nginx + PHP-FPM
- **Build Command :** `composer install --no-dev --optimize-autoloader`
- **Méthode de Déploiement :** Git pull + artisan down/up + migrate

### 14.2 Pipeline CI/CD

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

### 14.3 Environnements

| Environnement | Frontend URL | Backend URL | Objectif |
|---------------|--------------|-------------|----------|
| Development | localhost | http://localhost:8000/api/v1 | Développement local |
| Staging | TestFlight / Internal Testing | https://staging-api.travelconnect.app/api/v1 | Tests pré-production |
| Production | App Store / Google Play | https://api.travelconnect.app/api/v1 | Environnement live |

---

## 15. Sécurité et Performance

### 15.1 Exigences de Sécurité

**Sécurité Frontend :**
- **Stockage Sécurisé :** Tokens stockés via `flutter_secure_storage` (Keychain iOS, Keystore Android)
- **Certificate Pinning :** Implémenté pour les connexions API en production
- **Obfuscation :** Code Dart obfusqué en release (`--obfuscate`)

**Sécurité Backend :**
- **Validation Input :** Toutes les entrées validées via Form Requests Laravel
- **Rate Limiting :** 60 requêtes/minute par IP, 1000/minute par utilisateur authentifié
- **CORS Policy :** Restreint aux domaines autorisés uniquement

**Sécurité Authentification :**
- **Stockage Tokens :** Tokens Sanctum hashés en base, expiration 30 jours inactivité
- **Gestion Sessions :** Un seul token actif par appareil, révocation possible
- **Politique Mots de Passe :** N/A (OAuth uniquement)

### 15.2 Optimisation Performance

**Performance Frontend :**
- **Taille Bundle :** < 20MB APK, < 50MB IPA (objectif)
- **Stratégie Chargement :** Lazy loading des features, préchargement carte
- **Stratégie Cache :** Cache images (cached_network_image), cache requêtes API (5 min)

**Performance Backend :**
- **Temps Réponse Cible :** < 500ms pour 95% des requêtes
- **Optimisation BDD :** Index sur colonnes de recherche, index spatial, requêtes optimisées
- **Stratégie Cache :** Cache fichier Laravel, cache requêtes géospatiales fréquentes

---

## 16. Stratégie de Tests

### 16.1 Pyramide de Tests

```
        E2E Tests (Flutter Integration)
       /                              \
      Integration Tests (API Feature)
     /                                \
    Frontend Unit Tests    Backend Unit Tests
    (Flutter Test)         (PHPUnit)
```

### 16.2 Organisation des Tests

**Tests Frontend :**
```
test/
├── unit/
│   ├── services/
│   │   └── trust_score_calculator_test.dart
│   └── utils/
│       └── date_formatter_test.dart
├── widget/
│   ├── question_card_test.dart
│   └── rating_stars_test.dart
└── integration/
    └── auth_flow_test.dart
```

**Tests Backend :**
```
tests/
├── Unit/
│   ├── Services/
│   │   ├── TrustScoreServiceTest.php
│   │   └── AuthServiceTest.php
│   └── Repositories/
│       └── QuestionRepositoryTest.php
└── Feature/
    ├── Auth/
    │   ├── GoogleAuthTest.php
    │   └── AppleAuthTest.php
    ├── Questions/
    │   ├── CreateQuestionTest.php
    │   └── ListQuestionsTest.php
    └── Answers/
        ├── CreateAnswerTest.php
        └── RateAnswerTest.php
```

### 16.3 Exemples de Tests

**Test Widget Flutter :**
```dart
// test/widget/question_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travelconnect/features/questions/presentation/widgets/question_card.dart';

void main() {
  group('QuestionCard', () {
    testWidgets('displays question title and author', (tester) async {
      final question = Question(
        id: 1,
        title: 'Best ramen in Shibuya?',
        user: User(name: 'Tanaka', userType: UserType.traveler),
        answersCount: 3,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionCard(question: question),
          ),
        ),
      );

      expect(find.text('Best ramen in Shibuya?'), findsOneWidget);
      expect(find.text('Tanaka'), findsOneWidget);
      expect(find.text('3 réponses'), findsOneWidget);
    });

    testWidgets('shows different marker color for unanswered questions', (tester) async {
      final question = Question(
        id: 1,
        title: 'Help needed!',
        answersCount: 0,
        // ...
      );

      await tester.pumpWidget(/* ... */);

      final marker = tester.widget<Container>(find.byType(Container).first);
      expect(marker.decoration, /* has urgent color */);
    });
  });
}
```

**Test API Laravel :**
```php
<?php

namespace Tests\Feature\Questions;

use App\Models\Question;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CreateQuestionTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_create_question(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/questions', [
            'title' => 'Best ramen in Shibuya?',
            'description' => 'Looking for authentic tonkotsu ramen',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'title',
                    'description',
                    'latitude',
                    'longitude',
                    'location_name',
                    'user',
                ],
            ]);

        $this->assertDatabaseHas('questions', [
            'title' => 'Best ramen in Shibuya?',
            'user_id' => $user->id,
        ]);
    }

    public function test_title_is_required(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/questions', [
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title']);
    }

    public function test_unauthenticated_user_cannot_create_question(): void
    {
        $response = $this->postJson('/api/v1/questions', [
            'title' => 'Test question',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(401);
    }
}
```

**Test E2E Flutter :**
```dart
// integration_test/auth_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travelconnect/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('User can sign in with Google and see map', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen is shown
      expect(find.text('Continuer avec Google'), findsOneWidget);

      // Tap Google sign-in button
      await tester.tap(find.text('Continuer avec Google'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // After successful login, map should be visible
      expect(find.byType(GoogleMap), findsOneWidget);
    });
  });
}
```

---

## 17. Standards de Codage

### 17.1 Règles Critiques Fullstack

| Règle | Description |
|-------|-------------|
| **Validation Côté Serveur** | Toujours valider les entrées côté API, même si validées côté client |
| **Gestion d'Erreurs** | Utiliser les handlers d'erreurs standardisés, jamais d'exceptions non catchées |
| **Authentification** | Toujours vérifier l'authentification via middleware, jamais dans le controller |
| **Variables d'Environnement** | Accéder via `config()` (Laravel) et injectées (Flutter), jamais `env()` directement |
| **Appels API** | Utiliser la couche service/repository, jamais d'appels HTTP directs dans les widgets/controllers |
| **Logs** | Logger les erreurs critiques avec contexte, jamais de données sensibles |
| **Commits** | Messages conventionnels (feat/fix/docs/refactor), jamais de commits de fichiers sensibles |

### 17.2 Conventions de Nommage

| Élément | Frontend (Dart) | Backend (PHP) | Exemple |
|---------|-----------------|---------------|---------|
| Classes | PascalCase | PascalCase | `QuestionCard`, `QuestionService` |
| Fichiers | snake_case | PascalCase (PSR-4) | `question_card.dart`, `QuestionService.php` |
| Variables | camelCase | camelCase | `questionCount`, `$questionCount` |
| Constantes | SCREAMING_SNAKE | SCREAMING_SNAKE | `MAX_TITLE_LENGTH`, `MAX_TITLE_LENGTH` |
| Routes API | - | kebab-case | `/api/v1/user-profile` |
| Tables BDD | - | snake_case | `user_questions` |
| Colonnes BDD | - | snake_case | `created_at` |

---

## 18. Stratégie de Gestion d'Erreurs

### 18.1 Flow d'Erreur

```mermaid
sequenceDiagram
    participant User
    participant Flutter as Flutter App
    participant API as Laravel API
    participant Logger as Logging

    User->>Flutter: Action (ex: créer question)
    Flutter->>API: POST /questions

    alt Validation Error (422)
        API->>Flutter: {error: {code, message, details}}
        Flutter->>User: Affiche erreurs champs
    else Auth Error (401)
        API->>Flutter: {error: {code: "UNAUTHENTICATED"}}
        Flutter->>Flutter: Clear token, redirect login
        Flutter->>User: "Session expirée, reconnectez-vous"
    else Server Error (500)
        API->>Logger: Log error with stack trace
        API->>Flutter: {error: {code: "SERVER_ERROR", request_id}}
        Flutter->>User: "Une erreur est survenue. Réessayez."
    else Network Error
        Flutter->>User: "Connexion impossible. Vérifiez votre réseau."
    end
```

### 18.2 Format de Réponse d'Erreur

```typescript
interface ApiError {
  error: {
    code: string;           // VALIDATION_ERROR, UNAUTHENTICATED, FORBIDDEN, etc.
    message: string;        // Message lisible par l'utilisateur
    details?: Record<string, string[]>;  // Erreurs par champ (validation)
    timestamp: string;      // ISO 8601
    request_id: string;     // UUID pour le debugging
  };
}
```

### 18.3 Handler d'Erreurs Frontend

```dart
// core/error/error_handler.dart
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'La connexion a expiré. Réessayez.';
        case DioExceptionType.connectionError:
          return 'Impossible de se connecter. Vérifiez votre réseau.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (statusCode == 401) {
            // Trigger logout
            return 'Session expirée. Reconnectez-vous.';
          }
          if (statusCode == 422 && data != null) {
            // Validation errors handled by form
            return data['error']['message'] ?? 'Données invalides';
          }
          if (statusCode == 429) {
            return 'Trop de requêtes. Patientez un moment.';
          }
          return data?['error']?['message'] ?? 'Une erreur est survenue';
        default:
          return 'Une erreur inattendue est survenue';
      }
    }
    return 'Une erreur est survenue';
  }
}
```

### 18.4 Handler d'Erreurs Backend

```php
<?php

// app/Exceptions/Handler.php (Laravel 11: bootstrap/app.php)
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Validation\ValidationException;
use Illuminate\Auth\AuthenticationException;
use Symfony\Component\HttpKernel\Exception\HttpException;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->render(function (Throwable $e, $request) {
        if ($request->expectsJson()) {
            $requestId = $request->header('X-Request-ID') ?? (string) Str::uuid();

            if ($e instanceof ValidationException) {
                return response()->json([
                    'error' => [
                        'code' => 'VALIDATION_ERROR',
                        'message' => 'Les données fournies sont invalides',
                        'details' => $e->errors(),
                        'timestamp' => now()->toISOString(),
                        'request_id' => $requestId,
                    ]
                ], 422);
            }

            if ($e instanceof AuthenticationException) {
                return response()->json([
                    'error' => [
                        'code' => 'UNAUTHENTICATED',
                        'message' => 'Authentification requise',
                        'timestamp' => now()->toISOString(),
                        'request_id' => $requestId,
                    ]
                ], 401);
            }

            if ($e instanceof HttpException) {
                return response()->json([
                    'error' => [
                        'code' => 'HTTP_ERROR',
                        'message' => $e->getMessage() ?: 'Erreur HTTP',
                        'timestamp' => now()->toISOString(),
                        'request_id' => $requestId,
                    ]
                ], $e->getStatusCode());
            }

            // Log server errors
            Log::error($e->getMessage(), [
                'request_id' => $requestId,
                'exception' => $e,
                'url' => $request->fullUrl(),
                'user_id' => $request->user()?->id,
            ]);

            return response()->json([
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Une erreur interne est survenue',
                    'timestamp' => now()->toISOString(),
                    'request_id' => $requestId,
                ]
            ], 500);
        }
    });
})
```

---

## 19. Monitoring et Observabilité

### 19.1 Stack de Monitoring

| Composant | Outil | Objectif |
|-----------|-------|----------|
| **Crash Reporting Mobile** | Firebase Crashlytics | Erreurs et crashes app |
| **Analytics Mobile** | Firebase Analytics | Événements utilisateur |
| **Logs Backend** | Laravel Log (fichiers) | Logs applicatifs |
| **Monitoring Serveur** | OVH Monitoring | CPU, RAM, disque |
| **Uptime** | UptimeRobot (gratuit) | Disponibilité API |

### 19.2 Métriques Clés

**Métriques Frontend :**
- Crashs par session
- Temps de chargement carte
- Taux de conversion login → création question
- Sessions actives par jour

**Métriques Backend :**
- Requêtes par seconde
- Temps de réponse (p50, p95, p99)
- Taux d'erreur (4xx, 5xx)
- Requêtes de base de données lentes

---

## 20. Résultats de la Checklist

La checklist d'architecture sera exécutée lors de la validation finale du document.

| Critère | Statut | Notes |
|---------|--------|-------|
| Stack technologique défini | ✅ | Conforme au PRD |
| Architecture backend documentée | ✅ | Laravel modulaire |
| Architecture frontend documentée | ✅ | Flutter BLoC pattern |
| Modèles de données complets | ✅ | 7 entités avec relations |
| API spécifiée | ✅ | REST, tous endpoints documentés |
| Schéma base de données | ✅ | MySQL 8 avec spatial |
| Stratégie de sécurité | ✅ | OAuth, Sanctum, rate limiting |
| Stratégie de tests | ✅ | Pyramide complète |
| Plan de déploiement | ✅ | OVH VPS + Stores |
| Diagrammes inclus | ✅ | Mermaid (architecture, ERD, workflows) |

---

*Document généré le 31 janvier 2026*
*Version 1.0 - TravelConnect MVP Architecture*
*Architecte : Winston*
