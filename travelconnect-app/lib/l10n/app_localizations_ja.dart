// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get nav_map => 'マップ';

  @override
  String get nav_forum => 'フォーラム';

  @override
  String get nav_notifications => '通知';

  @override
  String get nav_profile => 'プロフィール';

  @override
  String get settings_title => '設定';

  @override
  String get settings_account => 'アカウント';

  @override
  String get settings_editProfile => 'プロフィール編集';

  @override
  String get settings_privacy => 'プライバシー';

  @override
  String get settings_notifications => '通知';

  @override
  String get settings_manageNotifications => '通知設定を管理する';

  @override
  String get settings_preferences => '環境設定';

  @override
  String get settings_language => '言語';

  @override
  String get settings_distanceUnits => '距離の単位';

  @override
  String get settings_kilometers => 'キロメートル';

  @override
  String get settings_miles => 'マイル';

  @override
  String get settings_theme => 'テーマ';

  @override
  String get settings_themeSystem => 'システム';

  @override
  String get settings_themeLight => 'ライト';

  @override
  String get settings_themeDark => 'ダーク';

  @override
  String get settings_about => 'アプリについて';

  @override
  String get settings_version => 'バージョン';

  @override
  String get settings_helpAndSupport => 'ヘルプとサポート';

  @override
  String get settings_termsOfUse => '利用規約';

  @override
  String get settings_privacyPolicy => 'プライバシーポリシー';

  @override
  String get settings_openSourceLicenses => 'オープンソースライセンス';

  @override
  String get settings_logout => 'ログアウト';

  @override
  String get settings_deleteAccount => 'アカウントを削除';

  @override
  String get settings_deleteAccountConfirm => 'アカウントを削除しますか？';

  @override
  String get settings_deleteAccountMessage =>
      'この操作は取り消せません。すべてのデータ、質問、回答が完全に削除されます。';

  @override
  String get settings_deleteAccountComingSoon => 'アカウント削除 - 近日公開';

  @override
  String settings_comingSoon(String feature) {
    return '$feature - 近日公開';
  }

  @override
  String get settings_languageFrench => 'Français';

  @override
  String get settings_languageEnglish => 'English';

  @override
  String get settings_languageJapanese => '日本語';

  @override
  String get settings_selectLanguage => '言語を選択';

  @override
  String get profile_title => 'プロフィール';

  @override
  String get profile_retry => '再試行';

  @override
  String get profile_questions => '質問';

  @override
  String get profile_answers => '回答';

  @override
  String get profile_helpful => '役に立った';

  @override
  String get profile_myQuestions => 'マイ質問';

  @override
  String get profile_myHelpfulAnswers => '役に立った回答';

  @override
  String get profile_myHelpfulAnswersComingSoon => '役に立った回答 - 近日公開';

  @override
  String get profile_editProfile => 'プロフィール編集';

  @override
  String get editProfile_title => 'プロフィール編集';

  @override
  String get editProfile_save => '保存';

  @override
  String get editProfile_displayName => '表示名 *';

  @override
  String get editProfile_nameTooShort => '名前は2文字以上必要です';

  @override
  String get editProfile_nameTooLong => '名前は50文字以内にしてください';

  @override
  String get editProfile_bio => '自己紹介（任意）';

  @override
  String get editProfile_bioHint => 'あなたについて教えてください...';

  @override
  String get editProfile_bioTooLong => '自己紹介は200文字以内にしてください';

  @override
  String get editProfile_iAm => 'タイプ';

  @override
  String get editProfile_mainLocation => '主な活動場所';

  @override
  String get editProfile_country => '国';

  @override
  String get editProfile_spokenLanguages => '話せる言語';

  @override
  String get editProfile_addLanguage => '言語を追加';

  @override
  String get editProfile_selectLanguage => '言語を選択';

  @override
  String get editProfile_interests => '興味・関心';

  @override
  String get editProfile_addInterest => '興味を追加';

  @override
  String get editProfile_selectInterest => '興味を選択';

  @override
  String get onboarding_next => '次へ';

  @override
  String get onboarding_skipIntro => 'スキップ';

  @override
  String get onboarding_start => 'はじめる';

  @override
  String get onboarding_slide1Title => 'どこにいても\n質問できます';

  @override
  String get onboarding_slide1Subtitle => '地元の人や旅行者が\nリアルタイムで回答します';

  @override
  String get onboarding_slide2Title => 'あなたの周りの\n質問を発見';

  @override
  String get onboarding_slide2Subtitle => 'マップやフォーラムで\n本物の回答を\n見つけましょう';

  @override
  String get onboarding_completeProfile => 'プロフィールを完成させましょう';

  @override
  String get onboarding_displayName => '表示名 *';

  @override
  String get onboarding_nameTooShort => '名前は2文字以上必要です';

  @override
  String get onboarding_nameTooLong => '名前は50文字以内にしてください';

  @override
  String get onboarding_iAm => 'タイプ... *';

  @override
  String get onboarding_country => '国 *';

  @override
  String get onboarding_bio => '自己紹介（任意）';

  @override
  String get onboarding_bioHint => 'あなたについて教えてください...';

  @override
  String get onboarding_bioTooLong => '自己紹介は200文字以内にしてください';

  @override
  String get onboarding_selectUserType => 'ユーザータイプを選択してください';

  @override
  String get questions_forum => 'フォーラム';

  @override
  String get questions_search => '検索...';

  @override
  String get questions_retry => '再試行';

  @override
  String get questions_noQuestions => '質問が見つかりません';

  @override
  String get questions_recent => '最新';

  @override
  String get questions_popular => '人気';

  @override
  String get questions_allCities => 'すべての都市';

  @override
  String get questions_filterByCity => '都市で絞り込む';

  @override
  String get createQuestion_title => '新しい質問';

  @override
  String get createQuestion_titleLabel => '質問のタイトル *';

  @override
  String get createQuestion_titleHint => '例：渋谷近くのおすすめラーメンは？';

  @override
  String get createQuestion_description => '詳細（任意）';

  @override
  String get createQuestion_descriptionHint => '質問の詳細を記入してください...';

  @override
  String get createQuestion_currentLocation => '現在地';

  @override
  String get createQuestion_adjustLocation => '位置を調整';

  @override
  String get createQuestion_publish => '投稿';

  @override
  String get createQuestion_success => '質問が投稿されました！';

  @override
  String get myQuestions_title => 'マイ質問';

  @override
  String get myQuestions_retry => '再試行';

  @override
  String get myQuestions_empty => 'まだ質問がありません';

  @override
  String get myQuestions_emptyMessage => '質問してアドバイスをもらいましょう！';

  @override
  String get myQuestions_askQuestion => '質問する';

  @override
  String get questionDetail_title => '詳細';

  @override
  String get questionDetail_reply => '回答する';

  @override
  String get questionDetail_retry => '再試行';

  @override
  String get questionDetail_user => 'ユーザー';

  @override
  String get answerInput_hint => 'あなたの経験を共有しましょう...';

  @override
  String get answerInput_cancel => 'キャンセル';

  @override
  String get answerInput_send => '送信';

  @override
  String get answerItem_yourAnswer => 'あなたの回答';

  @override
  String answerItem_rated(int rating) {
    return '評価 $rating/5';
  }

  @override
  String get answerItem_rate => '評価：';

  @override
  String get answerItem_editRating => '評価を変更';

  @override
  String get locationPicker_title => '位置を調整';

  @override
  String get locationPicker_confirm => '確定';

  @override
  String get notifications_title => '通知';

  @override
  String get notifications_markAllRead => 'すべて既読';

  @override
  String get notifications_empty => '通知はありません';

  @override
  String get notifications_emptyMessage => '誰かがあなたの質問に\n回答すると通知されます';

  @override
  String get notifications_today => '今日';

  @override
  String get notifications_yesterday => '昨日';

  @override
  String get notifications_older => 'それ以前';

  @override
  String get notifications_markRead => '既読にする';

  @override
  String get notifications_delete => '削除';

  @override
  String get notifications_deleted => '通知を削除しました';

  @override
  String get notificationSettings_title => '通知';

  @override
  String get notificationSettings_preferences => '通知設定';

  @override
  String get notificationSettings_newAnswers => '新しい回答';

  @override
  String get notificationSettings_newAnswersDesc => 'あなたの質問に誰かが回答したとき通知を受け取る';

  @override
  String get notificationSettings_nearbyQuestions => '近くの質問';

  @override
  String get notificationSettings_nearbyQuestionsDesc =>
      'あなたのエリアに新しい質問が投稿されたとき通知を受け取る';

  @override
  String get notificationSettings_zoneSection => '通知ゾーン';

  @override
  String get notificationSettings_configureZone => 'ゾーンを設定';

  @override
  String get notificationSettings_configureZoneDesc =>
      '近くの質問を受け取りたいエリアを設定してください';

  @override
  String get notificationSettings_maxPerDay => '1日最大5件の通知';

  @override
  String get notificationSettings_loadError => '読み込みエラー';

  @override
  String get notificationSettings_retry => '再試行';

  @override
  String get notificationZone_title => '通知ゾーン';

  @override
  String get notificationZone_save => '保存';

  @override
  String notificationZone_radiusKm(int radius) {
    return '半径：$radius km';
  }

  @override
  String get notificationZone_myLocation => '現在地';

  @override
  String get notificationZone_instructions =>
      'マーカーをドラッグするか、マップをタップしてゾーンの中心を設定してください。このゾーン内に投稿された質問の通知を受け取ります（1日最大5件）。';

  @override
  String get notificationZone_saved => '通知ゾーンを保存しました';

  @override
  String get notificationZone_locationError => '現在地を取得できません';

  @override
  String get search_hint => '検索...';

  @override
  String get search_retry => '再試行';

  @override
  String get search_recentSearches => '最近の検索';

  @override
  String get search_clearHistory => '履歴を削除';

  @override
  String get search_placeholder => '質問や場所を検索...';

  @override
  String search_resultsCount(int count) {
    return '質問（$count件）';
  }

  @override
  String get search_noResults => '結果が見つかりません';

  @override
  String get search_noResultsHint => '別のキーワードで検索してみてください';

  @override
  String get search_loadError => '結果を読み込めません';

  @override
  String get report_flagTooltip => '報告';

  @override
  String get report_title => 'このコンテンツを報告';

  @override
  String get report_reasonLabel => '報告の理由：';

  @override
  String get report_comment => 'コメント（任意）';

  @override
  String get report_commentHint => '必要に応じて詳細を追加してください...';

  @override
  String get report_cancel => 'キャンセル';

  @override
  String get report_submit => '報告する';

  @override
  String get report_success => '報告が送信されました。モデレーションへのご協力ありがとうございます。';

  @override
  String get avatar_changePhoto => '写真を変更';

  @override
  String get avatar_gallery => 'ギャラリー';

  @override
  String get avatar_camera => 'カメラ';

  @override
  String get userType_traveler => '旅行者';

  @override
  String get userType_travelerDesc => '旅行して質問します';

  @override
  String get userType_localSupporter => 'ローカルサポーター';

  @override
  String get userType_localSupporterDesc => '地元の知識で旅行者をサポートします';

  @override
  String get questionsErrorBanner_retry => '再試行';

  @override
  String get map_search => '検索...';

  @override
  String get map_retry => '再試行';

  @override
  String get trust_title => '信頼スコア';

  @override
  String get trust_understood => '了解';

  @override
  String get trust_newUser => '新規ユーザーです！';

  @override
  String get trust_newUserDesc => '信頼スコアは、あなたの回答に3件以上の評価が付いた後に計算されます。';

  @override
  String trust_yourScore(String score) {
    return 'あなたのスコア：$score';
  }

  @override
  String get trust_howCalculated => '計算方法は？';

  @override
  String get trust_formula => '平均評価 × log(回答数 + 1)';

  @override
  String get trust_avgRating => '平均評価：あなたの回答に対するすべての評価の平均';

  @override
  String get trust_answerCount => '回答数：他のユーザーに評価された回答の数';

  @override
  String get trust_examples => '例：';

  @override
  String get trust_example1 => '1件の回答、評価5.0';

  @override
  String get trust_example1Calc => '5.0 × log(2) = 1.5';

  @override
  String get trust_example2 => '3件の回答、評価4.5';

  @override
  String get trust_example2Calc => '4.5 × log(4) = 2.7';

  @override
  String get trust_example3 => '10件の回答、評価4.5';

  @override
  String get trust_example3Calc => '4.5 × log(11) = 4.7';

  @override
  String get trust_whyTitle => 'なぜこのシステム？';

  @override
  String get trust_whyDesc => 'このスコアは、定期的に質の高いアドバイスをするユーザーを優遇し、継続的な貢献を評価します。';

  @override
  String get logout_title => 'ログアウト';

  @override
  String get logout_message => 'ログアウトしてもよろしいですか？';

  @override
  String get logout_cancel => 'キャンセル';

  @override
  String get logout_confirm => 'ログアウト';

  @override
  String get auth_connectToStart => 'ログインして始めましょう';

  @override
  String get auth_continueWithGoogle => 'Googleで続ける';

  @override
  String get auth_continueWithApple => 'Appleで続ける';

  @override
  String get common_cancel => 'キャンセル';

  @override
  String get common_save => '保存';

  @override
  String get common_retry => '再試行';

  @override
  String get common_delete => '削除';
}
