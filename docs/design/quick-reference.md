# Quick Reference Guide - TravelConnect Design

Guide de référence rapide pour les développeurs. Pour les détails complets, consultez le [Design System](./design-system.md).

---

## 🎨 Couleurs Essentielles

```dart
// Couleurs principales
Primary:     #2196F3  (Bleu confiance)
Secondary:   #009688  (Teal exploration)
Accent:      #FF7043  (Coral chaleur)
Gold:        #FFC107  (Trust score)

// Sémantiques
Success:     #4CAF50
Warning:     #FF9800
Error:       #F44336

// Neutres
Background:  #FAFAFA
Surface:     #FFFFFF
TextPrimary: #212121
TextSecondary: #757575
Divider:     #E0E0E0
```

---

## 📝 Typographie

```dart
// Police
Font: 'Noto Sans JP'

// Tailles courantes
Headline (page title):    24px / Bold (700)
Title (section):          16px / Medium (500)
Body (texte principal):   16px / Regular (400)
Label (boutons):          14px / Medium (500)
Caption (metadata):       11px / Medium (500)
```

---

## 📏 Espacements

```dart
// Base 4px
xs:    4px   // Micro
sm:    8px   // Entre éléments liés
md:    12px  // Intra-composant
base:  16px  // ★ Padding standard
lg:    24px  // Entre sections
xl:    32px  // Séparation majeure
xxl:   48px  // Marges de page
```

---

## 🔘 Boutons

```dart
// Primary Button
Height: 48px
Padding: 24px horizontal
BorderRadius: 24px (pill)
Background: primary (#2196F3)
Text: white, 14px Medium

// FAB (Floating Action Button)
Size: 56x56px
BorderRadius: 16px
Background: accent (#FF7043)
Icon: white, 24px
Position: bottom-right, 16px from edges
```

---

## 🃏 Cards

```dart
// Question Card
Background: white
BorderRadius: 12px
Padding: 16px
Shadow: elevation-1
Margin: 12px between cards

// Structure:
- Header: Avatar (40px) + Name + Badge + Time
- Body: Question (max 3 lines, ellipsis)
- Location: Icon + Place name
- Footer: Answers count + Rating
```

---

## 📱 Navigation

```dart
// Bottom Navigation Bar
Height: 80px (includes safe area)
Background: white
Shadow: elevation-4 (top)
Items: 4 max
- Selected: primary (#2196F3), filled icon
- Unselected: gray (#757575), outlined icon

// App Bar
Height: 56px
Background: white
Shadow: elevation-1
Title: 24px Bold, left-aligned
```

---

## 👤 Avatar & Badge

```dart
// Avatar Sizes
XS:  24px  (inline)
SM:  40px  (cards)
MD:  56px  (preview)
LG:  80px  (profil)
XL:  120px (édition)

// Badge
✈️ Voyageur: primary (#2196F3)
🏠 Local: secondary (#009688)
✓ Vérifié: gold (#FFC107)
Size: 24x24px
```

---

## ⭐ Trust Score

```dart
// Display
Stars: 5 star icons (16-24px)
Filled: gold (#FFC107)
Empty: gray (#E0E0E0)
Numeric: "4.5/5" à droite

// Sizes
Small:  12px stars (inline)
Medium: 16px stars (cards)
Large:  24px stars (profil)
```

---

## 📍 Question Marker (Carte)

```dart
Size: 40x48px (with pointer)
Shape: rounded square + triangle
Background: primary (#2196F3)
Icon: question mark, white
Border: 2px white

// States
Default: primary (#2196F3)
Selected: accent (#FF7043)
Answered: secondary (#009688)
Cluster: circular, shows count
```

---

## 🎭 Animations

```dart
// Durées
Fast:    150ms  (micro-interactions)
Normal:  300ms  (★ standard)
Slow:    500ms  (transitions majeures)

// Courbes
Curves.easeOut       (entrées)
Curves.easeIn        (sorties)
Curves.easeInOut     (standard)
Curves.fastOutSlowIn (navigation)
```

---

## 📦 Élévation

```dart
elevation-0:  0dp   (flat)
elevation-1:  1dp   (cards)
elevation-2:  3dp   (raised buttons)
elevation-3:  6dp   (FAB, dialogs)
elevation-4:  8dp   (navigation bars)
```

---

## ✅ États de Composants

```dart
// Button States
Default:  primary (#2196F3)
Hover:    primary-600 (#1E88E5)
Pressed:  primary-700 (#1976D2)
Disabled: gray-300 (#E0E0E0)
Loading:  primary + CircularProgress

// Input States
Default:  border gray-200
Focused:  border primary, 2px
Error:    border error (#F44336)
Disabled: background gray-200
```

---

## 🔔 Snackbars

```dart
Position: bottom, above nav bar
Height: 48px
Padding: 16px
BorderRadius: 4px
Duration: 3-4s
Action: Optional (right aligned)

// Types
Success: green (#4CAF50), ✓ icon
Error:   red (#F44336), ⚠ icon
Info:    blue (#2196F3), ℹ icon
Warning: orange (#FF9800), ⚠ icon
```

