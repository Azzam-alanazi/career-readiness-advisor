import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Career Readiness'**
  String get appTitle;

  /// Always the name of the OTHER language, written in that language.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get switchLanguage;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get onboardingTitle;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you have studied and where you want to work. We compare it with what employers ask for.'**
  String get onboardingIntro;

  /// No description provided for @majorLabel.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get majorLabel;

  /// No description provided for @majorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Information Systems'**
  String get majorHint;

  /// No description provided for @careerLabel.
  ///
  /// In en, this message translates to:
  /// **'Target career'**
  String get careerLabel;

  /// No description provided for @careerRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a career to continue.'**
  String get careerRequired;

  /// No description provided for @coursesLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed courses ({count} selected)'**
  String coursesLabel(int count);

  /// No description provided for @coursesCatalogNote.
  ///
  /// In en, this message translates to:
  /// **'Listed as they appear in the course catalog.'**
  String get coursesCatalogNote;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'See my readiness'**
  String get submit;

  /// No description provided for @submitFailed.
  ///
  /// In en, this message translates to:
  /// **'Your profile could not be saved. Check the connection and try again.'**
  String get submitFailed;

  /// No description provided for @readinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Readiness'**
  String get readinessTitle;

  /// No description provided for @readinessFor.
  ///
  /// In en, this message translates to:
  /// **'Readiness for {career}'**
  String readinessFor(String career);

  /// No description provided for @readinessExplained.
  ///
  /// In en, this message translates to:
  /// **'The share of in-demand skills you already have, weighted by how often employers ask for each.'**
  String get readinessExplained;

  /// No description provided for @coveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Skills you have ({count})'**
  String coveredTitle(int count);

  /// No description provided for @noneCovered.
  ///
  /// In en, this message translates to:
  /// **'None of the in-demand skills yet. The list below shows where to start.'**
  String get noneCovered;

  /// No description provided for @missingTitle.
  ///
  /// In en, this message translates to:
  /// **'Skills to build, most in demand first ({count})'**
  String missingTitle(int count);

  /// No description provided for @demandShare.
  ///
  /// In en, this message translates to:
  /// **'in {percent} of postings'**
  String demandShare(String percent);

  /// No description provided for @seeRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Suggested courses'**
  String get seeRecommendations;

  /// No description provided for @recommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested courses'**
  String get recommendationsTitle;

  /// No description provided for @suggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions, not verdicts'**
  String get suggestionTitle;

  /// No description provided for @suggestionBody.
  ///
  /// In en, this message translates to:
  /// **'Courses are ranked by how much market demand they could help you cover. Treat them as a starting point for a conversation with your academic advisor, not as a decision or a guarantee.'**
  String get suggestionBody;

  /// No description provided for @couldHelpWith.
  ///
  /// In en, this message translates to:
  /// **'Could help with'**
  String get couldHelpWith;

  /// No description provided for @noRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No course in the catalog covers these gaps.'**
  String get noRecommendations;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// No description provided for @universityCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'University courses ({count})'**
  String universityCoursesTitle(int count);

  /// No description provided for @universityCoursesNote.
  ///
  /// In en, this message translates to:
  /// **'From your university\'s catalog. These count toward your degree.'**
  String get universityCoursesNote;

  /// No description provided for @onlineCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Online courses ({count})'**
  String onlineCoursesTitle(int count);

  /// No description provided for @onlineCoursesNote.
  ///
  /// In en, this message translates to:
  /// **'For skills no university course teaches. These don\'t count toward your degree.'**
  String get onlineCoursesNote;

  /// No description provided for @countsTowardDegree.
  ///
  /// In en, this message translates to:
  /// **'Counts toward your degree'**
  String get countsTowardDegree;

  /// No description provided for @notTowardDegree.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t count toward your degree'**
  String get notTowardDegree;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @noOnlineCourses.
  ///
  /// In en, this message translates to:
  /// **'No online course is listed yet for the skills your university doesn\'t teach.'**
  String get noOnlineCourses;

  /// No description provided for @uncoveredTitle.
  ///
  /// In en, this message translates to:
  /// **'No course listed yet ({count})'**
  String uncoveredTitle(int count);

  /// No description provided for @uncoveredBody.
  ///
  /// In en, this message translates to:
  /// **'No university course teaches these skills, and no online course has been listed for them yet.'**
  String get uncoveredBody;

  /// No description provided for @qualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimates, not validated results'**
  String get qualityTitle;

  /// No description provided for @qualityTitlePassed.
  ///
  /// In en, this message translates to:
  /// **'About these figures'**
  String get qualityTitlePassed;

  /// No description provided for @qualityGateFailed.
  ///
  /// In en, this message translates to:
  /// **'In validation, the skill matcher scored F1 {f1}, below the {floor} it needed to pass. Read these figures as rough estimates.'**
  String qualityGateFailed(String f1, String floor);

  /// No description provided for @qualityCoursesUnchecked.
  ///
  /// In en, this message translates to:
  /// **'Which skills each course teaches has not been checked against hand-labelled courses, so some courses may count for less than they should.'**
  String get qualityCoursesUnchecked;

  /// No description provided for @qualityEnglishSource.
  ///
  /// In en, this message translates to:
  /// **'Market demand comes from English-language job postings. Skill names are shown in your chosen language.'**
  String get qualityEnglishSource;

  /// No description provided for @errorUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Is the backend running?'**
  String get errorUnreachable;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server couldn\'t answer that request.'**
  String get errorServer;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @careerBusinessAnalyst.
  ///
  /// In en, this message translates to:
  /// **'Business Analyst'**
  String get careerBusinessAnalyst;

  /// No description provided for @careerDataAnalyst.
  ///
  /// In en, this message translates to:
  /// **'Data Analyst'**
  String get careerDataAnalyst;

  /// No description provided for @careerErpConsultant.
  ///
  /// In en, this message translates to:
  /// **'ERP Consultant'**
  String get careerErpConsultant;

  /// No description provided for @careerItSupportSpecialist.
  ///
  /// In en, this message translates to:
  /// **'IT Support Specialist'**
  String get careerItSupportSpecialist;

  /// No description provided for @careerSoftwareDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Software Developer'**
  String get careerSoftwareDeveloper;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
