import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('ja'),
  ];

  /// No description provided for @nav_map.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get nav_map;

  /// No description provided for @nav_forum.
  ///
  /// In fr, this message translates to:
  /// **'Forum'**
  String get nav_forum;

  /// No description provided for @nav_notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get nav_notifications;

  /// No description provided for @nav_profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get nav_profile;

  /// No description provided for @settings_title.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings_title;

  /// No description provided for @settings_account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settings_account;

  /// No description provided for @settings_editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get settings_editProfile;

  /// No description provided for @settings_privacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get settings_privacy;

  /// No description provided for @settings_notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_manageNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les préférences de notification'**
  String get settings_manageNotifications;

  /// No description provided for @settings_preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get settings_preferences;

  /// No description provided for @settings_language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settings_language;

  /// No description provided for @settings_distanceUnits.
  ///
  /// In fr, this message translates to:
  /// **'Unités de distance'**
  String get settings_distanceUnits;

  /// No description provided for @settings_kilometers.
  ///
  /// In fr, this message translates to:
  /// **'Kilomètres'**
  String get settings_kilometers;

  /// No description provided for @settings_miles.
  ///
  /// In fr, this message translates to:
  /// **'Miles'**
  String get settings_miles;

  /// No description provided for @settings_theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settings_theme;

  /// No description provided for @settings_themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settings_themeSystem;

  /// No description provided for @settings_themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settings_themeLight;

  /// No description provided for @settings_themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settings_themeDark;

  /// No description provided for @settings_about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settings_about;

  /// No description provided for @settings_version.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_helpAndSupport.
  ///
  /// In fr, this message translates to:
  /// **'Aide et support'**
  String get settings_helpAndSupport;

  /// No description provided for @settings_termsOfUse.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get settings_termsOfUse;

  /// No description provided for @settings_privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get settings_privacyPolicy;

  /// No description provided for @settings_openSourceLicenses.
  ///
  /// In fr, this message translates to:
  /// **'Licences open source'**
  String get settings_openSourceLicenses;

  /// No description provided for @settings_logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get settings_logout;

  /// No description provided for @settings_deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get settings_deleteAccount;

  /// No description provided for @settings_deleteAccountConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte ?'**
  String get settings_deleteAccountConfirm;

  /// No description provided for @settings_deleteAccountMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Toutes vos données, questions et réponses seront définitivement supprimées.'**
  String get settings_deleteAccountMessage;

  /// No description provided for @settings_deleteAccountComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Suppression de compte - Bientôt disponible'**
  String get settings_deleteAccountComingSoon;

  /// No description provided for @settings_comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'{feature} - Bientôt disponible'**
  String settings_comingSoon(String feature);

  /// No description provided for @settings_languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settings_languageFrench;

  /// No description provided for @settings_languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get settings_languageEnglish;

  /// No description provided for @settings_languageJapanese.
  ///
  /// In fr, this message translates to:
  /// **'日本語'**
  String get settings_languageJapanese;

  /// No description provided for @settings_selectLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get settings_selectLanguage;

  /// No description provided for @profile_title.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile_title;

  /// No description provided for @profile_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get profile_retry;

  /// No description provided for @profile_questions.
  ///
  /// In fr, this message translates to:
  /// **'Questions'**
  String get profile_questions;

  /// No description provided for @profile_answers.
  ///
  /// In fr, this message translates to:
  /// **'Réponses'**
  String get profile_answers;

  /// No description provided for @profile_helpful.
  ///
  /// In fr, this message translates to:
  /// **'Helpful'**
  String get profile_helpful;

  /// No description provided for @profile_myQuestions.
  ///
  /// In fr, this message translates to:
  /// **'Mes questions'**
  String get profile_myQuestions;

  /// No description provided for @profile_myHelpfulAnswers.
  ///
  /// In fr, this message translates to:
  /// **'Mes réponses utiles'**
  String get profile_myHelpfulAnswers;

  /// No description provided for @profile_myHelpfulAnswersComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Mes réponses utiles - Bientôt disponible'**
  String get profile_myHelpfulAnswersComingSoon;

  /// No description provided for @profile_editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profile_editProfile;

  /// No description provided for @editProfile_title.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfile_title;

  /// No description provided for @editProfile_save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get editProfile_save;

  /// No description provided for @editProfile_displayName.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'affichage *'**
  String get editProfile_displayName;

  /// No description provided for @editProfile_nameTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le nom doit contenir au moins 2 caractères'**
  String get editProfile_nameTooShort;

  /// No description provided for @editProfile_nameTooLong.
  ///
  /// In fr, this message translates to:
  /// **'Le nom ne peut pas dépasser 50 caractères'**
  String get editProfile_nameTooLong;

  /// No description provided for @editProfile_bio.
  ///
  /// In fr, this message translates to:
  /// **'Bio (optionnel)'**
  String get editProfile_bio;

  /// No description provided for @editProfile_bioHint.
  ///
  /// In fr, this message translates to:
  /// **'Dites-nous un peu plus sur vous...'**
  String get editProfile_bioHint;

  /// No description provided for @editProfile_bioTooLong.
  ///
  /// In fr, this message translates to:
  /// **'La bio ne peut pas dépasser 200 caractères'**
  String get editProfile_bioTooLong;

  /// No description provided for @editProfile_iAm.
  ///
  /// In fr, this message translates to:
  /// **'Je suis'**
  String get editProfile_iAm;

  /// No description provided for @editProfile_mainLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation principale'**
  String get editProfile_mainLocation;

  /// No description provided for @editProfile_country.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get editProfile_country;

  /// No description provided for @editProfile_spokenLanguages.
  ///
  /// In fr, this message translates to:
  /// **'Langues parlées'**
  String get editProfile_spokenLanguages;

  /// No description provided for @editProfile_addLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une langue'**
  String get editProfile_addLanguage;

  /// No description provided for @editProfile_selectLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une langue'**
  String get editProfile_selectLanguage;

  /// No description provided for @editProfile_interests.
  ///
  /// In fr, this message translates to:
  /// **'Centres d\'intérêt'**
  String get editProfile_interests;

  /// No description provided for @editProfile_addInterest.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un intérêt'**
  String get editProfile_addInterest;

  /// No description provided for @editProfile_selectInterest.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un centre d\'intérêt'**
  String get editProfile_selectInterest;

  /// No description provided for @onboarding_next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboarding_next;

  /// No description provided for @onboarding_skipIntro.
  ///
  /// In fr, this message translates to:
  /// **'Passer l\'introduction'**
  String get onboarding_skipIntro;

  /// No description provided for @onboarding_start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboarding_start;

  /// No description provided for @onboarding_slide1Title.
  ///
  /// In fr, this message translates to:
  /// **'Posez vos questions,\noù que vous soyez'**
  String get onboarding_slide1Title;

  /// No description provided for @onboarding_slide1Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Des locaux et voyageurs vous\nrépondent en temps réel'**
  String get onboarding_slide1Subtitle;

  /// No description provided for @onboarding_slide2Title.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez les questions\nautour de vous'**
  String get onboarding_slide2Title;

  /// No description provided for @onboarding_slide2Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Explorez la carte ou parcourez\nle forum pour trouver des\nréponses authentiques'**
  String get onboarding_slide2Subtitle;

  /// No description provided for @onboarding_completeProfile.
  ///
  /// In fr, this message translates to:
  /// **'Complétez votre profil'**
  String get onboarding_completeProfile;

  /// No description provided for @onboarding_displayName.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'affichage *'**
  String get onboarding_displayName;

  /// No description provided for @onboarding_nameTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le nom doit contenir au moins 2 caractères'**
  String get onboarding_nameTooShort;

  /// No description provided for @onboarding_nameTooLong.
  ///
  /// In fr, this message translates to:
  /// **'Le nom ne peut pas dépasser 50 caractères'**
  String get onboarding_nameTooLong;

  /// No description provided for @onboarding_iAm.
  ///
  /// In fr, this message translates to:
  /// **'Je suis... *'**
  String get onboarding_iAm;

  /// No description provided for @onboarding_country.
  ///
  /// In fr, this message translates to:
  /// **'Pays *'**
  String get onboarding_country;

  /// No description provided for @onboarding_bio.
  ///
  /// In fr, this message translates to:
  /// **'Bio (optionnel)'**
  String get onboarding_bio;

  /// No description provided for @onboarding_bioHint.
  ///
  /// In fr, this message translates to:
  /// **'Dites-nous un peu plus sur vous...'**
  String get onboarding_bioHint;

  /// No description provided for @onboarding_bioTooLong.
  ///
  /// In fr, this message translates to:
  /// **'La bio ne peut pas dépasser 200 caractères'**
  String get onboarding_bioTooLong;

  /// No description provided for @onboarding_selectUserType.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner votre type d\'utilisateur'**
  String get onboarding_selectUserType;

  /// No description provided for @questions_forum.
  ///
  /// In fr, this message translates to:
  /// **'Forum'**
  String get questions_forum;

  /// No description provided for @questions_search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher...'**
  String get questions_search;

  /// No description provided for @questions_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get questions_retry;

  /// No description provided for @questions_noQuestions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune question trouvée'**
  String get questions_noQuestions;

  /// No description provided for @questions_recent.
  ///
  /// In fr, this message translates to:
  /// **'Récentes'**
  String get questions_recent;

  /// No description provided for @questions_popular.
  ///
  /// In fr, this message translates to:
  /// **'Populaires'**
  String get questions_popular;

  /// No description provided for @questions_allCities.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les villes'**
  String get questions_allCities;

  /// No description provided for @questions_filterByCity.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par ville'**
  String get questions_filterByCity;

  /// No description provided for @createQuestion_title.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Question'**
  String get createQuestion_title;

  /// No description provided for @createQuestion_titleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Titre de la question *'**
  String get createQuestion_titleLabel;

  /// No description provided for @createQuestion_titleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Meilleur ramen près de Shibuya ?'**
  String get createQuestion_titleHint;

  /// No description provided for @createQuestion_description.
  ///
  /// In fr, this message translates to:
  /// **'Description (optionnel)'**
  String get createQuestion_description;

  /// No description provided for @createQuestion_descriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre question en détail...'**
  String get createQuestion_descriptionHint;

  /// No description provided for @createQuestion_currentLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation actuelle'**
  String get createQuestion_currentLocation;

  /// No description provided for @createQuestion_adjustLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ajuster la localisation'**
  String get createQuestion_adjustLocation;

  /// No description provided for @createQuestion_publish.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get createQuestion_publish;

  /// No description provided for @createQuestion_success.
  ///
  /// In fr, this message translates to:
  /// **'Question publiée avec succès !'**
  String get createQuestion_success;

  /// No description provided for @myQuestions_title.
  ///
  /// In fr, this message translates to:
  /// **'Mes Questions'**
  String get myQuestions_title;

  /// No description provided for @myQuestions_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get myQuestions_retry;

  /// No description provided for @myQuestions_empty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune question posée'**
  String get myQuestions_empty;

  /// No description provided for @myQuestions_emptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Commencez à poser des questions pour obtenir des conseils !'**
  String get myQuestions_emptyMessage;

  /// No description provided for @myQuestions_askQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Poser une question'**
  String get myQuestions_askQuestion;

  /// No description provided for @questionDetail_title.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get questionDetail_title;

  /// No description provided for @questionDetail_reply.
  ///
  /// In fr, this message translates to:
  /// **'Répondre'**
  String get questionDetail_reply;

  /// No description provided for @questionDetail_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get questionDetail_retry;

  /// No description provided for @questionDetail_user.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get questionDetail_user;

  /// No description provided for @answerInput_hint.
  ///
  /// In fr, this message translates to:
  /// **'Partagez votre expérience...'**
  String get answerInput_hint;

  /// No description provided for @answerInput_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get answerInput_cancel;

  /// No description provided for @answerInput_send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get answerInput_send;

  /// No description provided for @answerItem_yourAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Votre réponse'**
  String get answerItem_yourAnswer;

  /// No description provided for @answerItem_rated.
  ///
  /// In fr, this message translates to:
  /// **'Noté {rating}/5'**
  String answerItem_rated(int rating);

  /// No description provided for @answerItem_rate.
  ///
  /// In fr, this message translates to:
  /// **'Noter:'**
  String get answerItem_rate;

  /// No description provided for @answerItem_editRating.
  ///
  /// In fr, this message translates to:
  /// **'Modifier votre note'**
  String get answerItem_editRating;

  /// No description provided for @locationPicker_title.
  ///
  /// In fr, this message translates to:
  /// **'Ajuster la localisation'**
  String get locationPicker_title;

  /// No description provided for @locationPicker_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get locationPicker_confirm;

  /// No description provided for @notifications_title.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_markAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout lire'**
  String get notifications_markAllRead;

  /// No description provided for @notifications_empty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get notifications_empty;

  /// No description provided for @notifications_emptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez notifié quand quelqu\'un\nrépondra à vos questions'**
  String get notifications_emptyMessage;

  /// No description provided for @notifications_today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get notifications_today;

  /// No description provided for @notifications_yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get notifications_yesterday;

  /// No description provided for @notifications_older.
  ///
  /// In fr, this message translates to:
  /// **'Plus ancien'**
  String get notifications_older;

  /// No description provided for @notifications_markRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer lu'**
  String get notifications_markRead;

  /// No description provided for @notifications_delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get notifications_delete;

  /// No description provided for @notifications_deleted.
  ///
  /// In fr, this message translates to:
  /// **'Notification supprimée'**
  String get notifications_deleted;

  /// No description provided for @notificationSettings_title.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationSettings_title;

  /// No description provided for @notificationSettings_preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences de notification'**
  String get notificationSettings_preferences;

  /// No description provided for @notificationSettings_newAnswers.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles réponses'**
  String get notificationSettings_newAnswers;

  /// No description provided for @notificationSettings_newAnswersDesc.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir une notification quand quelqu\'un répond à vos questions'**
  String get notificationSettings_newAnswersDesc;

  /// No description provided for @notificationSettings_nearbyQuestions.
  ///
  /// In fr, this message translates to:
  /// **'Questions proches'**
  String get notificationSettings_nearbyQuestions;

  /// No description provided for @notificationSettings_nearbyQuestionsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir une notification pour les nouvelles questions dans votre zone'**
  String get notificationSettings_nearbyQuestionsDesc;

  /// No description provided for @notificationSettings_zoneSection.
  ///
  /// In fr, this message translates to:
  /// **'Zone de notification'**
  String get notificationSettings_zoneSection;

  /// No description provided for @notificationSettings_configureZone.
  ///
  /// In fr, this message translates to:
  /// **'Configurer ma zone'**
  String get notificationSettings_configureZone;

  /// No description provided for @notificationSettings_configureZoneDesc.
  ///
  /// In fr, this message translates to:
  /// **'Définissez la zone dans laquelle vous souhaitez recevoir les questions proches'**
  String get notificationSettings_configureZoneDesc;

  /// No description provided for @notificationSettings_maxPerDay.
  ///
  /// In fr, this message translates to:
  /// **'Maximum 5 notifications par jour'**
  String get notificationSettings_maxPerDay;

  /// No description provided for @notificationSettings_loadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get notificationSettings_loadError;

  /// No description provided for @notificationSettings_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get notificationSettings_retry;

  /// No description provided for @notificationZone_title.
  ///
  /// In fr, this message translates to:
  /// **'Zone de notification'**
  String get notificationZone_title;

  /// No description provided for @notificationZone_save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get notificationZone_save;

  /// No description provided for @notificationZone_radiusKm.
  ///
  /// In fr, this message translates to:
  /// **'Rayon: {radius} km'**
  String notificationZone_radiusKm(int radius);

  /// No description provided for @notificationZone_myLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get notificationZone_myLocation;

  /// No description provided for @notificationZone_instructions.
  ///
  /// In fr, this message translates to:
  /// **'Déplacez le marqueur ou tapez sur la carte pour définir le centre de votre zone. Vous recevrez des notifications pour les questions posées dans cette zone (maximum 5 par jour).'**
  String get notificationZone_instructions;

  /// No description provided for @notificationZone_saved.
  ///
  /// In fr, this message translates to:
  /// **'Zone de notification enregistrée'**
  String get notificationZone_saved;

  /// No description provided for @notificationZone_locationError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'obtenir votre position'**
  String get notificationZone_locationError;

  /// No description provided for @search_hint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher...'**
  String get search_hint;

  /// No description provided for @search_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get search_retry;

  /// No description provided for @search_recentSearches.
  ///
  /// In fr, this message translates to:
  /// **'Recherches récentes'**
  String get search_recentSearches;

  /// No description provided for @search_clearHistory.
  ///
  /// In fr, this message translates to:
  /// **'Effacer l\'historique'**
  String get search_clearHistory;

  /// No description provided for @search_placeholder.
  ///
  /// In fr, this message translates to:
  /// **'Recherchez des questions, des lieux...'**
  String get search_placeholder;

  /// No description provided for @search_resultsCount.
  ///
  /// In fr, this message translates to:
  /// **'Questions ({count})'**
  String search_resultsCount(int count);

  /// No description provided for @search_noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat trouvé'**
  String get search_noResults;

  /// No description provided for @search_noResultsHint.
  ///
  /// In fr, this message translates to:
  /// **'Essayez avec d\'autres mots-clés'**
  String get search_noResultsHint;

  /// No description provided for @search_loadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les résultats'**
  String get search_loadError;

  /// No description provided for @report_flagTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get report_flagTooltip;

  /// No description provided for @report_title.
  ///
  /// In fr, this message translates to:
  /// **'Signaler ce contenu'**
  String get report_title;

  /// No description provided for @report_reasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Raison du signalement :'**
  String get report_reasonLabel;

  /// No description provided for @report_comment.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire (optionnel)'**
  String get report_comment;

  /// No description provided for @report_commentHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des détails si nécessaire...'**
  String get report_commentHint;

  /// No description provided for @report_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get report_cancel;

  /// No description provided for @report_submit.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get report_submit;

  /// No description provided for @report_success.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé. Merci de contribuer à la modération.'**
  String get report_success;

  /// No description provided for @avatar_changePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get avatar_changePhoto;

  /// No description provided for @avatar_gallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get avatar_gallery;

  /// No description provided for @avatar_camera.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get avatar_camera;

  /// No description provided for @userType_traveler.
  ///
  /// In fr, this message translates to:
  /// **'Voyageur'**
  String get userType_traveler;

  /// No description provided for @userType_travelerDesc.
  ///
  /// In fr, this message translates to:
  /// **'Je voyage et je pose des questions'**
  String get userType_travelerDesc;

  /// No description provided for @userType_localSupporter.
  ///
  /// In fr, this message translates to:
  /// **'Local Supporter'**
  String get userType_localSupporter;

  /// No description provided for @userType_localSupporterDesc.
  ///
  /// In fr, this message translates to:
  /// **'J\'aide les voyageurs avec mes connaissances locales'**
  String get userType_localSupporterDesc;

  /// No description provided for @questionsErrorBanner_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get questionsErrorBanner_retry;

  /// No description provided for @map_search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher...'**
  String get map_search;

  /// No description provided for @map_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get map_retry;

  /// No description provided for @trust_title.
  ///
  /// In fr, this message translates to:
  /// **'Score de Confiance'**
  String get trust_title;

  /// No description provided for @trust_understood.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get trust_understood;

  /// No description provided for @trust_newUser.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes nouveau !'**
  String get trust_newUser;

  /// No description provided for @trust_newUserDesc.
  ///
  /// In fr, this message translates to:
  /// **'Votre score de confiance sera calculé après avoir reçu des notes sur au moins 3 de vos réponses.'**
  String get trust_newUserDesc;

  /// No description provided for @trust_yourScore.
  ///
  /// In fr, this message translates to:
  /// **'Votre score : {score}'**
  String trust_yourScore(String score);

  /// No description provided for @trust_howCalculated.
  ///
  /// In fr, this message translates to:
  /// **'Comment est-il calculé ?'**
  String get trust_howCalculated;

  /// No description provided for @trust_formula.
  ///
  /// In fr, this message translates to:
  /// **'Note moyenne × log(Nombre de réponses + 1)'**
  String get trust_formula;

  /// No description provided for @trust_avgRating.
  ///
  /// In fr, this message translates to:
  /// **'Note moyenne : Moyenne de toutes les notes reçues sur vos réponses'**
  String get trust_avgRating;

  /// No description provided for @trust_answerCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de réponses : Nombre de réponses notées par d\'autres utilisateurs'**
  String get trust_answerCount;

  /// No description provided for @trust_examples.
  ///
  /// In fr, this message translates to:
  /// **'Exemples :'**
  String get trust_examples;

  /// No description provided for @trust_example1.
  ///
  /// In fr, this message translates to:
  /// **'1 réponse notée 5.0'**
  String get trust_example1;

  /// No description provided for @trust_example1Calc.
  ///
  /// In fr, this message translates to:
  /// **'5.0 × log(2) = 1.5'**
  String get trust_example1Calc;

  /// No description provided for @trust_example2.
  ///
  /// In fr, this message translates to:
  /// **'3 réponses notées 4.5'**
  String get trust_example2;

  /// No description provided for @trust_example2Calc.
  ///
  /// In fr, this message translates to:
  /// **'4.5 × log(4) = 2.7'**
  String get trust_example2Calc;

  /// No description provided for @trust_example3.
  ///
  /// In fr, this message translates to:
  /// **'10 réponses notées 4.5'**
  String get trust_example3;

  /// No description provided for @trust_example3Calc.
  ///
  /// In fr, this message translates to:
  /// **'4.5 × log(11) = 4.7'**
  String get trust_example3Calc;

  /// No description provided for @trust_whyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi ce système ?'**
  String get trust_whyTitle;

  /// No description provided for @trust_whyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ce score favorise les utilisateurs qui donnent régulièrement des conseils de qualité, tout en récompensant la contribution constante.'**
  String get trust_whyDesc;

  /// No description provided for @logout_title.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout_title;

  /// No description provided for @logout_message.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get logout_message;

  /// No description provided for @logout_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get logout_cancel;

  /// No description provided for @logout_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout_confirm;

  /// No description provided for @auth_connectToStart.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour commencer'**
  String get auth_connectToStart;

  /// No description provided for @auth_continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get auth_continueWithGoogle;

  /// No description provided for @auth_continueWithApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get auth_continueWithApple;

  /// No description provided for @common_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get common_save;

  /// No description provided for @common_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get common_retry;

  /// No description provided for @common_delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get common_delete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
