# 17. Standards de Codage

## 17.1 Règles Critiques Fullstack

| Règle | Description |
|-------|-------------|
| **Validation Côté Serveur** | Toujours valider les entrées côté API, même si validées côté client |
| **Gestion d'Erreurs** | Utiliser les handlers d'erreurs standardisés, jamais d'exceptions non catchées |
| **Authentification** | Toujours vérifier l'authentification via middleware, jamais dans le controller |
| **Variables d'Environnement** | Accéder via `config()` (Laravel) et injectées (Flutter), jamais `env()` directement |
| **Appels API** | Utiliser la couche service/repository, jamais d'appels HTTP directs dans les widgets/controllers |
| **Logs** | Logger les erreurs critiques avec contexte, jamais de données sensibles |
| **Commits** | Messages conventionnels (feat/fix/docs/refactor), jamais de commits de fichiers sensibles |

## 17.2 Conventions de Nommage

| Élément | Frontend (Dart) | Backend (PHP) | Exemple |
|---------|-----------------|---------------|---------|
| Classes | PascalCase | PascalCase | `QuestionCard`, `QuestionService` |
| Fichiers | snake_case | PascalCase (PSR-4) | `question_card.dart`, `QuestionService.php` |
| Variables | camelCase | camelCase | `questionCount`, `$questionCount` |
| Constantes | SCREAMING_SNAKE | SCREAMING_SNAKE | `MAX_TITLE_LENGTH`, `MAX_TITLE_LENGTH` |
| Routes API | - | kebab-case | `/api/v1/user-profile` |
| Tables BDD | - | snake_case | `user_questions` |
| Colonnes BDD | - | snake_case | `created_at` |
