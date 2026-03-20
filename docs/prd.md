# TravelConnect - Document des Exigences Produit (PRD)

---

## 1. Objectifs et Contexte

### 1.1 Objectifs

- **G1:** Réduire l'anxiété des voyageurs en fournissant un accès en temps réel à des conseils humains de locaux et voyageurs expérimentés
- **G2:** Créer une plateforme communautaire de confiance où les voyageurs peuvent poser des questions géolocalisées et recevoir des réponses personnalisées
- **G3:** Atteindre 10 000 utilisateurs actifs mensuels (MAU) dans les 6 mois suivant le lancement
- **G4:** Recruter 500+ Local Supporters vérifiés dans 10 destinations populaires (Paris, Séoul, Taipei, Bangkok, Singapour, Hawaii, LA, NYC, Londres, Sydney)
- **G5:** Obtenir un taux de réponse moyen < 2 heures pour 80% des questions
- **G6:** Valider le product-market fit avec un NPS > 50 avant de chercher un financement externe
- **G7:** Livrer un MVP fonctionnel dans le budget de 3 000€ HT

### 1.2 Contexte

TravelConnect répond à un vide fondamental dans l'expérience de voyage : l'absence de connexion humaine authentique et de conseils fiables en temps réel. Les voyageurs, particulièrement à l'international, font face à l'anxiété liée au manque d'informations fiables, aux barrières linguistiques et à l'isolement.

Les solutions actuelles présentent des limites significatives :
- **Google Maps** : Information factuelle sans conseil humain personnalisé
- **TripAdvisor** : Avis souvent faux, pas d'interaction directe
- **Forums (Reddit)** : Réponses tardives, non géolocalisées, anonymes
- **Guides de voyage** : Statiques, génériques, rapidement obsolètes
- **ChatGPT/IA** : Pas de vécu réel, peut halluciner, manque d'authenticité

La reprise du tourisme international post-COVID présente une opportunité de timing idéale. Les voyageurs japonais (18M+ voyages/an pré-COVID) recherchent activement des solutions pour voyager avec confiance. La proposition de valeur de TravelConnect — « Des humains, pas des algorithmes » — répond directement à ce besoin d'authenticité et de réassurance.

### 1.3 Journal des Modifications

| Date | Version | Description | Auteur |
|------|---------|-------------|--------|
| 2026-01-31 | 1.0 | Création initiale du PRD depuis le Brief Projet | John (PM) |

---

## 2. Exigences

### 2.1 Exigences Fonctionnelles

