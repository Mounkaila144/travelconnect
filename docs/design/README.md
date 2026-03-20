# Documentation Design UX/UI - TravelConnect

---

## 🎨 Vue d'Ensemble

Cette documentation contient l'ensemble du **Design System** et des **Wireframes** pour l'application mobile **TravelConnect**. Elle a été créée pour servir de référence complète pour le développement frontend Flutter.

**Version** : 1.0
**Date** : Janvier 2026
**Créé par** : Sally, UX Expert

---

## 📚 Documents Disponibles

### 1. [Design System](./design-system.md)

Le design system complet de TravelConnect incluant :

- **Fondations**
  - Philosophie et principes de design
  - Palette de couleurs (primaires, secondaires, sémantiques)
  - Typographie (Noto Sans JP, échelle typographique)
  - Espacement et grille (système base 4px)
  - Iconographie (Material Symbols Rounded)

- **Composants UI**
  - Boutons (Primary, Secondary, Text, FAB)
  - Cards (Question Card, Profile Card)
  - Navigation (Bottom Nav, App Bar)
  - Inputs (Text Field, Search Bar)
  - Trust Score Display
  - Question Markers

- **Styles**
  - Motion & Animation (durées, courbes, transitions)
  - Élévation & Ombres
  - Accessibilité (WCAG AA)
  - Dark Mode

- **Implémentation Flutter**
  - Code snippets complets
  - ThemeData configuration
  - Composants réutilisables

### 2. [Wireframes Principaux](./wireframes-principaux.md)

Wireframes détaillés des écrans essentiels :

1. **Login & Authentification**
   - Écran de connexion social (Google, Apple)
   - Flow OAuth

2. **Onboarding** (3 écrans)
   - Bienvenue et présentation
   - Fonctionnalités clés
   - Création de profil

3. **Carte Interactive** (Écran Principal)
   - Carte avec markers géolocalisés
   - Preview cards des questions
   - FAB pour créer question
   - Bottom navigation

4. **Fil d'Actualité / Forum**
   - Liste des questions
   - Filtres et recherche
   - Question cards

5. **Détail de Question**
   - Question complète
   - Réponses avec votes
   - Input de réponse

6. **Créer une Question**
   - Modal de création
   - Sélection de localisation
   - Catégorisation

7. **Profil Utilisateur**
   - Header avec avatar et stats
   - Trust score
   - Questions et réponses de l'utilisateur

### 3. [Wireframes Secondaires](./wireframes-secondaires.md)

Wireframes des écrans de support :

1. **Notifications**
   - Centre de notifications
   - Types de notifications
   - États (lu/non lu)

2. **Recherche**
   - Barre de recherche active
   - Suggestions
   - Résultats multi-sections

3. **Paramètres**
   - Compte et sécurité
   - Préférences notifications
   - Langue et thème

4. **Modifier le Profil**
   - Édition des informations
   - Upload photo
   - Langues et intérêts

5. **Modals et Dialogues**
   - Modal de réponse
   - Confirmations
   - Bottom sheets
   - Snackbars

6. **États Spéciaux**
   - Loading (skeleton)
   - Empty states
   - Erreurs
   - Permissions

---

## 🎯 Objectifs de Conception

### Vision UX Globale

TravelConnect doit offrir une **expérience rassurante, simple et chaleureuse**. L'interface doit transmettre un sentiment de **communauté et de confiance**, rappelant l'échange avec un ami local plutôt qu'une interaction avec une application froide.

### Principes Directeurs

1. **Simplicité** : Navigation intuitive, pas de surcharge cognitive
2. **Confiance** : Mise en avant des scores de réputation et badges vérifiés
3. **Proximité** : Design chaleureux favorisant la connexion humaine
4. **Efficacité** : Accès rapide aux fonctionnalités essentielles

### Paradigmes d'Interaction

- **Carte-centrée** : La carte interactive est le point d'entrée principal
- **Feed secondaire** : Liste chronologique comme navigation alternative
- **Action flottante** : Bouton FAB pour actions rapides
- **Pull-to-refresh** : Actualisation intuitive
- **Swipe actions** : Gestes naturels pour actions courantes

---

## 🚀 Guide d'Implémentation

### Pour les Développeurs Flutter

1. **Commencer par le Design System**
   - Lire `design-system.md` pour comprendre les fondations
   - Copier le code Flutter du thème dans votre projet
   - Implémenter les couleurs, typographie, et composants de base

2. **Suivre les Wireframes**
   - Utiliser `wireframes-principaux.md` pour les écrans MVP
   - Référer `wireframes-secondaires.md` pour fonctionnalités additionnelles
   - Respecter les spécifications dimensionnelles et d'espacement

3. **Composants Réutilisables**
   - Créer d'abord les composants de base (Avatar, Badge, TrustScore)
   - Construire les composants complexes (QuestionCard, ProfileCard)
   - Assembler les écrans avec ces composants

4. **Accessibilité**
   - Implémenter les labels Semantics dès le début
   - Tester avec VoiceOver (iOS) et TalkBack (Android)
   - Vérifier les contrastes de couleurs

### Structure de Code Recommandée

