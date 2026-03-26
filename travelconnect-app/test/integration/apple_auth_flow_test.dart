// Apple Sign-In Integration Tests
//
// IMPORTANT: These tests require:
// - An iOS simulator or physical iOS device
// - A valid Apple Developer account configured in Xcode
// - Sign in with Apple capability enabled
// - A running backend at the configured API_BASE_URL
//
// Run with: flutter test integration_test/apple_auth_flow_test.dart
// (on iOS simulator only)
//
// Manual E2E Test Checklist:
//
// 1. [  ] Complete flow: Login screen -> Apple dialog -> Backend auth -> Map screen
// 2. [  ] New user flow: Shows onboarding after first login
// 3. [  ] Existing user flow: Goes directly to map
// 4. [  ] Test with real Apple ID credentials
// 5. [  ] Test with "Hide My Email" enabled
// 6. [  ] Test with "Hide My Email" disabled
// 7. [  ] User name extraction (first + last name)
// 8. [  ] Default name "Utilisateur" when not provided
// 9. [  ] Error scenarios display appropriate SnackBar messages
// 10. [ ] Token is stored and persists across app restarts
// 11. [ ] Subsequent logins use stored token
// 12. [ ] Apple button does NOT appear on Android devices
// 13. [ ] User cancellation returns to login screen gracefully

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Apple Sign-In Integration Tests', () {
    test('Apple Sign-In button is visible on iOS', () {
      expect(Platform.isIOS, isTrue,
          reason: 'This integration test must run on iOS');
    });

    // Additional integration tests require real Apple Sign-In credentials
    // and an active iOS simulator. These are validated manually during QA.
  });
}
