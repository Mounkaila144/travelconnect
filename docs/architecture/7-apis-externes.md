# 7. APIs Externes

## 7.1 Google OAuth 2.0

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

## 7.2 Apple Sign-In

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

## 7.3 Firebase Cloud Messaging (FCM)

- **Objectif :** Notifications push iOS et Android
- **Documentation :** https://firebase.google.com/docs/cloud-messaging
- **Base URL :** https://fcm.googleapis.com/v1
- **Authentification :** Service Account JWT
- **Rate Limits :** Pas de limite pour messages individuels

**Endpoints Utilisés :**
- `POST /projects/{project}/messages:send` - Envoi notification

**Notes d'Intégration :** Utilisation du package `kreait/firebase-php` pour Laravel. Configuration projet Firebase requise pour iOS (APNs) et Android.

---

## 7.4 Google Maps Platform

- **Objectif :** Affichage carte, markers, geocoding
- **Documentation :** https://developers.google.com/maps
- **Authentification :** API Key
- **Rate Limits :** Selon plan tarifaire (crédit mensuel gratuit de $200)

**Services Utilisés :**
- Maps SDK for iOS/Android - Carte interactive
- Geocoding API - Reverse geocoding pour location_name

**Notes d'Intégration :** API Key restreinte par package name (Android) et bundle ID (iOS). Optimisation des appels geocoding via cache.

---

## 7.5 OVH Object Storage (S3-compatible)

- **Objectif :** Stockage photos de profil
- **Documentation :** https://docs.ovh.com/gb/en/storage/object-storage-swift-api/
- **Base URL :** https://s3.{region}.cloud.ovh.net
- **Authentification :** AWS Signature V4 (S3 compatible)
- **Rate Limits :** Pas de limite, facturation à l'usage

**Opérations Utilisées :**
- `PUT /{bucket}/{key}` - Upload image
- `DELETE /{bucket}/{key}` - Suppression image

**Notes d'Intégration :** Utilisation du package `league/flysystem-aws-s3-v3` avec Laravel Filesystem.
