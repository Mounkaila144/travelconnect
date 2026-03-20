# Design System TravelConnect

---

## 1. Fondations

### 1.1 Philosophie de Design

**"Un ami local dans chaque ville du monde"**

Notre design system incarne les valeurs fondamentales de TravelConnect :
- **Confiance** : Des indicateurs visuels clairs de réputation et de fiabilité
- **Chaleur** : Une esthétique accueillante qui favorise la connexion humaine
- **Simplicité** : Une navigation intuitive, sans surcharge cognitive
- **Authenticité** : Un design qui célèbre la diversité culturelle du voyage

### 1.2 Principes de Design

| Principe | Description |
|----------|-------------|
| **User-First** | Chaque décision sert l'utilisateur, pas l'esthétique |
| **Clarity Over Cleverness** | Préférer la clarté à l'originalité |
| **Consistent But Not Rigid** | Cohérent mais adaptable aux contextes |
| **Accessible By Default** | L'accessibilité n'est pas une option |
| **Mobile-Native** | Conçu pour le tactile et les petits écrans |

---

## 2. Palette de Couleurs

### 2.1 Couleurs Primaires

```
Primary Blue - La Confiance
├── primary-50:   #E3F2FD  (backgrounds légers)
├── primary-100:  #BBDEFB  (hover states)
├── primary-200:  #90CAF9  (disabled states)
├── primary-300:  #64B5F6
├── primary-400:  #42A5F5
├── primary-500:  #2196F3  ★ Principal
├── primary-600:  #1E88E5  (hover on primary)
├── primary-700:  #1976D2  (pressed states)
├── primary-800:  #1565C0
└── primary-900:  #0D47A1  (dark mode primary)
```

### 2.2 Couleurs Secondaires

```
Teal - L'Exploration
├── secondary-50:   #E0F2F1
├── secondary-100:  #B2DFDB
├── secondary-200:  #80CBC4
├── secondary-300:  #4DB6AC
├── secondary-400:  #26A69A
├── secondary-500:  #009688  ★ Principal
├── secondary-600:  #00897B
├── secondary-700:  #00796B
├── secondary-800:  #00695C
└── secondary-900:  #004D40
```

### 2.3 Couleurs Accent

```
Coral - La Chaleur Humaine
├── accent-light:   #FFAB91
├── accent-main:    #FF7043  ★ Principal
└── accent-dark:    #E64A19

Gold - La Confiance (badges, ratings)
├── gold-light:     #FFE082
├── gold-main:      #FFC107  ★ Principal
└── gold-dark:      #FFA000
```

### 2.4 Couleurs Sémantiques

```
Success (Réponse validée, action réussie)
├── success-light:  #C8E6C9
├── success-main:   #4CAF50
└── success-dark:   #388E3C

Warning (Attention requise)
├── warning-light:  #FFF3E0
├── warning-main:   #FF9800
└── warning-dark:   #F57C00

Error (Erreurs, suppressions)
├── error-light:    #FFEBEE
├── error-main:     #F44336
└── error-dark:     #D32F2F

Info (Informations)
├── info-light:     #E3F2FD
├── info-main:      #2196F3
└── info-dark:      #1976D2
```

### 2.5 Neutres

```
Grays - Interface
├── gray-50:    #FAFAFA  (backgrounds)
├── gray-100:   #F5F5F5  (cards, surfaces)
├── gray-200:   #EEEEEE  (dividers)
├── gray-300:   #E0E0E0  (borders)
├── gray-400:   #BDBDBD  (placeholder text)
├── gray-500:   #9E9E9E  (icons disabled)
├── gray-600:   #757575  (secondary text)
├── gray-700:   #616161
├── gray-800:   #424242  (body text)
└── gray-900:   #212121  (headings)

Special
├── white:      #FFFFFF
├── black:      #000000
└── overlay:    rgba(0, 0, 0, 0.5)
```

### 2.6 Implémentation Flutter

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Primary
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color primaryDark = Color(0xFF1976D2);

  // Secondary
  static const Color secondary = Color(0xFF009688);
  static const Color secondaryLight = Color(0xFFB2DFDB);
  static const Color secondaryDark = Color(0xFF00796B);

  // Accent
  static const Color accent = Color(0xFFFF7043);
  static const Color gold = Color(0xFFFFC107);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // Neutrals
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
}
```

---

## 3. Typographie

### 3.1 Police Principale

**Noto Sans JP** - Police principale pour le japonais et les caractères latins

Avantages :
- Support complet japonais (hiragana, katakana, kanji)
- Excellente lisibilité sur mobile
- Gratuite via Google Fonts
- Multiples graisses disponibles

### 3.2 Échelle Typographique

```
Display Large    - 57px / 64px line-height / -0.25 letter-spacing
Display Medium   - 45px / 52px / 0
Display Small    - 36px / 44px / 0

