# Wireframes - Écrans Principaux

---

## Table des Matières

1. [Login & Authentification](#1-login--authentification)
2. [Onboarding](#2-onboarding)
3. [Carte Interactive (Écran Principal)](#3-carte-interactive-écran-principal)
4. [Fil d'Actualité / Forum](#4-fil-dactualité--forum)
5. [Détail de Question](#5-détail-de-question)
6. [Créer une Question](#6-créer-une-question)
7. [Profil Utilisateur](#7-profil-utilisateur)

---

## 1. Login & Authentification

### 1.1 Écran de Login

```
┌─────────────────────────────────────┐
│                                     │
│            [Logo App]               │
│          TravelConnect              │
│                                     │
│     Votre ami local dans chaque     │
│         ville du monde              │
│                                     │
│                                     │
│   [Illustration Voyage Amicale]     │
│                                     │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  🔵 Continuer avec Google    │  │ <- Primary Button
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  🍎 Continuer avec Apple     │  │ <- Primary Button
│  └───────────────────────────────┘  │
│                                     │
│                                     │
│  En continuant, vous acceptez nos   │
│  Conditions d'utilisation           │
│                                     │
└─────────────────────────────────────┘
```

**Spécifications :**
- **Statut** : Non authentifié
- **Navigation** : Aucune (écran de démarrage)
- **Actions** :
  - Connexion avec Google → OAuth flow
  - Connexion avec Apple → OAuth flow
  - Lien vers Conditions → Modal Web
- **États** :
  - Default : Boutons actifs
  - Loading : CircularProgress sur bouton cliqué
  - Error : Snackbar avec message d'erreur

**Interactions :**
1. User tape sur "Continuer avec Google"
2. OAuth flow s'ouvre
3. User autorise l'app
4. Backend crée/récupère le profil
5. Si nouveau user → Onboarding
6. Si user existant → Carte principale

---

## 2. Onboarding

### 2.1 Écran 1/3 - Bienvenue

```
┌─────────────────────────────────────┐
│  [×]                          1/3   │ <- Close + Indicateur
│                                     │
│                                     │
│    [Illustration: Globe + Points]   │
│                                     │
│                                     │
│     Posez vos questions,            │
│     où que vous soyez               │
│                                     │
│   Des locaux et voyageurs vous      │
│   répondent en temps réel           │
│                                     │
│                                     │
│   ● ○ ○                             │ <- Pagination dots
│                                     │
│  ┌───────────────────────────────┐  │
│  │        Suivant                │  │ <- Primary Button
│  └───────────────────────────────┘  │
│                                     │
│         Passer l'introduction       │ <- Text Button
│                                     │
└─────────────────────────────────────┘
```

### 2.2 Écran 2/3 - Fonctionnalités

```
┌─────────────────────────────────────┐
│  [×]                          2/3   │
│                                     │
│                                     │
│  [Illustration: Carte + Marqueurs]  │
│                                     │
│                                     │
│    Découvrez les questions          │
│    autour de vous                   │
│                                     │
│   Explorez la carte ou parcourez    │
│   le forum pour trouver des         │
│   réponses authentiques             │
│                                     │
│                                     │
│   ○ ● ○                             │
│                                     │
│  ┌───────────────────────────────┐  │
│  │        Suivant                │  │
│  └───────────────────────────────┘  │
│                                     │
│         Passer l'introduction       │
│                                     │
└─────────────────────────────────────┘
```

### 2.3 Écran 3/3 - Profil

```
┌─────────────────────────────────────┐
│  [×]                          3/3   │
│                                     │
│                                     │
│    Complétez votre profil           │
│                                     │
│       ┌──────────────┐              │
│       │   [Photo]    │              │ <- Tap to upload
│       │    +Ajouter  │              │
│       └──────────────┘              │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Nom d'affichage               │  │ <- Text Input
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Bio (optionnel)               │  │ <- Text Area
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Je suis :                          │
│  ○ Voyageur    ○ Local              │ <- Radio buttons
│                                     │
│  ┌───────────────────────────────┐  │
│  │      Commencer                │  │ <- Primary Button
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Spécifications :**
- **Flux** : 3 écrans swipables
- **Navigation** :
  - Swipe left/right entre écrans
  - Bouton "Suivant" → Écran suivant
  - "Passer" → Va directement au profil (écran 3)
  - "Commencer" → Sauvegarde profil → Carte principale
- **Validation** :
  - Nom requis (2-50 caractères)
  - Photo optionnelle
  - Bio optionnelle (max 200 caractères)
  - Type (Voyageur/Local) requis

---

## 3. Carte Interactive (Écran Principal)

```
┌─────────────────────────────────────┐
│  TravelConnect         🔍  📍  👤   │ <- AppBar
├─────────────────────────────────────┤
│                                     │
│     ╔══════════════════════════╗    │
│     ║    [CARTE INTERACTIVE]   ║    │
│     ║                          ║    │
│     ║   📍 📍    📍           ║    │ <- Question markers
│     ║        📍               ║    │
│     ║ 📍          📍  📍     ║    │
│     ║                          ║    │
│     ║     [Ma Position]        ║    │
│     ║          ●               ║    │
│     ║                          ║    │
│     ║    📍       📍          ║    │
│     ╚══════════════════════════╝    │
│                                     │
│  ┌────────────────────────────┐     │
│  │ 📍 Ce quartier est-il sûr? │ <── │ <- Question card (bottom sheet preview)
│  │ Paris 9e • Il y a 2h       │     │
│  │ 3 réponses • ⭐ 4.2        │     │
│  └────────────────────────────┘     │
│                                     │
│                              ┌────┐ │
│                              │ ➕ │ │ <- FAB (Create Question)
│                              └────┘ │
├─────────────────────────────────────┤
│  🗺️   💬    🔔    👤               │ <- Bottom Nav
│ Carte Forum Notif Profil           │
└─────────────────────────────────────┘
```

**Spécifications :**

**AppBar (Top) :**
- **Titre** : "TravelConnect" (Headline Small)
- **Actions** :
  - 🔍 Recherche → Ouvre barre de recherche
  - 📍 Centrer sur ma position → Recentre la carte
  - 👤 Profil → Navigation vers profil

**Carte :**
- **Provider** : Google Maps / Mapbox
- **Markers** :
  - Bleu (📍) : Questions non répondues
  - Teal (📍) : Questions avec réponses
  - Coral (📍) : Question sélectionnée
  - Cercle avec nombre : Cluster de questions
- **Interactions** :
  - Pinch to zoom
  - Drag to pan
  - Tap marker → Affiche preview card
  - Tap sur carte (vide) → Cache preview card

**Preview Card (Bottom Sheet) :**
- **Contenu** :
  - Question (1 ligne, ellipsis)
  - Localisation + Temps écoulé
  - Nombre de réponses + Score moyen
- **Actions** :
  - Swipe up → Ouvre détail complet
  - Tap → Ouvre détail complet
  - Swipe down → Cache la card

**FAB (Floating Action Button) :**
- **Position** : Bottom-right, 16px des bords
- **Action** : Ouvre "Créer une question"
- **Icône** : ➕ (add)
- **Couleur** : Accent (coral)

**Bottom Navigation :**
- **Items** :
  1. 🗺️ Carte (selected)
  2. 💬 Forum
  3. 🔔 Notifications (badge si nouveau)
  4. 👤 Profil

**États :**
- **Loading** : Skeleton placeholders pour markers
- **Empty** : "Aucune question dans cette zone. Soyez le premier !"
- **Error** : Snackbar "Impossible de charger la carte"
- **No Location Permission** : Modal demandant l'autorisation

---

## 4. Fil d'Actualité / Forum

```
┌─────────────────────────────────────┐
│  ← Forum                  🔍        │ <- AppBar
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │ 🔍 Rechercher...            │    │ <- Search bar
│  └─────────────────────────────┘    │
│                                     │
│  🌍 Toutes destinations  ▼          │ <- Filter dropdown
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Sarah K.  ✈️  • 2h       │    │ <- Question Card 1
│  │                             │    │
│  │ Est-ce que le métro de      │    │
│  │ Paris accepte les cartes... │    │
│  │                             │    │
│  │ 📍 Paris 1er                │    │
│  │ 💬 5 réponses  ⭐ 4.5       │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Ken T.  🏠  • 5h         │    │ <- Question Card 2
│  │                             │    │
│  │ Recommandations de          │    │
│  │ restaurants locaux près...  │    │
│  │                             │    │
│  │ 📍 Tokyo, Shibuya           │    │
│  │ 💬 12 réponses  ⭐ 4.8      │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Marie L.  ✈️  • 1j       │    │ <- Question Card 3
│  │                             │    │
│  │ Quartiers à éviter la nuit  │    │
│  │ à Barcelone?                │    │
│  │                             │    │
│  │ 📍 Barcelona                │    │
│  │ 💬 8 réponses  ⭐ 4.0       │    │
│  └─────────────────────────────┘    │
│                                     │
│                              ┌────┐ │
│                              │ ➕ │ │ <- FAB
│                              └────┘ │
├─────────────────────────────────────┤
│  🗺️   💬    🔔    👤               │
│ Carte Forum Notif Profil           │
│       ●                             │ <- Selected indicator
└─────────────────────────────────────┘
```

**Spécifications :**

**AppBar :**
- **Leading** : Titre "Forum"
- **Trailing** : 🔍 Recherche

**Search Bar :**
- **Placeholder** : "Rechercher..."
- **Action** : Filtre en temps réel les questions

**Filtres :**
- **Destination** : Dropdown menu
  - Toutes destinations
  - Liste des destinations avec questions
- **Tri** (future) : Plus récentes, Plus de réponses, Meilleures notes

**Question Cards :**
- **Header** :
  - Avatar (40px, circular)
  - Nom utilisateur
  - Badge (✈️ Voyageur / 🏠 Local)
  - Temps écoulé
- **Body** :
  - Texte question (3 lignes max, ellipsis)
- **Footer** :
  - 📍 Localisation
  - 💬 Nombre de réponses
  - ⭐ Score moyen
- **Interaction** :
  - Tap → Ouvre détail de question

**Liste :**
- **Scroll** : Infini avec lazy loading
- **Pull to refresh** : Rafraîchit la liste
- **Spacing** : 12px entre cards
- **Empty State** : "Aucune question pour l'instant. Soyez le premier à poser une question!"

**Loading States :**
- Skeleton cards pendant chargement initial
- Loader en bas pendant infinite scroll

---

## 5. Détail de Question

```
┌─────────────────────────────────────┐
│  ←                    ⋮             │ <- AppBar: Back + Menu
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐   │
│  │ 👤 Sarah K.  ✈️  • 2h       │   │ <- Question Header
│  │    ⭐⭐⭐⭐☆ 4.2            │   │
│  └──────────────────────────────┘   │
│                                     │
│  Est-ce que le métro de Paris       │ <- Question Text
│  accepte les cartes bancaires sans  │
│  contact ou faut-il acheter un      │
│  ticket physique?                   │
│                                     │
│  📍 Paris 1er - Châtelet            │ <- Location
│                                     │
│  #transport #paris #metro           │ <- Tags (optional)
│                                     │
├─────────────────────────────────────┤
│  5 Réponses                         │ <- Section Header
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐   │
│  │ 👤 Pierre M.  🏠            │   │ <- Answer 1 (Best)
│  │    ⭐⭐⭐⭐⭐ 4.9            │   │
│  │ ✓ Meilleure réponse         │   │
│  │                             │   │
│  │ Oui, presque toutes les     │   │
│  │ stations acceptent les      │   │
│  │ paiements sans contact...   │   │
│  │                             │   │
│  │ 👍 12  • Il y a 1h          │   │
│  └──────────────────────────────┘   │
│                                     │
│  ┌──────────────────────────────┐   │
│  │ 👤 Emma L.  ✈️              │   │ <- Answer 2
│  │    ⭐⭐⭐⭐☆ 4.5            │   │
│  │                             │   │
│  │ Je confirme! J'ai utilisé   │   │
│  │ ma carte tout le mois...    │   │
│  │                             │   │
│  │ 👍 8  • Il y a 3h           │   │
│  └──────────────────────────────┘   │
│                                     │
│  [Voir 3 autres réponses...]        │ <- Collapsed answers
│                                     │
├─────────────────────────────────────┤
│  ┌────────────────────────────┐     │
│  │ Écrire une réponse...      │  ↗ │ <- Reply Input
│  └────────────────────────────┘     │
└─────────────────────────────────────┘
```

**Spécifications :**

**AppBar :**
- **Leading** : ← Retour
- **Trailing** : ⋮ Menu (Partager, Signaler, Supprimer si owner)

**Question Section :**
- **Header** :
  - Avatar + Nom + Badge + Temps
  - Score de confiance (étoiles)
- **Body** :
  - Texte complet (pas de truncation)
  - Location avec icône
  - Tags (optionnel, V2)
- **Actions** (menu) :
  - Partager
  - Signaler
  - Supprimer (si propriétaire)

**Answers Section :**
- **Header** : "X Réponses" (tri par helpful votes)
- **Answer Card** :
  - Avatar + Nom + Badge
  - Score de confiance
  - Badge "Meilleure réponse" si la plus utile
  - Texte de la réponse
  - 👍 Compteur de votes + Temps écoulé
- **Interaction** :
  - Tap 👍 → Vote helpful (toggle)
  - Long press → Menu (Signaler)
- **Collapsed Answers** :
  - Affiche top 2 réponses par défaut
  - "Voir X autres réponses" → Expand all

**Reply Input :**
- **Placeholder** : "Écrire une réponse..."
- **Action** : Tap → Ouvre modal de réponse complète
- **Icon** : ↗ Envoyer

**Empty State (No Answers) :**
```
┌─────────────────────────────────────┐
│  Aucune réponse pour l'instant      │
│                                     │
│  [Illustration: Chat vide]          │
│                                     │
│  Soyez le premier à répondre!       │
│                                     │
│  ┌───────────────────────────────┐  │
│  │     Répondre                  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## 6. Créer une Question

```
┌─────────────────────────────────────┐
│  ×  Nouvelle question               │ <- Modal Header
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Votre question              │    │ <- Text Area
│  │                             │    │
│  │                             │    │
│  │ Ex: Ce quartier est-il sûr  │    │ <- Placeholder
│  │ pour une femme seule?       │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│  0/500 caractères                   │ <- Counter
│                                     │
│  Localisation                       │
│  ┌─────────────────────────────┐    │
│  │ 📍 Paris 9e - Pigalle       │ ◉  │ <- Location input
│  └─────────────────────────────┘    │
│  ○ Utiliser ma position actuelle    │ <- Radio
│  ○ Choisir une autre localisation   │ <- Radio
│                                     │
│  ┌─────────────────────────────┐    │
│  │ [Mini Carte Preview]        │    │ <- Map preview (small)
│  │        ●                    │    │
│  └─────────────────────────────┘    │
│                                     │
│  Catégorie (optionnel)              │
│  ○ Transport  ○ Restaurant          │ <- Chips
│  ○ Logement   ○ Sécurité            │
│  ○ Autre                            │
│                                     │
│                                     │
│  ┌───────────────────────────────┐  │
│  │     Publier la question       │  │ <- Primary Button
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Spécifications :**

**Modal :**
- **Présentation** : Bottom sheet modal, full height
- **Header** :
  - × Fermer (gauche)
  - "Nouvelle question" (titre)
- **Dismiss** : Swipe down ou tap ×

**Question Input :**
- **Type** : Text Area, multi-lignes
- **Validation** :
  - Minimum 10 caractères
  - Maximum 500 caractères
- **Placeholder** : Exemple de bonne question
- **Counter** : Live character count

**Localisation :**
- **Options** :
  - ○ Position actuelle (par défaut)
  - ○ Autre localisation (ouvre search)
- **Display** : 📍 Nom du lieu
- **Map Preview** : Mini carte (150px height) avec marker
- **Search** : Autocomplete Google Places API

**Catégorie :**
- **Optionnel** : Pas requis pour MVP
- **Chips** : Single select
- **Options** : Transport, Restaurant, Logement, Sécurité, Autre

**Bouton Publier :**
- **États** :
  - Disabled : Si question trop courte
  - Loading : CircularProgress pendant POST
  - Success → Ferme modal → Navigue vers question créée
  - Error → Snackbar "Erreur lors de la publication"

**Validation :**
- Question : 10-500 caractères ✓
- Localisation : Requise ✓
- Catégorie : Optionnelle

---

## 7. Profil Utilisateur

```
┌─────────────────────────────────────┐
│  ← Profil                 ⚙️        │ <- AppBar
├─────────────────────────────────────┤
│                                     │
│       ┌───────────────┐             │
│       │   [Avatar]    │             │ <- Avatar 80px
│       │               │             │
│       └───────────────┘             │
│                                     │
│        Sarah Kawasaki               │ <- Name (Title Large)
│            ✈️ Voyageur              │ <- Badge
│                                     │
│      ⭐⭐⭐⭐☆ 4.2 (24 avis)        │ <- Trust Score
│                                     │
│  Voyageuse passionnée, toujours     │ <- Bio
│  à la recherche de nouvelles        │
│  aventures et rencontres...         │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────┬──────────┬─────────┐  │
│  │    8     │    24    │   156   │  │ <- Stats
│  │ Questions│ Réponses │ Helpful │  │
│  └──────────┴──────────┴─────────┘  │
│                                     │
├─────────────────────────────────────┤
│  Mes Questions                      │ <- Section
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Est-ce que le métro...      │    │ <- Question preview
│  │ 📍 Paris 1er • 2h           │    │
│  │ 💬 5  ⭐ 4.5                │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Recommandations de...       │    │
│  │ 📍 Tokyo • 1j               │    │
│  │ 💬 12  ⭐ 4.8               │    │
│  └─────────────────────────────┘    │
│                                     │
│  [Voir toutes les questions]        │ <- Link
│                                     │
├─────────────────────────────────────┤
│  Mes Réponses Utiles                │ <- Section
│                                     │
│  ┌─────────────────────────────┐    │
│  │ "Oui, presque toutes les... │    │ <- Answer preview
│  │ Sur: Métro Paris            │    │
│  │ 👍 12 • Il y a 1h           │    │
│  └─────────────────────────────┘    │
│                                     │
│  [Voir toutes les réponses]         │
│                                     │
└─────────────────────────────────────┘
```

**Spécifications :**

**AppBar :**
- **Leading** : ← Retour (si autre profil) ou Titre
- **Trailing** : ⚙️ Paramètres (si mon profil)

**Profile Header :**
- **Avatar** : 80px, circular, tap to edit (si mon profil)
- **Name** : Title Large, bold
- **Badge** : ✈️ Voyageur ou 🏠 Local + ✓ Vérifié
- **Trust Score** :
  - Étoiles visuelles
  - Score numérique (4.2/5)
  - Nombre d'avis entre parenthèses
- **Bio** : Body Medium, gray-600, max 3 lignes

**Stats Section :**
- **3 colonnes égales** :
  - Questions postées
  - Réponses données
  - Votes "Helpful" reçus
- **Style** : Chiffre large (Title Large) + Label (Label Small)

**Mes Questions :**
- **Affichage** : Top 2 questions récentes
- **Card** : Version compacte avec :
  - Titre question (1 ligne)
  - Location + Temps
  - Nb réponses + Score
- **Action** : "Voir toutes" → Liste complète

**Mes Réponses Utiles :**
- **Affichage** : Top 2 réponses les plus votées
- **Card** :
  - Extrait réponse (2 lignes)
  - "Sur: [Question title]"
  - Votes + Temps
- **Action** : "Voir toutes" → Liste complète

**Tabs (V2) :**
- Questions | Réponses | Enregistrés

**Actions (Menu Paramètres) :**
- Modifier le profil
- Préférences
- Notifications
- Confidentialité
- Aide
- Déconnexion

---

## Navigation & Transitions

### Flow Principal

```
Login
  ↓
Onboarding (si nouveau)
  ↓
Carte (Home)
  ├→ Question Detail
  │   └→ Create Answer
  ├→ Create Question
  ├→ Forum
  │   └→ Question Detail
  ├→ Notifications
  │   └→ Question Detail
  └→ Profile
      ├→ Settings
      └→ Edit Profile
```

### Transitions

| De → Vers | Type | Durée |
|-----------|------|-------|
| Login → Onboarding | Fade | 300ms |
| Onboarding slides | Slide horizontal | 300ms |
| Bottom Nav | Fade + Slide | 200ms |
| Question Card → Detail | Slide up | 300ms |
| Create Question Modal | Slide up | 300ms |
| Back navigation | Slide right | 300ms |

---

## États et Variations

### Loading States

```
Carte:
├─ Skeleton markers (pulsing)
└─ Shimmer sur preview card

Forum:
├─ Skeleton cards (3x)
└─ Content shimmer effect

Profil:
├─ Avatar shimmer
└─ Stats placeholder
```

### Empty States

| Écran | Illustration | Message | CTA |
|-------|--------------|---------|-----|
| Carte (no questions) | 🗺️ | "Aucune question ici" | "Posez la première" |
| Forum (no results) | 🔍 | "Aucun résultat" | "Modifier les filtres" |
| Notifications | 🔔 | "Pas de notifications" | - |
| Profile Questions | 💬 | "Vous n'avez pas encore posé de question" | "Poser une question" |

### Error States

```
┌─────────────────────────────────────┐
│                                     │
│      [Illustration: Erreur]         │
│                                     │
│    Une erreur est survenue          │
│                                     │
│  Impossible de charger le contenu   │
│                                     │
│  ┌───────────────────────────────┐  │
│  │        Réessayer              │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

---

*Wireframes Principaux TravelConnect v1.0*
*Créé par Sally, UX Expert - Janvier 2026*