- **FR1:** Le système doit afficher une carte interactive avec les questions géolocalisées visibles sous forme de marqueurs
- **FR2:** Les utilisateurs doivent pouvoir publier une question liée à leur position actuelle ou à une destination future
- **FR3:** Les utilisateurs doivent pouvoir répondre aux questions avec du texte
- **FR4:** Chaque utilisateur doit avoir un profil simplifié comprenant : nom, photo, bio courte, badge (Voyageur/Local), pays d'origine
- **FR5:** Le système doit calculer et afficher un score de confiance pour chaque utilisateur basé sur les évaluations de ses réponses
- **FR6:** Les utilisateurs doivent recevoir des notifications push pour les nouvelles réponses à leurs questions et les nouvelles questions dans leur zone
- **FR7:** Le système doit afficher un fil d'actualité/forum listant les questions récentes par destination
- **FR8:** Les utilisateurs doivent pouvoir s'authentifier via Google ou Apple Sign-In
- **FR9:** Les utilisateurs doivent pouvoir noter les réponses reçues (système d'évaluation)
- **FR10:** Les utilisateurs doivent pouvoir signaler du contenu inapproprié
- **FR11:** Le système doit permettre aux administrateurs de modérer et supprimer le contenu signalé
- **FR12:** Les utilisateurs doivent pouvoir filtrer les questions par destination/zone géographique
- **FR13:** Le système doit afficher le temps écoulé depuis la publication de chaque question/réponse
- **FR14:** Les utilisateurs doivent pouvoir uploader une photo de profil depuis leur galerie ou appareil photo

### 2.2 Exigences Non-Fonctionnelles

- **NFR1:** Le chargement de la carte doit être inférieur à 3 secondes sur connexion 4G
- **NFR2:** Le temps de réponse API doit être inférieur à 500ms pour 95% des requêtes
- **NFR3:** L'application doit supporter iOS 15+ et Android 10+ (API 29)
- **NFR4:** L'application doit fonctionner en japonais pour le MVP
- **NFR5:** Le système doit supporter 10 000 utilisateurs actifs mensuels sans dégradation de performance
- **NFR6:** Les données utilisateurs doivent être chiffrées en transit (HTTPS) et au repos
- **NFR7:** Le système doit implémenter un rate limiting pour prévenir les abus
- **NFR8:** L'application doit respecter les guidelines Apple App Store et Google Play Store
- **NFR9:** Le backend doit être hébergé sur OVH avec une disponibilité de 99.5%
- **NFR10:** Les tokens d'authentification doivent expirer après 30 jours d'inactivité
- **NFR11:** Le système doit conserver les logs d'activité pendant 90 jours minimum
- **NFR12:** L'application doit consommer moins de 100MB de stockage sur l'appareil

---

## 3. Objectifs de Conception d'Interface Utilisateur

### 3.1 Vision UX Globale

TravelConnect doit offrir une expérience rassurante, simple et chaleureuse. L'interface doit transmettre un sentiment de communauté et de confiance, rappelant l'échange avec un ami local plutôt qu'une interaction avec une application froide.

**Principes directeurs :**
- **Simplicité** : Navigation intuitive, pas de surcharge cognitive
- **Confiance** : Mise en avant des scores de réputation et badges vérifiés
- **Proximité** : Design chaleureux favorisant la connexion humaine
- **Efficacité** : Accès rapide aux fonctionnalités essentielles (poser une question, voir les réponses)

### 3.2 Paradigmes d'Interaction Clés

- **Carte-centrée** : La carte interactive est le point d'entrée principal pour découvrir les questions par localisation
- **Feed secondaire** : Liste chronologique des questions comme navigation alternative
- **Action flottante** : Bouton FAB pour poster rapidement une question
- **Pull-to-refresh** : Actualisation intuitive du contenu
- **Swipe actions** : Gestes naturels pour les actions rapides (noter, signaler)

### 3.3 Écrans et Vues Principales

| Écran | Description | Priorité |
|-------|-------------|----------|
| **Carte interactive** | Vue principale avec marqueurs des questions géolocalisées | P0 |
| **Fil d'actualité** | Liste des questions récentes filtrables par destination | P0 |
| **Détail question** | Question complète avec ses réponses et système de notation | P0 |
| **Nouvelle question** | Formulaire de publication avec sélection de localisation | P0 |
| **Profil utilisateur** | Informations, badge, score de confiance, historique | P0 |
| **Notifications** | Centre des alertes (nouvelles réponses, questions proches) | P1 |
| **Paramètres** | Configuration compte, notifications, langue | P1 |
| **Onboarding** | Écrans de bienvenue et création de profil | P1 |

### 3.4 Accessibilité

**Niveau cible : WCAG AA**
- Contraste suffisant pour la lisibilité
- Tailles de texte adaptables
- Support VoiceOver (iOS) et TalkBack (Android)
- Labels accessibles sur tous les éléments interactifs

### 3.5 Branding

- **Palette** : Couleurs évoquant le voyage et la confiance (bleus, verts naturels, accents chaleureux)
- **Typographie** : Police lisible, moderne et amicale
- **Iconographie** : Style cohérent, simple et reconnaissable
- **Ton** : Amical, rassurant, inclusif

*Note : UI standard Flutter pour le MVP, design sur-mesure prévu pour V2*

### 3.6 Plateformes et Appareils Cibles

**Plateformes :** iOS + Android (application Flutter cross-platform)

| Plateforme | Version Minimum | Priorité |
|------------|-----------------|----------|
| iOS | 15.0+ | P0 |
| Android | 10+ (API 29) | P0 |
| Web | Non prioritaire | Hors scope MVP |

**Responsive :** Support des tailles d'écran de 4.7" à 6.7" (smartphones uniquement pour MVP)

---

## 4. Hypothèses Techniques

### 4.1 Structure du Repository

**Architecture : Polyrepo (2 repositories séparés)**

| Repository | Technologie | Description |
|------------|-------------|-------------|
| `travelconnect-api` | Laravel (PHP 8.2+) | Backend API REST |
| `travelconnect-app` | Flutter (Dart 3.0+) | Application mobile cross-platform |

**Justification :** Séparation claire des responsabilités, déploiement indépendant, équipes potentiellement distinctes à l'avenir.

### 4.2 Architecture des Services

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

### 4.3 Stack Technologique Détaillé

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

### 4.4 Exigences de Tests

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

### 4.5 Hypothèses Techniques Additionnelles

- **Géolocalisation** : Utilisation des fonctions spatiales MySQL 8 (ST_Distance_Sphere) pour les requêtes de proximité
- **Temps réel** : Pas de WebSocket pour MVP — polling ou push notifications suffisants
- **Cache** : Redis optionnel pour MVP, cache Laravel fichier acceptable initialement
- **Modération** : Interface admin Laravel simple (pas de package externe)
- **Emails** : Pas d'emails transactionnels pour MVP (notifications push uniquement)
- **Analytics** : Firebase Analytics pour le tracking de base
- **Crash Reporting** : Firebase Crashlytics

---

## 5. Liste des Epics

| Epic | Titre | Objectif |
|------|-------|----------|
| **Epic 1** | Fondation & Authentification | Établir l'infrastructure projet, l'authentification sociale et le profil utilisateur de base |
| **Epic 2** | Carte & Questions | Implémenter la carte interactive et le système de publication de questions géolocalisées |
| **Epic 3** | Réponses & Réputation | Permettre les réponses aux questions, le système de notation et le calcul du score de confiance |
| **Epic 4** | Notifications & Engagement | Implémenter les notifications push et le fil d'actualité pour maximiser l'engagement |
| **Epic 5** | Administration & Lancement | Créer l'interface d'administration, finaliser les tests et déployer sur les stores |

---

## 6. Détail des Epics

### Epic 1 : Fondation & Authentification

**Objectif :** Établir les bases techniques du projet avec une infrastructure robuste, un système d'authentification sociale fonctionnel (Google/Apple) et la gestion complète du profil utilisateur. Cette epic pose les fondations sur lesquelles toutes les fonctionnalités suivantes seront construites.

---

#### Story 1.1 : Configuration initiale du projet

**En tant que** développeur,
**Je veux** avoir une structure de projet Laravel et Flutter configurée avec Git,
**Afin de** pouvoir commencer le développement sur des bases solides.

**Critères d'acceptation :**
1. Le repository `travelconnect-api` est créé avec Laravel 10+ initialisé
2. Le repository `travelconnect-app` est créé avec Flutter 3.x initialisé
3. Les fichiers .gitignore appropriés sont configurés pour chaque repository
4. Le fichier README.md documente les instructions de setup pour chaque projet
5. La structure de dossiers Laravel suit les conventions (Controllers, Models, Services)
6. La connexion à une base de données MySQL locale est fonctionnelle
7. Une route health-check `/api/health` retourne un status 200 avec timestamp

---

#### Story 1.2 : Authentification Google Sign-In

**En tant qu'** utilisateur,
**Je veux** pouvoir me connecter avec mon compte Google,
**Afin d'** accéder rapidement à l'application sans créer un nouveau compte.

**Critères d'acceptation :**
1. L'écran de login affiche un bouton "Continuer avec Google" clairement visible
2. Le flux OAuth Google s'ouvre dans un navigateur sécurisé (pas WebView)
3. Après autorisation Google, l'utilisateur est redirigé vers l'app avec un token valide
4. Le backend crée automatiquement un compte utilisateur à la première connexion
5. Le token d'authentification est stocké de manière sécurisée sur l'appareil
6. Les connexions suivantes utilisent le token stocké sans redemander l'autorisation
7. Un message d'erreur clair s'affiche si l'authentification échoue
8. L'endpoint `/api/auth/google` accepte le token Google et retourne un token Sanctum

---

#### Story 1.3 : Authentification Apple Sign-In

**En tant qu'** utilisateur iOS,
**Je veux** pouvoir me connecter avec mon compte Apple,
**Afin de** respecter mes préférences de confidentialité Apple.

**Critères d'acceptation :**
1. L'écran de login affiche un bouton "Continuer avec Apple" (style officiel Apple)
2. Le flux Apple Sign-In natif iOS s'ouvre correctement
3. L'option "Hide My Email" d'Apple est supportée
4. Le backend gère correctement les emails relayés Apple
5. Le compte utilisateur est créé avec le nom fourni par Apple (ou "Utilisateur" par défaut)
6. L'endpoint `/api/auth/apple` accepte le token Apple et retourne un token Sanctum
7. Sur Android, le bouton Apple n'est pas affiché

---

#### Story 1.4 : Création et affichage du profil utilisateur

**En tant qu'** utilisateur connecté,
**Je veux** avoir un profil avec mes informations de base,
**Afin que** les autres utilisateurs puissent me connaître et me faire confiance.

**Critères d'acceptation :**
1. À la première connexion, l'utilisateur est dirigé vers un écran de complétion de profil
2. Le profil contient : nom d'affichage, photo, bio courte (max 150 caractères), pays
3. L'utilisateur peut choisir son type : "Voyageur" ou "Local Supporter"
4. Un badge visuel distinct indique le type d'utilisateur (Voyageur/Local)
5. La photo de profil peut être uploadée depuis la galerie ou l'appareil photo
6. Les photos sont redimensionnées à 400x400px avant upload
7. L'écran "Mon profil" affiche toutes les informations avec le score de confiance (initialisé à 0)
8. L'endpoint GET `/api/user/profile` retourne les données du profil connecté
9. L'endpoint PUT `/api/user/profile` permet de modifier les informations

---

#### Story 1.5 : Déconnexion et gestion de session

**En tant qu'** utilisateur connecté,
**Je veux** pouvoir me déconnecter de l'application,
**Afin de** sécuriser mon compte sur un appareil partagé.

**Critères d'acceptation :**
1. Un bouton "Déconnexion" est accessible dans les paramètres
2. Une confirmation est demandée avant déconnexion
3. Le token local est supprimé après déconnexion
4. Le token est invalidé côté serveur
5. L'utilisateur est redirigé vers l'écran de login
6. L'endpoint POST `/api/auth/logout` invalide le token courant

---

### Epic 2 : Carte & Questions

**Objectif :** Implémenter le cœur de l'expérience TravelConnect : une carte interactive affichant les questions géolocalisées et permettant aux utilisateurs de publier leurs propres questions. Cette epic transforme l'application en un outil utile pour les voyageurs.

---

#### Story 2.1 : Affichage de la carte interactive

**En tant qu'** utilisateur,
**Je veux** voir une carte interactive de ma zone,
**Afin de** visualiser les questions posées autour de moi.

**Critères d'acceptation :**
1. La carte Google Maps s'affiche en plein écran comme vue principale
2. La carte se centre sur la position actuelle de l'utilisateur au chargement
3. L'utilisateur peut zoomer, dézoomer et naviguer sur la carte
4. Un bouton "Ma position" permet de recentrer sur la localisation actuelle
5. La permission de géolocalisation est demandée avec une explication claire
6. Si la permission est refusée, la carte affiche une position par défaut (Tokyo)
7. Le chargement de la carte prend moins de 3 secondes sur 4G

---

#### Story 2.2 : Affichage des marqueurs de questions

**En tant qu'** utilisateur,
**Je veux** voir des marqueurs sur la carte représentant les questions,
**Afin de** découvrir ce que les voyageurs demandent dans une zone.

**Critères d'acceptation :**
1. Les questions sont représentées par des marqueurs distinctifs sur la carte
2. Les marqueurs affichent un aperçu (icône + indicateur de nombre de réponses)
3. Les questions sans réponse ont un marqueur d'une couleur différente (urgence visuelle)
4. Cliquer sur un marqueur affiche une info-bulle avec le titre de la question
5. Cliquer sur l'info-bulle ouvre le détail complet de la question
6. Le clustering s'active automatiquement quand les marqueurs sont trop proches
7. L'endpoint GET `/api/questions?lat={lat}&lng={lng}&radius={km}` retourne les questions dans le rayon
8. Maximum 100 questions sont chargées à la fois (pagination)

---

#### Story 2.3 : Publication d'une nouvelle question

**En tant qu'** utilisateur,
**Je veux** pouvoir poster une question liée à un lieu,
**Afin d'** obtenir des conseils de locaux ou voyageurs expérimentés.

**Critères d'acceptation :**
1. Un bouton flottant (FAB) "+" est toujours visible sur la carte
2. Cliquer sur le FAB ouvre un formulaire de nouvelle question
3. Le formulaire contient : titre (obligatoire, max 100 car.), description (max 500 car.)
4. La localisation est pré-remplie avec la position actuelle
5. L'utilisateur peut ajuster la localisation en déplaçant un marqueur sur une mini-carte
6. Un bouton "Publier" envoie la question
7. Une confirmation visuelle s'affiche après publication réussie
8. La nouvelle question apparaît immédiatement sur la carte
9. L'endpoint POST `/api/questions` crée une nouvelle question
10. Les champs titre et localisation sont validés côté serveur

---

#### Story 2.4 : Affichage du détail d'une question

**En tant qu'** utilisateur,
**Je veux** voir le détail complet d'une question,
**Afin de** comprendre le contexte et lire les réponses.

**Critères d'acceptation :**
1. L'écran détail affiche : titre, description, localisation sur mini-carte
2. L'auteur est affiché avec sa photo, nom, badge et score de confiance
3. La date de publication est affichée en format relatif ("il y a 2h")
4. Le nombre de réponses est indiqué
5. La liste des réponses s'affiche sous la question (voir Epic 3)
6. Un bouton "Répondre" est visible en bas de l'écran
7. L'endpoint GET `/api/questions/{id}` retourne la question avec ses réponses

---

#### Story 2.5 : Mes questions

**En tant qu'** utilisateur,
**Je veux** voir la liste des questions que j'ai posées,
**Afin de** suivre les réponses reçues.

**Critères d'acceptation :**
1. Un onglet "Mes questions" est accessible depuis le profil
2. La liste affiche mes questions triées par date (récentes en premier)
3. Chaque item montre : titre, localisation, nombre de réponses, date
4. Un indicateur visuel signale les nouvelles réponses non lues
5. Cliquer sur une question ouvre son détail
6. L'endpoint GET `/api/user/questions` retourne les questions de l'utilisateur connecté

---

### Epic 3 : Réponses & Réputation

**Objectif :** Compléter le cycle d'interaction communautaire en permettant aux utilisateurs de répondre aux questions et de noter les réponses. Le système de score de confiance différencie TravelConnect des solutions anonymes existantes.

---

#### Story 3.1 : Répondre à une question

**En tant qu'** utilisateur,
**Je veux** pouvoir répondre à une question,
**Afin d'** aider un voyageur avec mon expérience.

**Critères d'acceptation :**
1. Le bouton "Répondre" sur le détail question ouvre un champ de saisie
2. La réponse accepte du texte (max 1000 caractères)
3. Un compteur de caractères indique la limite
4. Le bouton "Envoyer" publie la réponse
5. La réponse apparaît immédiatement dans la liste
6. L'auteur de la question reçoit une notification (voir Epic 4)
7. L'endpoint POST `/api/questions/{id}/answers` crée une réponse
8. Un utilisateur peut poster plusieurs réponses à la même question

---

#### Story 3.2 : Affichage des réponses

**En tant qu'** utilisateur,
**Je veux** voir toutes les réponses à une question,
**Afin de** bénéficier des différents points de vue.

**Critères d'acceptation :**
1. Les réponses s'affichent sous la question, triées par pertinence (score puis date)
2. Chaque réponse montre : texte, auteur (photo, nom, badge, score), date
3. La note moyenne de la réponse est affichée (étoiles)
4. Les réponses de Local Supporters sont visuellement mises en avant
5. Un indicateur montre si l'utilisateur a déjà noté cette réponse
6. La pagination charge les réponses supplémentaires au scroll

---

#### Story 3.3 : Noter une réponse

**En tant qu'** utilisateur,
**Je veux** pouvoir noter une réponse,
**Afin d'** indiquer sa qualité et aider au calcul du score de confiance.

**Critères d'acceptation :**
1. Chaque réponse affiche un système de notation (1-5 étoiles)
2. L'utilisateur peut noter en tapant sur les étoiles
3. La note est enregistrée immédiatement avec feedback visuel
4. L'utilisateur peut modifier sa note
5. L'auteur d'une réponse ne peut pas noter sa propre réponse
6. La note moyenne est recalculée après chaque vote
7. L'endpoint POST `/api/answers/{id}/rate` enregistre la note
8. L'endpoint retourne la nouvelle moyenne

---

#### Story 3.4 : Calcul et affichage du score de confiance

**En tant qu'** utilisateur,
**Je veux** voir le score de confiance des autres utilisateurs,
**Afin de** juger la fiabilité de leurs conseils.

**Critères d'acceptation :**
1. Le score de confiance est affiché sur chaque profil et à côté de chaque réponse
2. Le score est calculé selon : moyenne des notes reçues × log(nombre de réponses + 1)
3. Le score est affiché sur une échelle de 0 à 5 avec une décimale
4. Les nouveaux utilisateurs affichent "Nouveau" au lieu d'un score
5. Le score est recalculé automatiquement après chaque nouvelle note
6. Un tooltip explique le calcul du score au tap

---

#### Story 3.5 : Signalement de contenu

**En tant qu'** utilisateur,
**Je veux** pouvoir signaler un contenu inapproprié,
**Afin de** maintenir une communauté saine.

**Critères d'acceptation :**
1. Un bouton "Signaler" (icône drapeau) est accessible sur chaque question et réponse
2. Cliquer ouvre un menu avec les raisons : Spam, Contenu offensant, Information fausse, Autre
3. L'utilisateur peut ajouter un commentaire optionnel
4. Une confirmation s'affiche après le signalement
5. Le contenu signalé est marqué pour revue dans l'admin
6. L'endpoint POST `/api/reports` crée un signalement
7. Un utilisateur ne peut signaler le même contenu qu'une fois

---

### Epic 4 : Notifications & Engagement

**Objectif :** Maximiser l'engagement et la réactivité de la communauté grâce aux notifications push et au fil d'actualité. Ces fonctionnalités sont essentielles pour atteindre l'objectif de temps de réponse < 2h.

---

#### Story 4.1 : Configuration Firebase Cloud Messaging

**En tant que** développeur,
**Je veux** intégrer Firebase Cloud Messaging,
**Afin d'** envoyer des notifications push aux utilisateurs.

**Critères d'acceptation :**
1. Le projet Firebase est configuré pour iOS et Android
2. L'app Flutter demande la permission de notifications au premier lancement
3. Le token FCM de chaque appareil est envoyé et stocké au backend
4. Le backend peut envoyer des notifications via l'API Firebase Admin
5. Les notifications sont reçues app en foreground et background
6. L'endpoint POST `/api/user/fcm-token` enregistre le token FCM

---

#### Story 4.2 : Notifications de nouvelles réponses

**En tant qu'** auteur d'une question,
**Je veux** recevoir une notification quand quelqu'un répond,
**Afin de** ne pas manquer les conseils reçus.

**Critères d'acceptation :**
1. Une notification push est envoyée à l'auteur quand une réponse est postée
2. La notification contient : "Nouvelle réponse à [titre question]" + aperçu
3. Cliquer sur la notification ouvre le détail de la question
4. Les notifications sont envoyées même si l'app est fermée
5. L'utilisateur peut désactiver ce type de notification dans les paramètres

---

#### Story 4.3 : Notifications de questions proches

**En tant que** Local Supporter,
**Je veux** être notifié des nouvelles questions dans ma zone,
**Afin de** pouvoir aider rapidement les voyageurs.

**Critères d'acceptation :**
1. Les Local Supporters peuvent définir leur zone d'intérêt (ville/rayon)
2. Une notification est envoyée quand une question est postée dans cette zone
3. La notification contient : "Nouvelle question près de [lieu]" + titre
4. Maximum 5 notifications par jour pour éviter le spam
5. L'utilisateur peut ajuster le rayon ou désactiver dans les paramètres
6. L'endpoint PUT `/api/user/notification-zone` configure la zone

---

#### Story 4.4 : Fil d'actualité des questions

**En tant qu'** utilisateur,
**Je veux** voir une liste des questions récentes,
**Afin de** découvrir les questions sans utiliser la carte.

**Critères d'acceptation :**
1. Un onglet "Forum" est accessible depuis la navigation principale
2. Le fil affiche les questions récentes triées par date
3. Chaque item montre : titre, localisation, auteur, nombre de réponses, temps écoulé
4. Un filtre permet de sélectionner une destination/ville
5. Pull-to-refresh actualise la liste
6. Scroll infini charge les questions plus anciennes
7. Cliquer sur une question ouvre son détail
8. L'endpoint GET `/api/questions?sort=recent&city={city}` supporte le filtrage

---

#### Story 4.5 : Centre de notifications

**En tant qu'** utilisateur,
**Je veux** voir l'historique de mes notifications,
**Afin de** retrouver les alertes que j'ai manquées.

**Critères d'acceptation :**
1. Une icône cloche dans la navigation indique les notifications non lues
2. Un badge numérique montre le nombre de non lues
3. L'écran notifications liste toutes les alertes reçues
4. Les notifications non lues sont visuellement distinctes
5. Cliquer sur une notification la marque comme lue et ouvre le contenu lié
6. L'endpoint GET `/api/notifications` retourne les notifications de l'utilisateur
7. L'endpoint POST `/api/notifications/{id}/read` marque comme lue

---

### Epic 5 : Administration & Lancement

**Objectif :** Créer les outils d'administration nécessaires à la modération, finaliser les tests et préparer le déploiement sur les stores iOS et Android. Cette epic aboutit au lancement public de l'application.

---

#### Story 5.1 : Interface d'administration - Authentification

**En tant qu'** administrateur,
**Je veux** accéder à une interface d'administration sécurisée,
**Afin de** gérer le contenu et les utilisateurs.

**Critères d'acceptation :**
1. Une page de login admin est accessible à `/admin`
2. L'authentification utilise email/mot de passe (pas OAuth)
3. Les comptes admin sont créés manuellement en base de données
4. La session admin expire après 8 heures d'inactivité
5. Le tableau de bord affiche les statistiques clés (utilisateurs, questions, réponses)
6. L'interface est responsive et utilisable sur mobile

---

#### Story 5.2 : Modération du contenu signalé

**En tant qu'** administrateur,
**Je veux** voir et traiter les contenus signalés,
**Afin de** maintenir la qualité de la communauté.

**Critères d'acceptation :**
1. Une liste affiche tous les signalements non traités, triés par date
2. Chaque signalement montre : contenu, raison, commentaire, signaleur
3. L'admin peut voir le contenu complet en contexte
4. Actions disponibles : Approuver (ignorer signalement), Supprimer contenu, Bannir utilisateur
5. Un champ permet d'ajouter une note interne
6. Le statut du signalement est mis à jour après action
7. L'historique des actions de modération est conservé

---

#### Story 5.3 : Gestion des utilisateurs

**En tant qu'** administrateur,
**Je veux** pouvoir gérer les utilisateurs,
**Afin de** traiter les cas problématiques.

**Critères d'acceptation :**
1. Une liste affiche tous les utilisateurs avec recherche par nom/email
2. Le profil complet de chaque utilisateur est consultable
3. L'historique des questions et réponses est visible
4. Actions disponibles : Bannir (temporaire/permanent), Retirer badge Local
5. L'utilisateur banni ne peut plus se connecter
6. L'historique des actions est conservé avec timestamp et admin

---

#### Story 5.4 : Configuration du serveur de production

**En tant que** développeur,
**Je veux** déployer l'API sur un serveur OVH de production,
**Afin que** l'application soit accessible aux utilisateurs.

**Critères d'acceptation :**
1. Un VPS OVH est provisionné avec les specs minimales requises
2. Nginx est configuré comme reverse proxy avec HTTPS (Let's Encrypt)
3. PHP-FPM est configuré pour Laravel
4. MySQL 8 est installé et sécurisé
5. Les variables d'environnement de production sont configurées
6. Les migrations de base de données sont exécutées
7. L'API répond correctement sur le domaine de production
8. Les logs sont configurés pour rotation automatique

---

#### Story 5.5 : Déploiement sur App Store (iOS)

**En tant que** développeur,
**Je veux** soumettre l'application sur l'App Store,
**Afin que** les utilisateurs iOS puissent la télécharger.

**Critères d'acceptation :**
1. Le build de production Flutter iOS est généré et signé
2. Les assets App Store sont préparés (icône, screenshots, description)
3. La politique de confidentialité est publiée et liée
4. Le formulaire App Store Connect est complété en japonais
5. L'application passe la review Apple
6. L'app est publiée en "Disponible au Japon" initialement

---

#### Story 5.6 : Déploiement sur Google Play (Android)

**En tant que** développeur,
**Je veux** soumettre l'application sur Google Play,
**Afin que** les utilisateurs Android puissent la télécharger.

**Critères d'acceptation :**
1. Le build de production Flutter Android (AAB) est généré et signé
2. Les assets Play Store sont préparés (icône, screenshots, description)
3. La politique de confidentialité est liée
4. Le formulaire Play Console est complété en japonais
5. Le questionnaire de classification du contenu est rempli
6. L'application passe la review Google
7. L'app est publiée en "Disponible au Japon" initialement

---

## 7. Résultats de la Checklist

*Cette section sera complétée après la revue finale du PRD par la checklist PM.*

| Critère | Statut | Notes |
|---------|--------|-------|
| Objectifs SMART définis | ✅ | 7 objectifs mesurables |
| Exigences fonctionnelles complètes | ✅ | 14 FR couvrant le MVP |
| Exigences non-fonctionnelles définies | ✅ | 12 NFR incluant performance et sécurité |
| Personas et utilisateurs cibles identifiés | ✅ | Via le brief (Voyageur Anxieux-Curieux + Local Supporter) |
| Épics séquentielles et logiques | ✅ | 5 épics avec dépendances claires |
| Stories avec critères d'acceptation | ✅ | 21 stories avec AC détaillés |
| Contraintes techniques documentées | ✅ | Stack, budget, timeline définis |
| Risques identifiés | ✅ | Via le brief (Chicken & Egg, temps réponse, etc.) |

---

## 8. Prochaines Étapes

### 8.1 Prompt pour l'Expert UX

```
Bonjour ! Je travaille sur TravelConnect, une application mobile communautaire
qui connecte les voyageurs avec des locaux et voyageurs expérimentés pour
obtenir des conseils en temps réel.

Veuillez créer les wireframes et le design system pour le MVP en vous basant
sur le PRD (docs/prd.md).

Points clés à considérer :
- Cible principale : voyageurs japonais (25-45 ans)
- UI standard Flutter acceptable pour MVP
- Carte interactive comme vue principale
- Système de confiance/réputation visible
- Accessibilité WCAG AA

Merci de proposer les wireframes des écrans principaux et les guidelines
de design pour assurer une expérience rassurante et intuitive.
```

### 8.2 Prompt pour l'Architecte

```
Bonjour ! Veuillez créer le document d'architecture technique pour TravelConnect
en vous basant sur le PRD (docs/prd.md).

Stack technique défini :
- Mobile : Flutter (iOS + Android)
- Backend : Laravel 10+ (API REST)
- Base de données : MySQL 8+ avec extensions spatiales
- Authentification : Laravel Sanctum + Socialite (Google/Apple)
- Notifications : Firebase Cloud Messaging
- Cartes : Google Maps SDK
- Hébergement : OVH VPS

Points critiques à adresser :
- Architecture API REST et structure des endpoints
- Schéma de base de données avec support géospatial
- Stratégie d'authentification et sécurité
- Architecture Flutter (state management, structure)
- Plan de déploiement CI/CD

Merci de produire une architecture détaillée permettant de commencer
le développement immédiatement.
```

---

*Document généré le 31 janvier 2026*
*Version 1.0 - TravelConnect MVP*