```
lib/
├── core/
│   └── theme/
│       ├── app_theme.dart        # Thème complet
│       ├── app_colors.dart       # Couleurs
│       ├── app_typography.dart   # Typographie
│       ├── app_spacing.dart      # Espacements
│       └── app_shadows.dart      # Ombres
├── widgets/
│   ├── avatars/
│   ├── badges/
│   ├── buttons/
│   ├── cards/
│   └── inputs/
└── features/
    └── [feature]/
        └── presentation/
            ├── pages/
            └── widgets/
```

---

## 📐 Spécifications Techniques

### Plateformes Cibles

| Plateforme | Version Minimum | Priorité |
|------------|-----------------|----------|
| iOS | 15.0+ | P0 |
| Android | 10+ (API 29) | P0 |
| Web | Non prioritaire | Hors scope MVP |

### Tailles d'Écran

**Responsive** : Support des tailles de 4.7" à 6.7" (smartphones uniquement pour MVP)

**Breakpoints** :
- Small: 320-375px (iPhone SE, small Android)
- Medium: 375-428px (iPhone standard)
- Large: 428+px (iPhone Pro Max, large Android)

### Performance

- **Chargement carte** : < 3s
- **Temps réponse API** : < 500ms
- **Transitions** : 200-300ms
- **60 FPS** : Pour toutes les animations

### Accessibilité

**Niveau cible** : WCAG 2.1 AA

- Contraste suffisant (4.5:1 texte normal, 3:1 texte large)
- Tailles de texte adaptables
- Support VoiceOver et TalkBack
- Zones tactiles minimum 44x44pt (iOS) / 48x48dp (Android)

---

## 🎨 Ressources Design

### Polices

- **Noto Sans JP** - Google Fonts
  - Regular (400)
  - Medium (500)
  - SemiBold (600)
  - Bold (700)

### Icônes

- **Material Symbols Rounded** - Style arrondi
- **Icônes personnalisées** : Badges (à créer en SVG)

### Illustrations

**À créer** :
- Onboarding (3 slides)
- Empty states (5-6 illustrations)
- Error states (2-3 illustrations)
- Permission requests (2-3 illustrations)

**Style recommandé** :
- Flat design moderne
- Couleurs de la palette TravelConnect
- Chaleureux et accueillant
- Inclusif et diversifié

---

## ✅ Checklist de Développement

### Phase 1 : Fondations
- [ ] Configurer le thème Flutter avec les couleurs
- [ ] Implémenter la typographie (Noto Sans JP)
- [ ] Créer les constantes d'espacement
- [ ] Configurer les ombres et élévations

### Phase 2 : Composants de Base
- [ ] Avatar component (toutes tailles)
- [ ] Badge component (Voyageur/Local)
- [ ] Trust Score component
- [ ] Boutons (Primary, Secondary, FAB)
- [ ] Input fields
- [ ] Cards de base

### Phase 3 : Écrans Principaux
- [ ] Login & Onboarding
- [ ] Carte interactive
- [ ] Fil d'actualité
- [ ] Détail de question
- [ ] Créer question
- [ ] Profil utilisateur

### Phase 4 : Écrans Secondaires
- [ ] Notifications
- [ ] Recherche
- [ ] Paramètres
- [ ] Modifier profil

### Phase 5 : États & Feedback
- [ ] Loading states (skeletons)
- [ ] Empty states
- [ ] Error states
- [ ] Snackbars
- [ ] Modals et dialogs

### Phase 6 : Polish & Accessibilité
- [ ] Animations et transitions
- [ ] Semantics labels
- [ ] Tests accessibilité
- [ ] Dark mode (optionnel MVP)
- [ ] Performance optimization

---

## 📝 Notes de Version

### v1.0 - Janvier 2026

**Créé :**
- Design system complet
- Wireframes de tous les écrans MVP
- Spécifications d'implémentation Flutter
- Documentation d'accessibilité

**Scope MVP :**
- 7 écrans principaux
- Authentification sociale
- Carte interactive
- Questions & réponses
- Profils utilisateurs
- Notifications basiques

**Hors Scope MVP** (V2+) :
- Messagerie privée (DM)
- Filtres avancés
- Multi-langue
- Gamification avancée
- Mode hors-ligne

---

## 🤝 Contribution

### Proposer des Améliorations

Si vous identifiez des opportunités d'amélioration du design :

1. Documenter le problème UX rencontré
2. Proposer une solution avec wireframe
3. Vérifier la cohérence avec le design system
4. Tester l'accessibilité de la solution

### Ajouter des Composants

Lors de la création de nouveaux composants :

1. Suivre les principes du design system
2. Documenter le composant avec exemples
3. Inclure les états (default, hover, pressed, disabled)
4. Ajouter les labels d'accessibilité

---

## 📞 Contact

**UX Expert** : Sally
**Pour questions design** : Référer à ce document d'abord
**Documentation technique** : Voir `docs/architecture/`

---

## 🔗 Liens Utiles

### Références Externes

- [Material Design 3](https://m3.material.io/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Google Fonts - Noto Sans JP](https://fonts.google.com/noto/specimen/Noto+Sans+JP)

### Documentation Projet

- [Brief Projet](../brief-fr.md)
- [PRD](../prd/)
- [Architecture](../architecture/)

---

**🎨 Happy Designing & Coding!**

*Cette documentation évolue avec le projet. N'hésitez pas à la consulter régulièrement pour rester aligné avec la vision UX.*
