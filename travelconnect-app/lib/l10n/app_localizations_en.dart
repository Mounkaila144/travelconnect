// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nav_map => 'Map';

  @override
  String get nav_forum => 'Forum';

  @override
  String get nav_notifications => 'Notifications';

  @override
  String get nav_profile => 'Profile';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_account => 'Account';

  @override
  String get settings_editProfile => 'Edit profile';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_manageNotifications => 'Manage notification preferences';

  @override
  String get settings_preferences => 'Preferences';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_distanceUnits => 'Distance units';

  @override
  String get settings_kilometers => 'Kilometers';

  @override
  String get settings_miles => 'Miles';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_themeSystem => 'System';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_about => 'About';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_helpAndSupport => 'Help & Support';

  @override
  String get settings_termsOfUse => 'Terms of Use';

  @override
  String get settings_privacyPolicy => 'Privacy Policy';

  @override
  String get settings_openSourceLicenses => 'Open source licenses';

  @override
  String get settings_logout => 'Log out';

  @override
  String get settings_deleteAccount => 'Delete my account';

  @override
  String get settings_deleteAccountConfirm => 'Delete my account?';

  @override
  String get settings_deleteAccountMessage =>
      'This action is irreversible. All your data, questions and answers will be permanently deleted.';

  @override
  String get settings_deleteAccountComingSoon =>
      'Account deletion - Coming soon';

  @override
  String settings_comingSoon(String feature) {
    return '$feature - Coming soon';
  }

  @override
  String get settings_languageFrench => 'Français';

  @override
  String get settings_languageEnglish => 'English';

  @override
  String get settings_languageJapanese => '日本語';

  @override
  String get settings_selectLanguage => 'Choose language';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_retry => 'Retry';

  @override
  String get profile_questions => 'Questions';

  @override
  String get profile_answers => 'Answers';

  @override
  String get profile_helpful => 'Helpful';

  @override
  String get profile_myQuestions => 'My questions';

  @override
  String get profile_myHelpfulAnswers => 'My helpful answers';

  @override
  String get profile_myHelpfulAnswersComingSoon =>
      'My helpful answers - Coming soon';

  @override
  String get profile_editProfile => 'Edit profile';

  @override
  String get editProfile_title => 'Edit profile';

  @override
  String get editProfile_save => 'Save';

  @override
  String get editProfile_displayName => 'Display name *';

  @override
  String get editProfile_nameTooShort => 'Name must be at least 2 characters';

  @override
  String get editProfile_nameTooLong => 'Name cannot exceed 50 characters';

  @override
  String get editProfile_bio => 'Bio (optional)';

  @override
  String get editProfile_bioHint => 'Tell us a bit more about yourself...';

  @override
  String get editProfile_bioTooLong => 'Bio cannot exceed 200 characters';

  @override
  String get editProfile_iAm => 'I am';

  @override
  String get editProfile_mainLocation => 'Main location';

  @override
  String get editProfile_country => 'Country';

  @override
  String get editProfile_spokenLanguages => 'Spoken languages';

  @override
  String get editProfile_addLanguage => 'Add a language';

  @override
  String get editProfile_selectLanguage => 'Select a language';

  @override
  String get editProfile_interests => 'Interests';

  @override
  String get editProfile_addInterest => 'Add an interest';

  @override
  String get editProfile_selectInterest => 'Select an interest';

  @override
  String get onboarding_next => 'Next';

  @override
  String get onboarding_skipIntro => 'Skip introduction';

  @override
  String get onboarding_start => 'Get started';

  @override
  String get onboarding_slide1Title => 'Ask your questions,\nwherever you are';

  @override
  String get onboarding_slide1Subtitle =>
      'Locals and travelers answer\nyou in real time';

  @override
  String get onboarding_slide2Title => 'Discover questions\naround you';

  @override
  String get onboarding_slide2Subtitle =>
      'Explore the map or browse\nthe forum for authentic\nanswers';

  @override
  String get onboarding_completeProfile => 'Complete your profile';

  @override
  String get onboarding_displayName => 'Display name *';

  @override
  String get onboarding_nameTooShort => 'Name must be at least 2 characters';

  @override
  String get onboarding_nameTooLong => 'Name cannot exceed 50 characters';

  @override
  String get onboarding_iAm => 'I am... *';

  @override
  String get onboarding_country => 'Country *';

  @override
  String get onboarding_bio => 'Bio (optional)';

  @override
  String get onboarding_bioHint => 'Tell us a bit more about yourself...';

  @override
  String get onboarding_bioTooLong => 'Bio cannot exceed 200 characters';

  @override
  String get onboarding_selectUserType => 'Please select your user type';

  @override
  String get questions_forum => 'Forum';

  @override
  String get questions_search => 'Search...';

  @override
  String get questions_retry => 'Retry';

  @override
  String get questions_noQuestions => 'No questions found';

  @override
  String get questions_recent => 'Recent';

  @override
  String get questions_popular => 'Popular';

  @override
  String get questions_allCities => 'All cities';

  @override
  String get questions_filterByCity => 'Filter by city';

  @override
  String get createQuestion_title => 'New Question';

  @override
  String get createQuestion_titleLabel => 'Question title *';

  @override
  String get createQuestion_titleHint => 'E.g.: Best ramen near Shibuya?';

  @override
  String get createQuestion_description => 'Description (optional)';

  @override
  String get createQuestion_descriptionHint =>
      'Describe your question in detail...';

  @override
  String get createQuestion_currentLocation => 'Current location';

  @override
  String get createQuestion_adjustLocation => 'Adjust location';

  @override
  String get createQuestion_publish => 'Publish';

  @override
  String get createQuestion_success => 'Question published successfully!';

  @override
  String get myQuestions_title => 'My Questions';

  @override
  String get myQuestions_retry => 'Retry';

  @override
  String get myQuestions_empty => 'No questions asked';

  @override
  String get myQuestions_emptyMessage =>
      'Start asking questions to get advice!';

  @override
  String get myQuestions_askQuestion => 'Ask a question';

  @override
  String get questionDetail_title => 'Details';

  @override
  String get questionDetail_reply => 'Reply';

  @override
  String get questionDetail_retry => 'Retry';

  @override
  String get questionDetail_user => 'User';

  @override
  String get answerInput_hint => 'Share your experience...';

  @override
  String get answerInput_cancel => 'Cancel';

  @override
  String get answerInput_send => 'Send';

  @override
  String get answerItem_yourAnswer => 'Your answer';

  @override
  String answerItem_rated(int rating) {
    return 'Rated $rating/5';
  }

  @override
  String get answerItem_rate => 'Rate:';

  @override
  String get answerItem_editRating => 'Edit your rating';

  @override
  String get locationPicker_title => 'Adjust location';

  @override
  String get locationPicker_confirm => 'Confirm';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_markAllRead => 'Read all';

  @override
  String get notifications_empty => 'No notifications';

  @override
  String get notifications_emptyMessage =>
      'You will be notified when someone\nanswers your questions';

  @override
  String get notifications_today => 'Today';

  @override
  String get notifications_yesterday => 'Yesterday';

  @override
  String get notifications_older => 'Older';

  @override
  String get notifications_markRead => 'Mark read';

  @override
  String get notifications_delete => 'Delete';

  @override
  String get notifications_deleted => 'Notification deleted';

  @override
  String get notificationSettings_title => 'Notifications';

  @override
  String get notificationSettings_preferences => 'Notification preferences';

  @override
  String get notificationSettings_newAnswers => 'New answers';

  @override
  String get notificationSettings_newAnswersDesc =>
      'Receive a notification when someone answers your questions';

  @override
  String get notificationSettings_nearbyQuestions => 'Nearby questions';

  @override
  String get notificationSettings_nearbyQuestionsDesc =>
      'Receive a notification for new questions in your area';

  @override
  String get notificationSettings_zoneSection => 'Notification zone';

  @override
  String get notificationSettings_configureZone => 'Configure my zone';

  @override
  String get notificationSettings_configureZoneDesc =>
      'Set the area in which you want to receive nearby questions';

  @override
  String get notificationSettings_maxPerDay =>
      'Maximum 5 notifications per day';

  @override
  String get notificationSettings_loadError => 'Loading error';

  @override
  String get notificationSettings_retry => 'Retry';

  @override
  String get notificationZone_title => 'Notification zone';

  @override
  String get notificationZone_save => 'Save';

  @override
  String notificationZone_radiusKm(int radius) {
    return 'Radius: $radius km';
  }

  @override
  String get notificationZone_myLocation => 'My location';

  @override
  String get notificationZone_instructions =>
      'Drag the marker or tap the map to set the center of your zone. You will receive notifications for questions posted in this zone (maximum 5 per day).';

  @override
  String get notificationZone_saved => 'Notification zone saved';

  @override
  String get notificationZone_locationError => 'Unable to get your location';

  @override
  String get search_hint => 'Search...';

  @override
  String get search_retry => 'Retry';

  @override
  String get search_recentSearches => 'Recent searches';

  @override
  String get search_clearHistory => 'Clear history';

  @override
  String get search_placeholder => 'Search for questions, places...';

  @override
  String search_resultsCount(int count) {
    return 'Questions ($count)';
  }

  @override
  String get search_noResults => 'No results found';

  @override
  String get search_noResultsHint => 'Try other keywords';

  @override
  String get search_loadError => 'Unable to load results';

  @override
  String get report_flagTooltip => 'Report';

  @override
  String get report_title => 'Report this content';

  @override
  String get report_reasonLabel => 'Reason for reporting:';

  @override
  String get report_comment => 'Comment (optional)';

  @override
  String get report_commentHint => 'Add details if needed...';

  @override
  String get report_cancel => 'Cancel';

  @override
  String get report_submit => 'Report';

  @override
  String get report_success =>
      'Report sent. Thank you for contributing to moderation.';

  @override
  String get avatar_changePhoto => 'Change photo';

  @override
  String get avatar_gallery => 'Gallery';

  @override
  String get avatar_camera => 'Camera';

  @override
  String get userType_traveler => 'Traveler';

  @override
  String get userType_travelerDesc => 'I travel and ask questions';

  @override
  String get userType_localSupporter => 'Local Supporter';

  @override
  String get userType_localSupporterDesc =>
      'I help travelers with my local knowledge';

  @override
  String get questionsErrorBanner_retry => 'Retry';

  @override
  String get map_search => 'Search...';

  @override
  String get map_retry => 'Retry';

  @override
  String get trust_title => 'Trust Score';

  @override
  String get trust_understood => 'Got it';

  @override
  String get trust_newUser => 'You are new!';

  @override
  String get trust_newUserDesc =>
      'Your trust score will be calculated after receiving ratings on at least 3 of your answers.';

  @override
  String trust_yourScore(String score) {
    return 'Your score: $score';
  }

  @override
  String get trust_howCalculated => 'How is it calculated?';

  @override
  String get trust_formula => 'Average rating × log(Number of answers + 1)';

  @override
  String get trust_avgRating =>
      'Average rating: Average of all ratings received on your answers';

  @override
  String get trust_answerCount =>
      'Number of answers: Number of answers rated by other users';

  @override
  String get trust_examples => 'Examples:';

  @override
  String get trust_example1 => '1 answer rated 5.0';

  @override
  String get trust_example1Calc => '5.0 × log(2) = 1.5';

  @override
  String get trust_example2 => '3 answers rated 4.5';

  @override
  String get trust_example2Calc => '4.5 × log(4) = 2.7';

  @override
  String get trust_example3 => '10 answers rated 4.5';

  @override
  String get trust_example3Calc => '4.5 × log(11) = 4.7';

  @override
  String get trust_whyTitle => 'Why this system?';

  @override
  String get trust_whyDesc =>
      'This score favors users who regularly give quality advice, while rewarding consistent contribution.';

  @override
  String get logout_title => 'Log out';

  @override
  String get logout_message => 'Are you sure you want to log out?';

  @override
  String get logout_cancel => 'Cancel';

  @override
  String get logout_confirm => 'Log out';

  @override
  String get auth_connectToStart => 'Sign in to get started';

  @override
  String get auth_continueWithGoogle => 'Continue with Google';

  @override
  String get auth_continueWithApple => 'Continue with Apple';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_delete => 'Delete';
}