---

## 🎯 Touch Targets

```dart
Minimum: 48x48dp (Android) / 44x44pt (iOS)
Spacing: 8px minimum between targets
```

---

## ♿ Accessibilité

```dart
// Contrastes (WCAG AA)
Texte normal: 4.5:1 minimum
Texte large:  3:1 minimum
UI components: 3:1 minimum

// Labels
Semantics(
  label: 'Description de l\'action',
  hint: 'Instruction d\'utilisation',
  button: true, // si c'est un bouton
  child: Widget(),
)
```

---

## 📐 Layout Standards

```dart
// Page Margins
Horizontal: 16px (AppSpacing.base)
Top: 16px + SafeArea
Bottom: 16px + SafeArea + NavBar

// Card Padding
Standard: 16px
Compact:  12px

// List Item
Height: 72-88px (touch target)
Padding: 16px
Spacing: 12px between items
```

---

## 🖼️ Empty States

```dart
Structure:
1. Illustration (center, ~150px)
2. Title (Headline Small, 24px Bold)
3. Message (Body Medium, 14px)
4. CTA Button (optional)

Spacing: 24px between elements
```

---

## ⏳ Loading States

```dart
// Skeleton
Animation: Shimmer (left to right)
Color: gray-200 → gray-100 → gray-200
Duration: 1.5s loop

// CircularProgress
Size: 24px (inline) / 48px (fullscreen)
Color: primary (#2196F3)
Stroke: 4px
```

---

## 🎨 Quick Theme Setup

```dart
import 'package:flutter/material.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF2196F3),
    secondary: Color(0xFF009688),
    tertiary: Color(0xFFFF7043),
    error: Color(0xFFF44336),
  ),
  fontFamily: 'Noto Sans JP',
  scaffoldBackgroundColor: Color(0xFFFAFAFA),
);
```

---

## 📱 Common Widgets

```dart
// Avatar
CircleAvatar(
  radius: 20, // 40px diameter
  backgroundImage: NetworkImage(url),
)

// Badge
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text('✈️ Voyageur'),
)

// Trust Score
Row(
  children: [
    ...List.generate(5, (i) => Icon(
      Icons.star,
      size: 16,
      color: i < rating ? goldColor : grayColor,
    )),
    SizedBox(width: 4),
    Text('4.5/5'),
  ],
)
```

---

## 🗺️ Map Markers

```dart
// Custom Marker Icon
BitmapDescriptor.fromAssetImage(
  ImageConfiguration(size: Size(40, 48)),
  'assets/markers/question_marker.png',
)

// Marker Colors
Unanswered: #2196F3 (primary)
Answered:   #009688 (secondary)
Selected:   #FF7043 (accent)
```

---

## 🔤 Text Truncation

```dart
// Single Line
Text(
  question,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)

// Multi Line (3 lines)
Text(
  question,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
)
```

---

## 📊 Common Layouts

```dart
// List Item
ListTile(
  contentPadding: EdgeInsets.all(16),
  leading: CircleAvatar(...), // 40px
  title: Text(...),           // 16px Medium
  subtitle: Text(...),        // 14px Regular
  trailing: Icon(...),        // 24px
)

// Card Header
Row(
  children: [
    CircleAvatar(...),        // 40px
    SizedBox(width: 12),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name),           // 16px Medium
        Text(time),           // 11px Regular gray
      ],
    ),
    Spacer(),
    Badge(...),
  ],
)
```

---

## 🎯 Icons

```dart
// Material Symbols Rounded
Icons.map               // 🗺️ Carte
Icons.forum             // 💬 Questions
Icons.notifications     // 🔔 Notifications
Icons.person            // 👤 Profil
Icons.add               // ➕ Ajouter
Icons.location_on       // 📍 Localisation
Icons.star              // ⭐ Rating
Icons.flight            // ✈️ Voyageur
Icons.home              // 🏠 Local
Icons.search            // 🔍 Recherche

// Sizes
Small:  20px
Medium: 24px (★ standard)
Large:  32px
```

---

## 🔄 Navigation Transitions

```dart
// Forward (push)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NewPage(),
  ),
);

// Modal (bottom sheet)
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(16),
    ),
  ),
  builder: (context) => ModalContent(),
);
```

---

## ⚡ Performance

```dart
// Image Caching
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) =>
    CircularProgressIndicator(),
  errorWidget: (context, url, error) =>
    Icon(Icons.error),
)

// List Performance
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) =>
    ItemWidget(items[index]),
)
```

---

## 📋 Validation Rules

```dart
// Question
Min: 10 caractères
Max: 500 caractères
Required: Oui

// Name
Min: 2 caractères
Max: 50 caractères
Required: Oui

// Bio
Max: 200 caractères
Required: Non
```

---

**💡 Tip**: Toujours se référer au [Design System complet](./design-system.md) pour les détails d'implémentation et les cas d'usage avancés.

---

*Quick Reference TravelConnect v1.0*