Headline Large   - 32px / 40px / 0
Headline Medium  - 28px / 36px / 0
Headline Small   - 24px / 32px / 0  ★ Titres d'écran

Title Large      - 22px / 28px / 0
Title Medium     - 16px / 24px / 0.15  ★ Sous-titres
Title Small      - 14px / 20px / 0.1

Body Large       - 16px / 24px / 0.5  ★ Texte principal
Body Medium      - 14px / 20px / 0.25
Body Small       - 12px / 16px / 0.4

Label Large      - 14px / 20px / 0.1  ★ Boutons
Label Medium     - 12px / 16px / 0.5
Label Small      - 11px / 16px / 0.5  ★ Badges, captions
```

### 3.3 Hiérarchie des Titres

| Usage | Style | Poids | Taille |
|-------|-------|-------|--------|
| Titre de page | Headline Small | Bold (700) | 24px |
| Titre de section | Title Large | SemiBold (600) | 22px |
| Titre de carte | Title Medium | Medium (500) | 16px |
| Corps de texte | Body Large | Regular (400) | 16px |
| Texte secondaire | Body Medium | Regular (400) | 14px |
| Labels/Captions | Label Small | Medium (500) | 11px |

### 3.4 Implémentation Flutter

```dart
// lib/core/theme/app_typography.dart
class AppTypography {
  static const String fontFamily = 'Noto Sans JP';

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );
}
```

---

## 4. Espacement et Grille

### 4.1 Système d'Espacement (Base 4px)

```
spacing-0:    0px
spacing-1:    4px   (micro-espacements)
spacing-2:    8px   (entre éléments liés)
spacing-3:    12px  (intra-composant)
spacing-4:    16px  ★ Unité de base, padding standard
spacing-5:    20px
spacing-6:    24px  (entre sections)
spacing-8:    32px  (séparation majeure)
spacing-10:   40px
spacing-12:   48px  (marges de page)
spacing-16:   64px  (sections majeures)
```

### 4.2 Marges de Page

```
Page margins (mobile):
├── Horizontal: 16px (spacing-4)
├── Top: 16px + SafeArea
└── Bottom: 16px + SafeArea + NavigationBar

Card padding:
├── Standard: 16px
└── Compact: 12px
```

### 4.3 Implémentation Flutter

```dart
// lib/core/theme/app_spacing.dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Horizontal page padding
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: base);

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(base);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);
}
```

---

## 5. Iconographie

### 5.1 Bibliothèque d'Icônes

**Material Symbols Rounded** - Style arrondi pour cohérence avec le design chaleureux

### 5.2 Tailles d'Icônes

```
icon-xs:   16px  (inline avec texte)
icon-sm:   20px  (actions secondaires)
icon-md:   24px  ★ Taille standard
icon-lg:   32px  (navigation principale)
icon-xl:   48px  (états vides, onboarding)
```

### 5.3 Icônes Clés de l'Application

| Usage | Icône | Nom Material |
|-------|-------|--------------|
| Carte | 🗺️ | map |
| Questions | 💬 | forum |
| Profil | 👤 | person |
| Notifications | 🔔 | notifications |
| Ajouter question | ➕ | add |
| Localisation | 📍 | location_on |
| Étoile (rating) | ⭐ | star |
| Voyageur | ✈️ | flight |
| Local | 🏠 | home |
| Recherche | 🔍 | search |
| Paramètres | ⚙️ | settings |
| Répondre | ↩️ | reply |
| Partager | 📤 | share |
| Signaler | 🚩 | flag |

### 5.4 Badges Utilisateur

```
Badge Voyageur:
├── Icône: flight + cercle bleu
├── Couleur: primary-500
└── Taille: 24x24px

Badge Local:
├── Icône: home + cercle teal
├── Couleur: secondary-500
└── Taille: 24x24px

Badge Vérifié:
├── Icône: verified
├── Couleur: gold-main
└── Taille: 16x16px (accompagne le badge principal)
```

---

## 6. Composants UI

### 6.1 Boutons

#### Primary Button
```
Specs:
├── Height: 48px
├── Padding: 24px horizontal
├── Border-radius: 24px (pill shape)
├── Background: primary-500
├── Text: white, Label Large
├── Shadow: elevation-2

