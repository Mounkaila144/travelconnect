# 16. Stratégie de Tests

## 16.1 Pyramide de Tests

```
        E2E Tests (Flutter Integration)
       /                              \
      Integration Tests (API Feature)
     /                                \
    Frontend Unit Tests    Backend Unit Tests
    (Flutter Test)         (PHPUnit)
```

## 16.2 Organisation des Tests

**Tests Frontend :**
```
test/
├── unit/
│   ├── services/
│   │   └── trust_score_calculator_test.dart
│   └── utils/
│       └── date_formatter_test.dart
├── widget/
│   ├── question_card_test.dart
│   └── rating_stars_test.dart
└── integration/
    └── auth_flow_test.dart
```

**Tests Backend :**
```
tests/
├── Unit/
│   ├── Services/
│   │   ├── TrustScoreServiceTest.php
│   │   └── AuthServiceTest.php
│   └── Repositories/
│       └── QuestionRepositoryTest.php
└── Feature/
    ├── Auth/
    │   ├── GoogleAuthTest.php
    │   └── AppleAuthTest.php
    ├── Questions/
    │   ├── CreateQuestionTest.php
    │   └── ListQuestionsTest.php
    └── Answers/
        ├── CreateAnswerTest.php
        └── RateAnswerTest.php
```

## 16.3 Exemples de Tests

**Test Widget Flutter :**
```dart
// test/widget/question_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travelconnect/features/questions/presentation/widgets/question_card.dart';

void main() {
  group('QuestionCard', () {
    testWidgets('displays question title and author', (tester) async {
      final question = Question(
        id: 1,
        title: 'Best ramen in Shibuya?',
        user: User(name: 'Tanaka', userType: UserType.traveler),
        answersCount: 3,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionCard(question: question),
          ),
        ),
      );

      expect(find.text('Best ramen in Shibuya?'), findsOneWidget);
      expect(find.text('Tanaka'), findsOneWidget);
      expect(find.text('3 réponses'), findsOneWidget);
    });

    testWidgets('shows different marker color for unanswered questions', (tester) async {
      final question = Question(
        id: 1,
        title: 'Help needed!',
        answersCount: 0,
        // ...
      );

      await tester.pumpWidget(/* ... */);

      final marker = tester.widget<Container>(find.byType(Container).first);
      expect(marker.decoration, /* has urgent color */);
    });
  });
}
```

**Test API Laravel :**
```php
<?php

namespace Tests\Feature\Questions;

use App\Models\Question;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CreateQuestionTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_create_question(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/questions', [
            'title' => 'Best ramen in Shibuya?',
            'description' => 'Looking for authentic tonkotsu ramen',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'title',
                    'description',
                    'latitude',
                    'longitude',
                    'location_name',
                    'user',
                ],
            ]);

        $this->assertDatabaseHas('questions', [
            'title' => 'Best ramen in Shibuya?',
            'user_id' => $user->id,
        ]);
    }

    public function test_title_is_required(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/questions', [
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title']);
    }

    public function test_unauthenticated_user_cannot_create_question(): void
    {
        $response = $this->postJson('/api/v1/questions', [
            'title' => 'Test question',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(401);
    }
}
```

**Test E2E Flutter :**
```dart
// integration_test/auth_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travelconnect/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('User can sign in with Google and see map', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen is shown
      expect(find.text('Continuer avec Google'), findsOneWidget);

      // Tap Google sign-in button
      await tester.tap(find.text('Continuer avec Google'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // After successful login, map should be visible
      expect(find.byType(GoogleMap), findsOneWidget);
    });
  });
}
```
