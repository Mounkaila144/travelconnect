# 5. Spécification API REST

## 5.1 Vue d'Ensemble

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

## 5.2 Authentification

Tous les endpoints (sauf auth/*) nécessitent un Bearer Token dans le header :
```
Authorization: Bearer {sanctum_token}
```

## 5.3 Endpoints

## 5.3.1 Health Check

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

## 5.3.2 Authentification

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

## 5.3.3 Profil Utilisateur

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

## 5.3.4 Questions

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

## 5.3.5 Réponses

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

## 5.3.6 Signalements

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

## 5.3.7 Notifications

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

## 5.4 Codes d'Erreur

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
