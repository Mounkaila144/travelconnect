import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/locale/locale_bloc.dart';

import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/log_out.dart';
import 'features/auth/domain/usecases/sign_in_with_apple.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/map/data/datasources/location_local_datasource.dart';
import 'features/map/data/repositories/location_repository_impl.dart';
import 'features/map/domain/repositories/location_repository.dart';
import 'features/map/domain/usecases/check_location_permission.dart';
import 'features/map/domain/usecases/get_current_location.dart';
import 'features/map/domain/usecases/request_location_permission.dart';
import 'features/map/presentation/bloc/map_bloc.dart';
import 'features/questions/data/datasources/questions_remote_datasource.dart';
import 'features/questions/data/repositories/questions_repository_impl.dart';
import 'features/questions/domain/repositories/questions_repository.dart';
import 'features/questions/domain/usecases/create_answer.dart';
import 'features/questions/domain/usecases/create_question.dart';
import 'features/questions/domain/usecases/get_nearby_questions.dart';
import 'features/questions/domain/usecases/get_question_detail.dart';
import 'features/questions/domain/usecases/get_user_questions.dart';
import 'features/questions/domain/usecases/rate_answer.dart';
import 'features/questions/presentation/bloc/question_detail_bloc.dart';
import 'features/moderation/data/datasources/report_remote_datasource.dart';
import 'features/moderation/data/repositories/report_repository_impl.dart';
import 'features/moderation/domain/repositories/report_repository.dart';
import 'features/moderation/domain/usecases/create_report.dart';
import 'features/moderation/presentation/bloc/report_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'core/services/notification_service.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/domain/usecases/update_profile.dart';
import 'features/profile/domain/usecases/upload_avatar.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/settings/data/datasources/settings_remote_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/notification_zone_bloc.dart';
import 'features/questions/presentation/bloc/questions_feed_bloc.dart';
import 'features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'features/notifications/data/repositories/notifications_repository_impl.dart';
import 'features/notifications/domain/repositories/notifications_repository.dart';
import 'features/notifications/presentation/bloc/notifications_center_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Locale BLoC
  sl.registerFactory<LocaleBloc>(
    () => LocaleBloc(prefs: sl<SharedPreferences>()),
  );

  // External
  sl.registerLazySingleton<Dio>(() {
    const baseUrl = 'https://travelconnect.ptrniger.com/api';

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ));

    // Add auth token interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await sl<AuthLocalDataSource>().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('[DIO REQUEST] ${options.method} ${options.baseUrl}${options.path}');
        debugPrint('[DIO REQUEST] Token present: ${token != null} | Token: ${token != null ? '${token.substring(0, 10)}...' : 'NULL'}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[DIO RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('[DIO ERROR] ${error.type} | ${error.response?.statusCode} | ${error.requestOptions.path}');
        debugPrint('[DIO ERROR] Message: ${error.message}');
        debugPrint('[DIO ERROR] Response data: ${error.response?.data}');
        handler.next(error);
      },
    ));

    return dio;
  });

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<GoogleSignIn>(() {
    const webClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
    return GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: kIsWeb && webClientId.isNotEmpty ? webClientId : null,
    );
  });

  // Auth Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<Dio>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      dio: sl<Dio>(),
    ),
  );

  // Auth Use Cases
  sl.registerLazySingleton<SignInWithGoogle>(
    () => SignInWithGoogle(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<SignInWithApple>(
    () => SignInWithApple(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LogOut>(
    () => LogOut(sl<AuthRepository>()),
  );

  // Auth BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInWithGoogle: sl<SignInWithGoogle>(),
      signInWithApple: sl<SignInWithApple>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // Profile Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Profile Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl<ProfileRemoteDataSource>()),
  );

  // Profile Use Cases
  sl.registerLazySingleton<GetProfile>(
    () => GetProfile(sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<UpdateProfile>(
    () => UpdateProfile(sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<UploadAvatar>(
    () => UploadAvatar(sl<ProfileRepository>()),
  );

  // Profile BLoC
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfile: sl<GetProfile>(),
      updateProfile: sl<UpdateProfile>(),
      uploadAvatar: sl<UploadAvatar>(),
    ),
  );

  // Map Data Sources
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(),
  );

  // Map Repository
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(localDataSource: sl<LocationLocalDataSource>()),
  );

  // Map Use Cases
  sl.registerLazySingleton<GetCurrentLocation>(
    () => GetCurrentLocation(sl<LocationRepository>()),
  );

  sl.registerLazySingleton<CheckLocationPermission>(
    () => CheckLocationPermission(sl<LocationRepository>()),
  );

  sl.registerLazySingleton<RequestLocationPermission>(
    () => RequestLocationPermission(sl<LocationRepository>()),
  );

  // Questions Data Sources
  sl.registerLazySingleton<QuestionsRemoteDataSource>(
    () => QuestionsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Questions Repository
  sl.registerLazySingleton<QuestionsRepository>(
    () => QuestionsRepositoryImpl(remoteDataSource: sl<QuestionsRemoteDataSource>()),
  );

  // Questions Use Cases
  sl.registerLazySingleton<GetNearbyQuestions>(
    () => GetNearbyQuestions(sl<QuestionsRepository>()),
  );

  sl.registerLazySingleton<CreateQuestion>(
    () => CreateQuestion(sl<QuestionsRepository>()),
  );

  sl.registerLazySingleton<GetQuestionDetail>(
    () => GetQuestionDetail(sl<QuestionsRepository>()),
  );

  sl.registerLazySingleton<GetUserQuestions>(
    () => GetUserQuestions(sl<QuestionsRepository>()),
  );

  sl.registerLazySingleton<CreateAnswer>(
    () => CreateAnswer(sl<QuestionsRepository>()),
  );

  sl.registerLazySingleton<RateAnswer>(
    () => RateAnswer(sl<QuestionsRepository>()),
  );

  // Question Detail BLoC
  sl.registerFactory<QuestionDetailBloc>(
    () => QuestionDetailBloc(
      getQuestionDetail: sl<GetQuestionDetail>(),
      createAnswer: sl<CreateAnswer>(),
      rateAnswer: sl<RateAnswer>(),
    ),
  );

  // Moderation Data Sources
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Moderation Repository
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remoteDataSource: sl<ReportRemoteDataSource>()),
  );

  // Moderation Use Cases
  sl.registerLazySingleton<CreateReport>(
    () => CreateReport(sl<ReportRepository>()),
  );

  // Report BLoC
  sl.registerFactory<ReportBloc>(
    () => ReportBloc(createReport: sl<CreateReport>()),
  );

  // Navigator Key (for notification deep-linking)
  sl.registerLazySingleton<GlobalKey<NavigatorState>>(
    () => GlobalKey<NavigatorState>(),
  );

  // Notification Service
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(sl<Dio>(), sl<GlobalKey<NavigatorState>>()),
  );

  // Notification BLoC
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(notificationService: sl<NotificationService>()),
  );

  // Settings Data Sources
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Settings Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(remoteDataSource: sl<SettingsRemoteDataSource>()),
  );

  // Settings BLoC
  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(settingsRepository: sl<SettingsRepository>()),
  );

  // Notification Zone BLoC (Story 4.3)
  sl.registerFactory<NotificationZoneBloc>(
    () => NotificationZoneBloc(settingsRepository: sl<SettingsRepository>()),
  );

  // Questions Feed BLoC (Story 4.4)
  sl.registerFactory<QuestionsFeedBloc>(
    () => QuestionsFeedBloc(questionsRepository: sl<QuestionsRepository>()),
  );

  // Notifications Center Data Sources (Story 4.5)
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Notifications Center Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(
        remoteDataSource: sl<NotificationsRemoteDataSource>()),
  );

  // Notifications Center BLoC
  sl.registerFactory<NotificationsCenterBloc>(
    () => NotificationsCenterBloc(
        notificationsRepository: sl<NotificationsRepository>()),
  );

  // Map BLoC
  sl.registerFactory<MapBloc>(
    () => MapBloc(
      getCurrentLocation: sl<GetCurrentLocation>(),
      checkLocationPermission: sl<CheckLocationPermission>(),
      requestLocationPermission: sl<RequestLocationPermission>(),
      getNearbyQuestions: sl<GetNearbyQuestions>(),
    ),
  );
}
