# Wireframes - Écrans Secondaires

---

## Table des Matières

1. [Notifications](#1-notifications)
2. [Recherche](#2-recherche)
3. [Paramètres](#3-paramètres)
4. [Modifier le Profil](#4-modifier-le-profil)
5. [Modals et Dialogues](#5-modals-et-dialogues)
6. [États Spéciaux](#6-états-spéciaux)

---

## 1. Notifications

### 1.1 Centre de Notifications

```
┌─────────────────────────────────────┐
│  ← Notifications      ✓ Tout lire  │ <- AppBar
├─────────────────────────────────────┤
│                                     │
│  Aujourd'hui                        │ <- Section header
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ● 💬 Nouvelle réponse       │    │ <- Notification 1 (unread)
│  │                             │    │
│  │ Pierre M. a répondu à votre │    │
│  │ question sur le métro       │    │
│  │                             │    │
│  │ Il y a 5 min                │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ● 👍 Réponse utile          │    │ <- Notification 2 (unread)
│  │                             │    │
│  │ 3 personnes ont trouvé      │    │
│  │ votre réponse utile         │    │
│  │                             │    │
│  │ Il y a 2h                   │    │
│  └─────────────────────────────┘    │
│                                     │
│  Hier                               │
│                                     │
│  ┌─────────────────────────────┐    │
│  │   📍 Question proche        │    │ <- Notification 3 (read)
│  │                             │    │
│  │ Nouvelle question à 500m    │    │
│  │ de vous à Paris 9e          │    │
│  │                             │    │
│  │ Hier à 18:32               │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │   ⭐ Nouveau badge          │    │ <- Notification 4 (read)
│  │                             │    │
│  │ Vous avez gagné le badge    │    │
│  │ "Voyageur Actif"            │    │
│  │                             │    │
│  │ Hier à 10:15               │    │
│  └─────────────────────────────┘    │
│                                     │
│  [Charger plus...]                  │
│                                     │
└─────────────────────────────────────┘
```

**Spécifications :**

**AppBar :**
- **Leading** : ← Retour
- **Title** : "Notifications"
- **Actions** : "✓ Tout lire" → Marque toutes comme lues

**Types de Notifications :**

| Icône | Type | Titre | Corps |
|-------|------|-------|-------|
| 💬 | Nouvelle réponse | "Nouvelle réponse" | "[User] a répondu à votre question sur [topic]" |
| 👍 | Réponse utile | "Réponse utile" | "[X] personnes ont trouvé votre réponse utile" |
| 📍 | Question proche | "Question proche" | "Nouvelle question à [distance] de vous à [lieu]" |
| ⭐ | Badge gagné | "Nouveau badge" | "Vous avez gagné le badge '[name]'" |
| 🔔 | Système | "Info" | Messages système |

**État des Notifications :**
- **Non lue** : Fond blanc + point bleu ● + texte bold
- **Lue** : Fond gray-50 + pas de point + texte normal
- **Swipe Actions** :
  - Swipe left → "Supprimer" (rouge)
  - Swipe right → "Marquer comme lue" (bleu)

**Interactions :**
- Tap notification → Navigue vers contenu concerné
- "Tout lire" → Marque toutes comme lues
- Pull to refresh → Actualise la liste

**Empty State :**
```
┌─────────────────────────────────────┐
│                                     │
│      [Illustration: Cloche]         │
│                                     │
│    Aucune notification              │
│                                     │
│  Vous serez notifié quand quelqu'un │
│  répondra à vos questions           │
│                                     │
└─────────────────────────────────────┘
```

---

## 2. Recherche

### 2.1 Barre de Recherche Active

```
┌─────────────────────────────────────┐
│  ←  🔍 Rechercher...          ×     │ <- AppBar (search active)
├─────────────────────────────────────┤
│                                     │
│  Recherches récentes                │ <- Section
│                                     │
│  🕒 métro paris          ×          │ <- Recent search 1
│  🕒 restaurants tokyo     ×          │ <- Recent search 2
│  🕒 sécurité barcelona   ×          │ <- Recent search 3
│                                     │
│  Effacer l'historique               │ <- Link
│                                     │
├─────────────────────────────────────┤
│  Suggestions                        │
│                                     │
│  🔍 métro                           │
│  🔍 transport public                │
│  📍 Paris                           │
│  👤 Guide local Paris               │
│                                     │
└─────────────────────────────────────┘
```

### 2.2 Résultats de Recherche

```
┌─────────────────────────────────────┐
│  ←  🔍 "métro paris"          ×     │
├─────────────────────────────────────┤
│                                     │
│  Questions (12)          Tout voir  │ <- Section with count
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Est-ce que le métro...      │    │ <- Result 1
│  │ 📍 Paris 1er • 2h           │    │
│  │ 💬 5  ⭐ 4.5                │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Horaires du métro...        │    │ <- Result 2
│  │ 📍 Paris • 1j               │    │
│  │ 💬 8  ⭐ 4.2                │    │
│  └─────────────────────────────┘    │
│                                     │
│  Utilisateurs (3)        Tout voir  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Pierre M.  🏠           │    │ <- User result
│  │    ⭐⭐⭐⭐⭐ 4.9            │    │
│  │    Expert Paris Metro       │    │
│  └─────────────────────────────┘    │
│                                     │
│  Lieux (5)               Tout voir  │
│                                     │
│  📍 Métro Châtelet                  │
│  📍 Gare du Nord                    │
│  📍 Montparnasse                    │
│                                     │
└─────────────────────────────────────┘
```

**Spécifications :**

**Search Bar Active :**
- **Leading** : ← Retour
- **Input** : Text field actif, focus auto
- **Trailing** : × Effacer recherche
- **Placeholder** : "Rechercher..."

**Recherches Récentes :**
- **Affichage** : Max 5 dernières recherches
- **Actions** :
  - Tap → Lance recherche
  - Tap × → Supprime de l'historique
  - "Effacer l'historique" → Vide tout

**Suggestions :**
- **Affichage** : Pendant la frappe
- **Types** :
  - 🔍 Mots-clés
  - 📍 Lieux
  - 👤 Utilisateurs
- **Source** : Autocomplete API + historique

**Résultats :**
- **Sections** : Questions, Utilisateurs, Lieux
- **Display** : Top 3 par section
- **Action** : "Tout voir" → Liste complète filtrée

**Empty State :**
```
┌─────────────────────────────────────┐
│  🔍 "abcxyz"                        │
│                                     │
│      [Illustration: Loupe]          │
│                                     │
│    Aucun résultat trouvé            │
│                                     │
│  Essayez avec d'autres mots-clés    │
│                                     │
└─────────────────────────────────────┘
```

---

## 3. Paramètres

```
┌─────────────────────────────────────┐
│  ← Paramètres                       │
├─────────────────────────────────────┤
│                                     │
│  Compte                             │ <- Section
│                                     │
│  Modifier le profil            →    │ <- Menu item
│  Changer de mot de passe       →    │
│  Confidentialité               →    │
│                                     │
├─────────────────────────────────────┤
│  Notifications                      │
│                                     │
│  Activer les notifications     ◉    │ <- Toggle ON
│  Nouvelles réponses            ◉    │ <- Toggle ON
│  Questions proches             ○    │ <- Toggle OFF
│  Messages                      ◉    │ <- Toggle ON
│  Badges et récompenses         ○    │ <- Toggle OFF
│                                     │
├─────────────────────────────────────┤
│  Préférences                        │
│                                     │
│  Langue                             │
│  Japonais                      →    │ <- Dropdown
│                                     │
│  Unités de distance                 │
│  Kilomètres                    →    │ <- Dropdown
│                                     │
│  Thème                              │
│  Système                       →    │ <- Dropdown (Clair/Sombre/Système)
│                                     │
├─────────────────────────────────────┤
│  À propos                           │
│                                     │
│  Version                            │
│  1.0.0 (Build 100)                  │
│                                     │
│  Aide et support               →    │
│  Conditions d'utilisation      →    │
│  Politique de confidentialité  →    │
│  Licences open source          →    │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │     Déconnexion               │  │ <- Destructive button
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │   Supprimer mon compte        │  │ <- Destructive button (outlined)
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Spécifications :**

**Sections :**
1. **Compte** : Gestion profil et sécurité
2. **Notifications** : Préférences de notifications push
3. **Préférences** : Langue, unités, thème
4. **À propos** : Informations app et légal

**Menu Items :**
- **Navigation** : Icon → Text → Chevron (→)
- **Toggle** : Icon → Text → Switch (◉/○)
- **Info** : Icon → Text → Value (non cliquable)

**Toggles :**
- **Style** : Material Switch
- **Couleur** : Primary (ON) / Gray (OFF)
- **Effet** : Immédiat, avec feedback

**Actions Destructives :**
- **Déconnexion** : Red text button
- **Supprimer compte** : Red outlined button
- **Confirmation** : Dialog avant action

---

## 4. Modifier le Profil

```
┌─────────────────────────────────────┐
│  ← Modifier le profil    Enregistrer│ <- AppBar
├─────────────────────────────────────┤
│                                     │
│       ┌───────────────┐             │
│       │   [Avatar]    │             │ <- Avatar 80px
│       │   ✏️ Modifier │             │ <- Tap to change
│       └───────────────┘             │
│                                     │
│  Nom d'affichage                    │
│  ┌─────────────────────────────┐    │
│  │ Sarah Kawasaki              │    │ <- Text Input
│  └─────────────────────────────┘    │
│                                     │
│  Bio                                │
│  ┌─────────────────────────────┐    │
│  │ Voyageuse passionnée...     │    │ <- Text Area
│  │                             │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│  0/200 caractères                   │
│                                     │
│  Je suis                            │
│  ○ Voyageur    ◉ Local              │ <- Radio buttons
│                                     │
│  Localisation principale (Local)    │
│  ┌─────────────────────────────┐    │
│  │ 📍 Paris, France            │    │ <- Location picker
│  └─────────────────────────────┘    │
│                                     │
│  Langues parlées                    │
│  🇯🇵 Japonais                       │ <- Selected chips
│  🇫🇷 Français                       │
│  🇬🇧 Anglais                        │
│                                     │
│  + Ajouter une langue               │ <- Link
│                                     │
│  Centres d'intérêt                  │
│  #Culture  #Gastronomie  #Nature    │ <- Tag chips
│  #Architecture  #Histoire           │
│                                     │
│  + Ajouter un intérêt               │
│                                     │
└─────────────────────────────────────┘
```

**Spécifications :**

**AppBar :**
- **Leading** : ← Retour (demande confirmation si modifié)
- **Actions** : "Enregistrer" → Sauvegarde et ferme

**Avatar :**
- **Display** : 80px, circular
- **Action** : Tap → Bottom sheet
  - Prendre une photo
  - Choisir depuis la galerie
  - Supprimer la photo

**Champs :**

| Champ | Type | Validation |
|-------|------|------------|
| Nom | Text Input | 2-50 caractères, requis |
| Bio | Text Area | Max 200 caractères, optionnel |
| Type | Radio | Voyageur/Local, requis |
| Localisation | Picker | Requis si Local |
| Langues | Multi-select | Optionnel |
| Intérêts | Tags | Optionnel, max 10 |

**Validation :**
- Bouton "Enregistrer" disabled si invalide
- Messages d'erreur sous champs invalides
- Confirmation avant quitter si non sauvegardé

---

## 5. Modals et Dialogues

### 5.1 Modal de Réponse

```
┌─────────────────────────────────────┐
│  ×  Répondre                        │ <- Modal header
├─────────────────────────────────────┤
│                                     │
│  Question:                          │
│  "Est-ce que le métro de Paris..."  │ <- Question preview
│                                     │
├─────────────────────────────────────┤
│                                     │
│  Votre réponse                      │
│  ┌─────────────────────────────┐    │
│  │                             │    │ <- Text Area
│  │                             │    │
│  │                             │    │
│  │                             │    │
│  │ Partagez votre expérience   │    │ <- Placeholder
│  │ et vos conseils...          │    │
│  │                             │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│  0/1000 caractères                  │
│                                     │
│  💡 Astuce: Soyez précis et         │ <- Helper text
│  mentionnez des détails concrets    │
│                                     │
│                                     │
│  ┌───────────────────────────────┐  │
│  │     Publier la réponse        │  │ <- Primary Button
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 5.2 Dialog de Confirmation

```
┌─────────────────────────────────────┐
│                                     │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │  Supprimer la question?       │  │ <- Title
│  │                               │  │
│  │  Cette action est             │  │
│  │  irréversible. Toutes les     │  │ <- Body
│  │  réponses seront également    │  │
│  │  supprimées.                  │  │
│  │                               │  │
│  │  ┌────────────┬─────────────┐ │  │
│  │  │  Annuler   │  Supprimer  │ │  │ <- Actions
│  │  └────────────┴─────────────┘ │  │
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 5.3 Bottom Sheet - Menu d'Actions

```
┌─────────────────────────────────────┐
│                                     │
│  ┌───────────────────────────────┐  │
│  │         ────                  │  │ <- Handle
│  │                               │  │
│  │  📤 Partager                  │  │ <- Action 1
│  │                               │  │
│  │  🔗 Copier le lien            │  │ <- Action 2
│  │                               │  │
│  │  🔕 Désactiver notifications  │  │ <- Action 3
│  │                               │  │
│  │  ✏️ Modifier                  │  │ <- Action 4 (owner only)
│  │                               │  │
│  │  🚩 Signaler                  │  │ <- Action 5 (danger)
│  │                               │  │
│  │  🗑️ Supprimer                 │  │ <- Action 6 (destructive)
│  │                               │  │
│  │  ─────────────────────        │  │
│  │                               │  │
│  │  Annuler                      │  │ <- Cancel
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 5.4 Snackbar - Feedback

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│  [Content de l'écran]               │
│                                     │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ ✓ Question publiée avec       │  │ <- Success Snackbar
│  │   succès         [VOIR]       │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Types de Snackbars :**

| Type | Icône | Couleur | Durée |
|------|-------|---------|-------|
| Success | ✓ | Success green | 3s |
| Error | ⚠ | Error red | 4s |
| Info | ℹ | Primary blue | 3s |
| Warning | ⚠ | Warning orange | 4s |

**Spécifications :**
- **Position** : Bottom, above nav bar
- **Action** : Optionnelle ("VOIR", "ANNULER")
- **Dismiss** : Auto après durée OU swipe down

### 5.5 Loading Dialog

```
┌─────────────────────────────────────┐
│                                     │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │      [CircularProgress]       │  │ <- Spinner
│  │                               │  │
│  │    Publication en cours...    │  │ <- Message
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

---

## 6. États Spéciaux

### 6.1 État de Chargement (Skeleton)

```
┌─────────────────────────────────────┐
│  TravelConnect         🔍  📍  👤   │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ▓▓▓▓ ▓▓▓▓▓▓▓▓▓  • ▓▓▓      │    │ <- Skeleton card
│  │                             │    │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓      │    │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓               │    │
│  │                             │    │
│  │ ▓▓ ▓▓▓▓▓▓▓ • ▓▓ ▓  ▓▓ ▓▓   │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ▓▓▓▓ ▓▓▓▓▓▓▓▓▓  • ▓▓▓      │    │
│  │                             │    │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓      │    │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓               │    │
│  │                             │    │
│  │ ▓▓ ▓▓▓▓▓▓▓ • ▓▓ ▓  ▓▓ ▓▓   │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

**Spécifications :**
- **Animation** : Shimmer effect (left to right)
- **Couleur** : gray-200 → gray-100 → gray-200
- **Durée** : 1.5s loop
- **Usage** : Pendant chargement initial

### 6.2 Pull to Refresh

```
┌─────────────────────────────────────┐
│           [Spinner]                 │ <- Pulling indicator
│              ↓                      │
├─────────────────────────────────────┤
│  Forum                     🔍       │
├─────────────────────────────────────┤
│                                     │
│  [Content]                          │
│                                     │
└─────────────────────────────────────┘
```

**États :**
1. **Idle** : Scroll normal
2. **Pulling** : Affiche spinner + texte "Tirer pour actualiser"
3. **Release** : "Relâcher pour actualiser"
4. **Refreshing** : CircularProgress + "Actualisation..."
5. **Done** : Animation de completion

### 6.3 Infinite Scroll

```
┌─────────────────────────────────────┐
│                                     │
│  [Question Card]                    │
│  [Question Card]                    │
│  [Question Card]                    │
│                                     │
│  ┌───────────────────────────────┐  │
│  │    [CircularProgress]         │  │ <- Loading more
│  │    Chargement...              │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 6.4 Pas de Connexion

```
┌─────────────────────────────────────┐
│  TravelConnect         🔍  📍  👤   │
├─────────────────────────────────────┤
│                                     │
│                                     │
│      [Illustration: Cloud Off]      │
│                                     │
│     Pas de connexion                │
│                                     │
│  Vérifiez votre connexion internet  │
│  et réessayez                       │
│                                     │
│  ┌───────────────────────────────┐  │
│  │        Réessayer              │  │ <- Primary Button
│  └───────────────────────────────┘  │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

### 6.5 Permission de Localisation

```
┌─────────────────────────────────────┐
│                                     │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │  [Illustration: Location]     │  │
│  │                               │  │
│  │  Activer la localisation      │  │
│  │                               │  │
│  │  TravelConnect a besoin       │  │
│  │  d'accéder à votre position   │  │
│  │  pour afficher les questions  │  │
│  │  autour de vous               │  │
│  │                               │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │    Autoriser            │  │  │ <- Primary
│  │  └─────────────────────────┘  │  │
│  │                               │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │    Plus tard            │  │  │ <- Secondary
│  │  └─────────────────────────┘  │  │
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 6.6 Onboarding Tooltips (V2)

```
┌─────────────────────────────────────┐
│  TravelConnect         🔍  📍  👤   │
├─────────────────────────────────────┤
│   ╭──────────────────────────────╮  │
│   │ Tapez sur un marqueur pour   │  │ <- Tooltip
│   │ voir la question             │  │
│   ╰─────────┬────────────────────╯  │
│             │                       │
│     ╔═══════▼═════════════════╗    │
│     ║    [CARTE]        📍    ║    │
│     ║         📍              ║    │
│     ╚═════════════════════════╝    │
│                                     │
│                              ┌────┐ │
│                    ╭─────────┤ ➕ │ │
│                    │         └────┘ │
│  ╭─────────────────┴──────────────╮ │
│  │ Tapez ici pour poser une       │ │
│  │ nouvelle question              │ │
│  ╰────────────────────────────────╯ │
│                                     │
└─────────────────────────────────────┘
```

---

## 7. Composants Réutilisables

### 7.1 Avatar Component

**Tailles :**
```
XS:  24px  (liste, inline)
SM:  40px  (cards, comments)
MD:  56px  (profil preview)
LG:  80px  (profil header)
XL:  120px (profil édition)
```

**Variants :**
- Photo user
- Initiales (si pas de photo)
- Placeholder (default avatar)
- Badge overlay (bottom-right pour Voyageur/Local)

### 7.2 Badge Component

```
┌──────────┐
│ ✈️ Voyageur │  <- Pill shape, primary color
└──────────┘

┌──────────┐
│ 🏠 Local   │  <- Pill shape, secondary color
└──────────┘

✓ Vérifié    <- Small, gold color
```

### 7.3 Trust Score Component

**Variants :**

Small (inline):
```
⭐⭐⭐⭐☆ 4.2
```

Medium (cards):
```
⭐⭐⭐⭐⭐
4.9 (24 avis)
```

Large (profil):
```
  ⭐ ⭐ ⭐ ⭐ ⭐
     4.5 / 5.0
   Basé sur 156 avis
```

### 7.4 Location Display

```
📍 Paris 9e - Pigalle    <- Compact

📍 Paris 9e - Pigalle    <- With distance
   À 500m de vous
```

### 7.5 Time Display

**Formats :**
- < 1h : "Il y a X min"
- < 24h : "Il y a X h"
- < 7j : "Il y a X j"
- > 7j : "Le [date]"

---

## 8. Patterns d'Interaction

### 8.1 Gestures

| Geste | Action | Contexte |
|-------|--------|----------|
| Tap | Sélectionner / Ouvrir | Partout |
| Long press | Menu contextuel | Cards, liste items |
| Swipe left | Action destructive (supprimer) | Liste items |
| Swipe right | Action positive (marquer lu) | Notifications |
| Swipe down | Rafraîchir | Listes scrollables |
| Swipe up | Fermer modal | Bottom sheets |
| Pinch | Zoom | Carte |
| Double tap | Zoom rapide | Carte |

### 8.2 Navigation Patterns

**Forward Navigation :**
- Slide left (nouvelle page)
- Fade + scale (modal)
- Slide up (bottom sheet)

**Backward Navigation :**
- Slide right (back)
- Fade out (modal close)
- Slide down (sheet dismiss)

### 8.3 Feedback Patterns

| Action | Feedback |
|--------|----------|
| Button tap | Ripple effect + scale 0.95 |
| Success action | Snackbar + haptic |
| Error | Snackbar + shake animation |
| Loading | CircularProgress OU skeleton |
| Vote | Icon animation (scale + color) |
| Badge earned | Confetti + modal |

---

## 9. Responsive Breakpoints

**Mobile (Primary) :**
- Small: 320-375px (iPhone SE, small Android)
- Medium: 375-428px (iPhone standard)
- Large: 428+px (iPhone Pro Max, large Android)

**Adaptations :**

| Size | Card Padding | Font Scale | Bottom Nav Height |
|------|--------------|------------|-------------------|
| Small | 12px | 0.9x | 56px |
| Medium | 16px | 1.0x | 64px |
| Large | 20px | 1.1x | 72px |

---

## 10. Accessibilité

### 10.1 Screen Reader Labels

**Exemples :**
```dart
Semantics(
  label: 'Question: Est-ce que le métro de Paris accepte les cartes sans contact',
  hint: 'Appuyez pour voir les détails et les réponses',
  child: QuestionCard(...),
)
```

### 10.2 Contraste de Couleurs

Tous les paires texte/fond respectent **WCAG AA** :
- Texte normal : 4.5:1 minimum
- Texte large : 3:1 minimum
- Composants UI : 3:1 minimum

### 10.3 Tailles de Touche

**Minimums :**
- Zone tactile : 48x48dp (Android) / 44x44pt (iOS)
- Espacement entre zones : 8dp minimum

---

*Wireframes Secondaires TravelConnect v1.0*
*Créé par Sally, UX Expert - Janvier 2026*