States:
├── Default: primary-500
├── Hover: primary-600
├── Pressed: primary-700
├── Disabled: gray-300, text gray-500
└── Loading: primary-500 + CircularProgress
```

#### Secondary Button (Outlined)
```
Specs:
├── Height: 48px
├── Border: 1px primary-500
├── Background: transparent
├── Text: primary-500, Label Large

States:
├── Default: border primary-500
├── Hover: background primary-50
├── Pressed: background primary-100
└── Disabled: border gray-300, text gray-500
```

#### Text Button
```
Specs:
├── Height: 40px
├── Padding: 12px horizontal
├── Background: transparent
├── Text: primary-500, Label Large
```

#### FAB (Floating Action Button)
```
Specs:
├── Size: 56px
├── Border-radius: 16px
├── Background: accent (coral)
├── Icon: white, 24px
├── Shadow: elevation-3

Position:
├── Bottom-right
├── 16px from edges
└── Above bottom navigation
```

### 6.2 Cards

#### Question Card
```
Specs:
├── Background: white
├── Border-radius: 12px
├── Padding: 16px
├── Shadow: elevation-1
├── Margin-bottom: 12px

Structure:
├── Header: Avatar + Username + Badge + Time
├── Content: Question text (max 3 lines)
├── Location: Icon + Place name
├── Footer: Answers count + Rating
```

#### Profile Card
```
Specs:
├── Background: white
├── Border-radius: 16px
├── Padding: 24px
├── Shadow: elevation-2

Structure:
├── Avatar: 80px, centered
├── Name: Title Large
├── Badge: Voyageur/Local
├── Trust Score: Stars + numeric
├── Bio: Body Medium, gray-600
└── Stats: Questions | Answers | Helpful
```

### 6.3 Navigation

#### Bottom Navigation Bar
```
Specs:
├── Height: 80px (includes safe area)
├── Background: white
├── Shadow: elevation-4 (top shadow)
├── Items: 4 max

Items:
├── Carte (map) - default selected
├── Forum (forum)
├── Notifications (notifications)
└── Profil (person)

States:
├── Selected: primary-500, icon filled
├── Unselected: gray-500, icon outlined
└── Badge: red dot for notifications
```

#### App Bar
```
Specs:
├── Height: 56px
├── Background: white
├── Shadow: elevation-1
├── Title: Headline Small, left-aligned

Actions:
├── Leading: back arrow (if applicable)
└── Trailing: actions (search, more)
```

### 6.4 Inputs

#### Text Field
```
Specs:
├── Height: 56px
├── Background: gray-100
├── Border-radius: 12px
├── Padding: 16px
├── Label: above field, Label Small
├── Placeholder: gray-400

States:
├── Default: border gray-200
├── Focused: border primary-500, 2px
├── Error: border error, helper text red
└── Disabled: background gray-200
```

#### Search Bar
```
Specs:
├── Height: 48px
├── Background: gray-100
├── Border-radius: 24px (pill)
├── Icon: search, left, gray-500
├── Placeholder: "Rechercher..."
```

### 6.5 Trust Score Display

#### Score de Confiance
```
Visual:
├── 5 étoiles (star icons)
├── Étoiles pleines: gold-main
├── Étoiles vides: gray-300
├── Demi-étoiles: gradient

Numeric:
├── Format: "4.5/5"
├── Font: Body Medium, gold-dark
└── Position: à droite des étoiles

Sizes:
├── Small: 12px stars, inline
├── Medium: 16px stars, card display
└── Large: 24px stars, profile
```

### 6.6 Question Marker (Carte)

```
Specs:
├── Size: 40x48px (with pointer)
├── Shape: rounded square + triangle pointer
├── Background: primary-500
├── Icon: question mark, white
├── Border: 2px white

