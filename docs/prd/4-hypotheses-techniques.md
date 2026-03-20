# Hypothèses Techniques

## Structure du Repository

**Architecture : Polyrepo (2 repositories séparés)**

| Repository | Technologie | Description |
|------------|-------------|-------------|
| `travelconnect-api` | Laravel (PHP 8.2+) | Backend API REST |
| `travelconnect-app` | Flutter (Dart 3.0+) | Application mobile cross-platform |

**Justification :** Séparation claire des responsabilités, déploiement indépendant, équipes potentiellement distinctes à l'avenir.

## Architecture des Services

**Architecture : Monolithe modulaire**

```
┌─────────────────────────────────────────────────────┐
│                   Flutter App                        │
│              (iOS + Android)                         │
└─────────────────────┬───────────────────────────────┘
                      │ HTTPS/REST
                      ▼
┌─────────────────────────────────────────────────────┐
│              Laravel API (Monolithe)                 │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐  │
│  │  Auth   │ │ Questions│ │ Profils │ │Notifications│ │
│  │ Module  │ │  Module  │ │ Module  │ │  Module   │  │
│  └─────────┘ └─────────┘ └─────────┘ └───────────┘  │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│                  MySQL 8.0+                          │
│            (avec extensions spatiales)               │
└─────────────────────────────────────────────────────┘
```

**Justification :** Pour un MVP avec budget limité et un seul développeur, un monolithe Laravel bien structuré offre rapidité de développement, simplicité de déploiement et facilité de maintenance.

## Stack Technologique Détaillé

| Couche | Technologie | Version | Justification |
|--------|-------------|---------|---------------|
| **Mobile** | Flutter | 3.x | Cross-platform, UI riche, performance native, écosystème mature |
| **Backend** | Laravel | 10.x/11.x | Framework PHP robuste, écosystème riche, API REST rapide |
| **Base de données** | MySQL | 8.0+ | Support spatial natif (ST_Distance, ST_Within), fiable |
| **Authentification** | Laravel Sanctum + Socialite | - | Tokens API sécurisés + OAuth Google/Apple |
| **Notifications Push** | Firebase Cloud Messaging (FCM) | - | Gratuit, fiable iOS/Android, intégration Flutter simple |
| **Cartes** | Google Maps SDK | - | Fiabilité, documentation, familiarité utilisateurs japonais |
| **Stockage média** | OVH Object Storage | - | Photos profil, coût maîtrisé |
| **Hébergement** | OVH VPS | - | Serveurs Europe, bon rapport qualité/prix |
| **CI/CD** | GitHub Actions | - | Intégration native, gratuit pour repos privés |

## Exigences de Tests

**Stratégie : Tests unitaires + Tests d'intégration API**

| Type de Test | Couverture Cible | Outils |
|--------------|------------------|--------|
| Tests unitaires Backend | 70% des services critiques | PHPUnit |
| Tests d'intégration API | Endpoints principaux | Laravel HTTP Tests |
| Tests unitaires Flutter | Widgets critiques | Flutter Test |
| Tests manuels | Parcours utilisateur complets | Checklist QA |

**Priorité MVP :**
1. Tests des endpoints d'authentification
2. Tests CRUD questions/réponses
3. Tests calcul score de confiance
4. Tests géolocalisation

## Hypothèses Techniques Additionnelles

- **Géolocalisation** : Utilisation des fonctions spatiales MySQL 8 (ST_Distance_Sphere) pour les requêtes de proximité
- **Temps réel** : Pas de WebSocket pour MVP — polling ou push notifications suffisants
- **Cache** : Redis optionnel pour MVP, cache Laravel fichier acceptable initialement
- **Modération** : Interface admin Laravel simple (pas de package externe)
- **Emails** : Pas d'emails transactionnels pour MVP (notifications push uniquement)
- **Analytics** : Firebase Analytics pour le tracking de base
- **Crash Reporting** : Firebase Crashlytics
