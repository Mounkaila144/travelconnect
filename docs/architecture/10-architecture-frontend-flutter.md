# 10. Architecture Frontend (Flutter)

## 10.1 Organisation des Composants

```
lib/
├── main.dart                    # Point d'entrée
├── app.dart                     # Configuration MaterialApp
├── injection.dart               # Dependency injection (GetIt)
│
├── core/                        # Code partagé
│   ├── api/
│   │   ├── api_client.dart      # Client HTTP (Dio)
│   │   ├── api_interceptors.dart
│   │   └── api_exceptions.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_endpoints.dart
│   ├── error/
│   │   └── failures.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── loading_indicator.dart
│       ├── error_widget.dart
│       └── avatar_widget.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── auth_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_google.dart
│   │   │       └── sign_in_with_apple.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       └── widgets/
│   │           └── social_login_button.dart
│   │
│   ├── map/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── map_bloc.dart
│   │       ├── pages/
│   │       │   └── map_page.dart
│   │       └── widgets/
│   │           ├── question_marker.dart
│   │           └── question_info_window.dart
│   │
│   ├── questions/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── questions_bloc.dart
│   │       │   └── question_detail_bloc.dart
│   │       ├── pages/
│   │       │   ├── questions_feed_page.dart
│   │       │   ├── question_detail_page.dart
│   │       │   └── create_question_page.dart
│   │       └── widgets/
│   │           ├── question_card.dart
│   │           ├── answer_item.dart
│   │           └── rating_stars.dart
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── notifications/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── routes/
    └── app_router.dart          # GoRouter configuration
```

## 10.2 Template de Composant (BLoC)

```dart
// features/questions/presentation/bloc/questions_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'questions_event.dart';
part 'questions_state.dart';

class QuestionsBloc extends Bloc<QuestionsEvent, QuestionsState> {
  final GetNearbyQuestions _getNearbyQuestions;

  QuestionsBloc({
    required GetNearbyQuestions getNearbyQuestions,
  })  : _getNearbyQuestions = getNearbyQuestions,
        super(QuestionsInitial()) {
    on<LoadNearbyQuestions>(_onLoadNearbyQuestions);
    on<RefreshQuestions>(_onRefreshQuestions);
  }

  Future<void> _onLoadNearbyQuestions(
    LoadNearbyQuestions event,
    Emitter<QuestionsState> emit,
  ) async {
    emit(QuestionsLoading());

    final result = await _getNearbyQuestions(
      NearbyQuestionsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: event.radiusKm,
      ),
    );

    result.fold(
      (failure) => emit(QuestionsError(failure.message)),
      (questions) => emit(QuestionsLoaded(questions)),
    );
  }

  Future<void> _onRefreshQuestions(
    RefreshQuestions event,
    Emitter<QuestionsState> emit,
  ) async {
    // Refresh logic
  }
}
```

## 10.3 Gestion d'État

```dart
// Structure du state global avec plusieurs BLoCs

// AuthBloc - État authentification
abstract class AuthState extends Equatable {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
}
class Unauthenticated extends AuthState {}

// Pattern d'utilisation dans l'app
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => getIt<AuthBloc>()),
    BlocProvider(create: (_) => getIt<MapBloc>()),
    BlocProvider(create: (_) => getIt<QuestionsBloc>()),
    BlocProvider(create: (_) => getIt<ProfileBloc>()),
    BlocProvider(create: (_) => getIt<NotificationsBloc>()),
  ],
  child: const TravelConnectApp(),
)
```

## 10.4 Architecture de Routing

```dart
// routes/app_router.dart
final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is Authenticated;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) return '/login';
    if (isLoggedIn && isLoggingIn) return '/map';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapPage(),
        ),
        GoRoute(
          path: '/feed',
          builder: (context, state) => const QuestionsFeedPage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/question/:id',
      builder: (context, state) => QuestionDetailPage(
        questionId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/question/create',
      builder: (context, state) => const CreateQuestionPage(),
    ),
  ],
);
```

## 10.5 Route Protégée Pattern

```dart
// Middleware d'authentification via GoRouter redirect
redirect: (context, state) {
  final authBloc = context.read<AuthBloc>();
  final isAuthenticated = authBloc.state is Authenticated;

  // Routes publiques
  final publicRoutes = ['/login', '/onboarding'];
  final isPublicRoute = publicRoutes.contains(state.matchedLocation);

  if (!isAuthenticated && !isPublicRoute) {
    return '/login';
  }

  if (isAuthenticated && state.matchedLocation == '/login') {
    final user = (authBloc.state as Authenticated).user;
    // Rediriger vers onboarding si profil incomplet
    if (user.name.isEmpty) {
      return '/onboarding';
    }
    return '/map';
  }

  return null;
}
```

## 10.6 Layer Services Frontend

```dart
// core/api/api_client.dart
class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = ApiEndpoints.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParams}) {
    return _dio.get<T>(path, queryParameters: queryParams);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }
}
```

```dart
// features/questions/data/datasources/questions_remote_datasource.dart
class QuestionsRemoteDataSource {
  final ApiClient _apiClient;

  QuestionsRemoteDataSource(this._apiClient);

  Future<List<QuestionModel>> getNearbyQuestions({
    required double lat,
    required double lng,
    required int radiusKm,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      '/questions',
      queryParams: {
        'lat': lat,
        'lng': lng,
        'radius': radiusKm,
        'page': page,
      },
    );

    return (response.data['data'] as List)
        .map((json) => QuestionModel.fromJson(json))
        .toList();
  }

  Future<QuestionModel> createQuestion(CreateQuestionDto dto) async {
    final response = await _apiClient.post(
      '/questions',
      data: dto.toJson(),
    );

    return QuestionModel.fromJson(response.data['data']);
  }
}
```
