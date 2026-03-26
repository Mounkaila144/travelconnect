import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/locale/locale_bloc.dart';
import 'core/locale/locale_event.dart';
import 'core/locale/locale_state.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/map/presentation/bloc/map_bloc.dart';
import 'features/map/presentation/pages/map_page.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';
import 'features/notifications/presentation/bloc/notifications_center_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_center_event.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';
import 'features/notifications/presentation/widgets/notification_badge.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/profile/presentation/pages/onboarding_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/questions/domain/usecases/create_answer.dart';
import 'features/questions/domain/usecases/get_question_detail.dart';
import 'features/questions/domain/usecases/rate_answer.dart';
import 'features/questions/presentation/bloc/question_detail_bloc.dart';
import 'features/questions/presentation/bloc/question_detail_event.dart';
import 'features/questions/presentation/bloc/questions_feed_bloc.dart';
import 'features/questions/presentation/pages/my_questions_page.dart';
import 'features/questions/presentation/pages/question_detail_page.dart';
import 'features/questions/presentation/pages/questions_feed_page.dart';
import 'features/search/presentation/pages/search_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/map/presentation/services/marker_icon_service.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase init failed (app will run without push notifications): $e');
    }
  }

  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('ja', timeago.JaMessages());
  await configureDependencies();

  if (firebaseInitialized) {
    try {
      await sl<NotificationService>().initialize();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService init skipped: $e');
      }
    }
  }

  await MarkerIconService.loadIcons();
  runApp(const TravelConnectApp());
}

class TravelConnectApp extends StatelessWidget {
  const TravelConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(const CheckAuthStatus()),
        ),
        BlocProvider(create: (_) => sl<ProfileBloc>()),
        BlocProvider(create: (_) => sl<MapBloc>()),
        BlocProvider(
          create: (_) => sl<NotificationBloc>()
            ..add(const PermissionRequested()),
        ),
        BlocProvider(
          create: (_) => sl<NotificationsCenterBloc>()
            ..add(const LoadNotifications()),
        ),
        BlocProvider(
          create: (_) => sl<LocaleBloc>()..add(const LoadSavedLocale()),
        ),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp(
            title: 'TravelConnect',
            navigatorKey: sl<GlobalKey<NavigatorState>>(),
            locale: localeState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('fr'),
              Locale('en'),
              Locale('ja'),
            ],
            theme: AppTheme.lightTheme,
            home: const _AuthGate(),
            onGenerateRoute: (settings) {
              // Handle /question/:id deep-link from notifications
              final uri = Uri.parse(settings.name ?? '');
              if (uri.pathSegments.length == 2 &&
                  uri.pathSegments[0] == 'question') {
                final questionId = int.tryParse(uri.pathSegments[1]);
                if (questionId != null) {
                  return MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => QuestionDetailBloc(
                        getQuestionDetail: sl<GetQuestionDetail>(),
                        createAnswer: sl<CreateAnswer>(),
                        rateAnswer: sl<RateAnswer>(),
                      )..add(LoadQuestionDetail(questionId)),
                      child: QuestionDetailPage(questionId: questionId),
                    ),
                  );
                }
              }

              // Static routes
              final staticRoutes = <String, WidgetBuilder>{
                '/login': (_) => const LoginPage(),
                '/onboarding': (_) => const OnboardingPage(),
                '/home': (_) => const _HomePage(),
                '/map': (_) => const MapPage(),
                '/profile': (_) => const ProfilePage(),
                '/edit-profile': (_) => const EditProfilePage(),
                '/settings': (_) => const SettingsPage(),
                '/user/questions': (_) => const MyQuestionsPage(),
                '/notifications': (_) => const NotificationsPage(),
                '/search': (_) => const SearchPage(),
              };

              final builder = staticRoutes[settings.name];
              if (builder != null) {
                return MaterialPageRoute(builder: builder, settings: settings);
              }

              return null;
            },
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          if (state.isNewUser || state.user.isNew) {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          } else {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else if (state is Unauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const MapPage(),
          BlocProvider(
            create: (_) => sl<QuestionsFeedBloc>(),
            child: const QuestionsFeedPage(),
          ),
          const NotificationsPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map_rounded),
              label: l10n.nav_map,
            ),
            NavigationDestination(
              icon: const Icon(Icons.forum_outlined),
              selectedIcon: const Icon(Icons.forum_rounded),
              label: l10n.nav_forum,
            ),
            NavigationDestination(
              icon: NotificationBadge(
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: NotificationBadge(
                child: const Icon(Icons.notifications_rounded),
              ),
              label: l10n.nav_notifications,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.nav_profile,
            ),
          ],
        ),
      ),
    );
  }
}