States:
├── Default: primary-500
├── Selected: accent (coral)
├── Answered: secondary-500 (teal)
└── Cluster: circular, shows count
```

---

## 7. Motion & Animation

### 7.1 Durées

```
instant:    0ms    (feedback immédiat)
fast:       150ms  (micro-interactions)
normal:     300ms  ★ Standard
slow:       500ms  (transitions majeures)
```

### 7.2 Courbes d'Animation

```dart
// Courbes Material Design 3
Curves.easeOut      // Entrées (éléments apparaissent)
Curves.easeIn       // Sorties (éléments disparaissent)
Curves.easeInOut    // Standard (changements d'état)
Curves.fastOutSlowIn // Emphasis (navigation)
```

### 7.3 Animations Clés

| Interaction | Animation | Durée |
|-------------|-----------|-------|
| Tap feedback | Scale down to 0.95 | 100ms |
| Page transition | Slide + Fade | 300ms |
| Modal appearance | Slide up + Fade | 300ms |
| Card appearance | Fade in + slight scale | 200ms |
| Loading states | Shimmer | Loop |
| Pull to refresh | Spring physics | Variable |
| FAB appear | Scale from 0 | 200ms |
| Marker bounce | Spring | 300ms |

---

## 8. Élévation & Ombres

### 8.1 Niveaux d'Élévation

```
elevation-0:  0dp   (flat, backgrounds)
elevation-1:  1dp   (cards, surfaces)
elevation-2:  3dp   (raised buttons)
elevation-3:  6dp   (FAB, dialogs)
elevation-4:  8dp   (navigation bars)
elevation-5:  12dp  (modals, drawers)
```

### 8.2 Implémentation Flutter

```dart
// lib/core/theme/app_shadows.dart
class AppShadows {
  static List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
```

---

## 9. Accessibilité

### 9.1 Niveau Cible

**WCAG 2.1 AA** - Standard pour applications mobiles

### 9.2 Contrastes Minimums

| Type | Ratio Minimum | Exemple |
|------|---------------|---------|
| Texte normal | 4.5:1 | gray-800 sur white |
| Texte large | 3:1 | gray-600 sur white |
| Composants UI | 3:1 | primary-500 sur white |
| Focus visible | 3:1 | border primary-700 |

### 9.3 Tailles Tactiles

```
Minimum touch target: 44x44px (iOS) / 48x48dp (Android)
Spacing between targets: 8px minimum
```

### 9.4 Labels et Descriptions

```dart
// Exemple d'accessibilité
Semantics(
  label: 'Poser une nouvelle question',
  button: true,
  child: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

---

## 10. Dark Mode

### 10.1 Palette Dark Mode

```
Backgrounds:
├── background:     #121212
├── surface:        #1E1E1E
├── surface-light:  #2C2C2C

Text:
├── textPrimary:    #FFFFFF (opacity 87%)
├── textSecondary:  #FFFFFF (opacity 60%)
├── textDisabled:   #FFFFFF (opacity 38%)

Colors:
├── primary:        #64B5F6 (primary-300)
├── secondary:      #4DB6AC (secondary-300)
├── accent:         #FFAB91 (accent-light)
└── divider:        #FFFFFF (opacity 12%)
```

---

## 11. Assets et Ressources

### 11.1 Structure des Assets

```
assets/
├── images/
│   ├── logo/
│   │   ├── logo.svg
│   │   ├── logo-white.svg
│   │   └── icon.png (1024x1024)
│   ├── onboarding/
│   │   ├── slide1.svg
│   │   ├── slide2.svg
│   │   └── slide3.svg
│   └── empty-states/
│       ├── no-questions.svg
│       ├── no-notifications.svg
│       └── no-connection.svg
├── icons/
│   ├── badge-traveler.svg
│   ├── badge-local.svg
│   └── badge-verified.svg
└── fonts/
    └── NotoSansJP/
        ├── NotoSansJP-Regular.otf
        ├── NotoSansJP-Medium.otf
        ├── NotoSansJP-SemiBold.otf
        └── NotoSansJP-Bold.otf
```

### 11.2 Logo Guidelines

```
Logo Principal:
├── Couleur: primary-500
├── Sur fond sombre: white
├── Taille minimum: 32px hauteur
├── Zone de protection: 1x hauteur du logo

App Icon:
├── iOS: 1024x1024px, coins arrondis par système
├── Android: 1024x1024px, adaptive icon
├── Couleur fond: primary-500
└── Icône: symbole blanc centré
```

---

## 12. Thème Flutter Complet

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Colors
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.accent,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // Typography
      fontFamily: 'Noto Sans JP',
      textTheme: const TextTheme(
        headlineSmall: AppTypography.headlineSmall,
        titleMedium: AppTypography.titleMedium,
        bodyLarge: AppTypography.bodyLarge,
        labelSmall: AppTypography.labelSmall,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        centerTitle: false,
      ),

      // Cards
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    // Dark theme implementation...
    return lightTheme; // Placeholder
  }
}
```

---

*Design System TravelConnect v1.0*
*Créé par Sally, UX Expert - Janvier 2026*
