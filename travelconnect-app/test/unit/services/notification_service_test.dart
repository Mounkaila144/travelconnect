import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/core/services/notification_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late NotificationService notificationService;

  setUp(() {
    mockDio = MockDio();
    notificationService =
        NotificationService(mockDio, GlobalKey<NavigatorState>());
  });

  group('NotificationService', () {
    group('registerTokenWithBackend', () {
      test('sends correct API request with fcm_token', () async {
        when(() => mockDio.post(
              '/user/fcm-token',
              data: {'fcm_token': 'test_fcm_token_12345'},
            )).thenAnswer((_) async => Response(
              statusCode: 204,
              requestOptions: RequestOptions(path: '/user/fcm-token'),
            ));

        await notificationService.registerTokenWithBackend('test_fcm_token_12345');

        verify(() => mockDio.post(
              '/user/fcm-token',
              data: {'fcm_token': 'test_fcm_token_12345'},
            )).called(1);
      });

      test('rethrows error on network failure', () async {
        when(() => mockDio.post(
              '/user/fcm-token',
              data: any(named: 'data'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: '/user/fcm-token'),
              type: DioExceptionType.connectionTimeout,
            ));

        expect(
          () => notificationService.registerTokenWithBackend('test_token'),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
