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
  /// **'Target careers'**
  String get careerLabel;

  /// No description provided for @careersHint.
  ///
  /// In en, this message translates to:
  /// **'Choose one, or up to three to compare side by side.'**
  String get careersHint;

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

  /// No description provided for @coursesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by code or title'**
  String get coursesSearchHint;

  /// No description provided for @coursesClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get coursesClearSearch;

  /// No description provided for @coursesSelectShown.
  ///
  /// In en, this message translates to:
  /// **'Select all shown ({count})'**
  String coursesSelectShown(int count);

  /// No description provided for @coursesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No course matches your search.'**
  String get coursesNoMatch;

  /// No description provided for @coursesQuickSelect.
  ///
  /// In en, this message translates to:
  /// **'Quick select:'**
  String get coursesQuickSelect;

  /// No description provided for @coursesUpToLevel.
  ///
  /// In en, this message translates to:
  /// **'All {level}-level and below'**
  String coursesUpToLevel(int level);

  /// No description provided for @trackCollege.
  ///
  /// In en, this message translates to:
  /// **'College requirements'**
  String get trackCollege;

  /// No description provided for @trackCore.
  ///
  /// In en, this message translates to:
  /// **'IS core'**
  String get trackCore;

  /// No description provided for @trackElectiveAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Electives: business analytics'**
  String get trackElectiveAnalytics;

  /// No description provided for @trackElectiveEcommerce.
  ///
  /// In en, this message translates to:
  /// **'Electives: e-commerce'**
  String get trackElectiveEcommerce;

  /// No description provided for @trackOther.
  ///
  /// In en, this message translates to:
  /// **'Other courses'**
  String get trackOther;

  /// No description provided for @trackSelected.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String trackSelected(int selected, int total);

  /// No description provided for @selectedCourses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No courses selected} =1{1 course selected} other{{count} courses selected}}'**
  String selectedCourses(int count);

  /// No description provided for @coursesReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get coursesReview;

  /// No description provided for @coursesClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get coursesClear;

  /// No description provided for @coursesCleared.
  ///
  /// In en, this message translates to:
  /// **'Selection cleared.'**
  String get coursesCleared;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @coursesReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected courses'**
  String get coursesReviewTitle;

  /// No description provided for @coursesClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get coursesClearAll;

  /// No description provided for @coursesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get coursesRemove;

  /// No description provided for @coursesDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get coursesDone;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'See my readiness'**
  String get submit;

  /// No description provided for @submitFailed.
  ///
  /// In en, this message translates to:
  /// **'Your profile could not be saved on this device. Try again.'**
  String get submitFailed;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile'**
  String get editProfileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsCourses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No completed courses} =1{1 completed course} other{{count} completed courses}}'**
  String settingsCourses(int count);

  /// No description provided for @settingsSkills.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No self-reported skills} =1{1 self-reported skill} other{{count} self-reported skills}}'**
  String settingsSkills(int count);

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsStorage.
  ///
  /// In en, this message translates to:
  /// **'Kept on this device'**
  String get settingsStorage;

  /// No description provided for @settingsLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Your profile is saved on this device only. Nothing about you is stored on a server, and there is no account, so removing the app removes your profile too.'**
  String get settingsLocalOnly;

  /// No description provided for @settingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get settingsDelete;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your profile?'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes your careers, courses and skills from this device, and you start again from the beginning.'**
  String get settingsDeleteBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @nextToSkills.
  ///
  /// In en, this message translates to:
  /// **'Next: other skills'**
  String get nextToSkills;

  /// No description provided for @skillsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other skills'**
  String get skillsTitle;

  /// No description provided for @skillsIntro.
  ///
  /// In en, this message translates to:
  /// **'Optional. Tick any skills you have from outside your courses: self-study, certifications or work experience.'**
  String get skillsIntro;

  /// No description provided for @skillsUnverified.
  ///
  /// In en, this message translates to:
  /// **'These are self-reported and unverified. Your readiness shows them apart from your courses.'**
  String get skillsUnverified;

  /// No description provided for @skillsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search skills'**
  String get skillsSearchHint;

  /// No description provided for @skillsSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}'**
  String skillsSelected(int count);

  /// No description provided for @skillFromCourses.
  ///
  /// In en, this message translates to:
  /// **'From your courses'**
  String get skillFromCourses;

  /// No description provided for @skillsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No skill matches your search.'**
  String get skillsNoMatch;

  /// No description provided for @coveredFromCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'From your courses ({count})'**
  String coveredFromCoursesTitle(int count);

  /// No description provided for @coveredSelfReportedTitle.
  ///
  /// In en, this message translates to:
  /// **'Self-reported ({count})'**
  String coveredSelfReportedTitle(int count);

  /// No description provided for @readinessFromCoursesOnly.
  ///
  /// In en, this message translates to:
  /// **'From your courses alone: {percent}'**
  String readinessFromCoursesOnly(String percent);

  /// No description provided for @categoryBusinessAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Business analysis and delivery'**
  String get categoryBusinessAnalysis;

  /// No description provided for @categoryData.
  ///
  /// In en, this message translates to:
  /// **'Data and analytics'**
  String get categoryData;

  /// No description provided for @categorySoftwareDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Software development'**
  String get categorySoftwareDevelopment;

  /// No description provided for @categoryInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure, cloud and networks'**
  String get categoryInfrastructure;

  /// No description provided for @categoryItSupport.
  ///
  /// In en, this message translates to:
  /// **'IT support and service management'**
  String get categoryItSupport;

  /// No description provided for @categorySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get categorySecurity;

  /// No description provided for @categoryErp.
  ///
  /// In en, this message translates to:
  /// **'ERP and enterprise processes'**
  String get categoryErp;

  /// No description provided for @categoryProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional skills'**
  String get categoryProfessional;

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

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Your careers side by side'**
  String get compareTitle;

  /// No description provided for @compareCovered.
  ///
  /// In en, this message translates to:
  /// **'Covered: {count}'**
  String compareCovered(int count);

  /// No description provided for @compareMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing: {count}'**
  String compareMissing(int count);

  /// No description provided for @compareFromCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses alone: {percent}'**
  String compareFromCourses(String percent);

  /// No description provided for @compareClosest.
  ///
  /// In en, this message translates to:
  /// **'Closest'**
  String get compareClosest;

  /// No description provided for @compareNote.
  ///
  /// In en, this message translates to:
  /// **'Tap a career to see its details below. Each score rests on the few postings shown under its name, so a few points apart is not a real difference.'**
  String get compareNote;

  /// No description provided for @recommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested courses'**
  String get recommendationsTitle;

  /// No description provided for @recommendationsFor.
  ///
  /// In en, this message translates to:
  /// **'For {career}'**
  String recommendationsFor(String career);

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

  /// No description provided for @navStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get navStudent;

  /// No description provided for @navDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get navDepartment;

  /// No description provided for @curriculumTitle.
  ///
  /// In en, this message translates to:
  /// **'Curriculum gaps'**
  String get curriculumTitle;

  /// No description provided for @curriculumIntro.
  ///
  /// In en, this message translates to:
  /// **'For the department: how the course catalog lines up with what job postings ask for.'**
  String get curriculumIntro;

  /// No description provided for @postingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 job posting} other{{count} job postings}}'**
  String postingsCount(int count);

  /// No description provided for @curriculumSampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Indicative only: {postings}'**
  String curriculumSampleTitle(String postings);

  /// No description provided for @curriculumSampleBody.
  ///
  /// In en, this message translates to:
  /// **'These gaps come from {postings}, {min} to {max} per career. At that size, a skill one or two postings mention can appear or disappear with the next few. Treat each gap as a question worth looking into, not as grounds on its own for changing the curriculum.'**
  String curriculumSampleBody(String postings, int min, int max);

  /// No description provided for @curriculumAllCareers.
  ///
  /// In en, this message translates to:
  /// **'All careers'**
  String get curriculumAllCareers;

  /// No description provided for @curriculumCoverageFor.
  ///
  /// In en, this message translates to:
  /// **'Coverage: {scope}'**
  String curriculumCoverageFor(String scope);

  /// No description provided for @curriculumCoverageLine.
  ///
  /// In en, this message translates to:
  /// **'{taught} of the {demanded} skills that {postings} ask for are taught by at least one course.'**
  String curriculumCoverageLine(int taught, int demanded, String postings);

  /// No description provided for @curriculumCoverageCounting.
  ///
  /// In en, this message translates to:
  /// **'Each skill counts once, however many postings ask for it.'**
  String get curriculumCoverageCounting;

  /// No description provided for @curriculumUncoveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Asked for, not taught ({count})'**
  String curriculumUncoveredTitle(int count);

  /// No description provided for @curriculumUncoveredNote.
  ///
  /// In en, this message translates to:
  /// **'Skills the postings ask for that no course in the catalog teaches, most in demand first.'**
  String get curriculumUncoveredNote;

  /// No description provided for @curriculumNoneUncovered.
  ///
  /// In en, this message translates to:
  /// **'Every skill the postings ask for is taught by at least one course.'**
  String get curriculumNoneUncovered;

  /// No description provided for @curriculumAskedIn.
  ///
  /// In en, this message translates to:
  /// **'Asked for in: {careers}'**
  String curriculumAskedIn(String careers);

  /// No description provided for @curriculumByCareerTitle.
  ///
  /// In en, this message translates to:
  /// **'Coverage by career'**
  String get curriculumByCareerTitle;

  /// No description provided for @curriculumCareerLine.
  ///
  /// In en, this message translates to:
  /// **'{taught} of {demanded} demanded skills taught · {postings}'**
  String curriculumCareerLine(int taught, int demanded, String postings);

  /// No description provided for @curriculumNotAskedTitle.
  ///
  /// In en, this message translates to:
  /// **'Taught, not asked for ({count})'**
  String curriculumNotAskedTitle(int count);

  /// No description provided for @curriculumNotAskedNote.
  ///
  /// In en, this message translates to:
  /// **'Skills the catalog teaches that no posting in this view asks for. Not asked for is not the same as not needed: a sample this small misses a lot.'**
  String get curriculumNotAskedNote;

  /// No description provided for @curriculumNoneNotAsked.
  ///
  /// In en, this message translates to:
  /// **'Every skill the catalog teaches is asked for by at least one posting.'**
  String get curriculumNoneNotAsked;

  /// No description provided for @curriculumTaughtIn.
  ///
  /// In en, this message translates to:
  /// **'Taught in: {courses}'**
  String curriculumTaughtIn(String courses);

  /// No description provided for @curriculumThreshold.
  ///
  /// In en, this message translates to:
  /// **'Counted: skills named in at least {k} of a career\'s postings.'**
  String curriculumThreshold(String k);

  /// No description provided for @curriculumThresholdLeftOut.
  ///
  /// In en, this message translates to:
  /// **'{count} named by fewer are left out and listed below.'**
  String curriculumThresholdLeftOut(int count);

  /// No description provided for @curriculumBelowTitle.
  ///
  /// In en, this message translates to:
  /// **'Named, but below the threshold ({count})'**
  String curriculumBelowTitle(int count);

  /// No description provided for @curriculumBelowNote.
  ///
  /// In en, this message translates to:
  /// **'Each is named by at least one posting, but by fewer than {k} of any career\'s postings, so it counts as neither demanded nor not asked for. The threshold is a share of postings, so the number of postings it takes grows with the sample.'**
  String curriculumBelowNote(String k);

  /// No description provided for @curriculumNotTaught.
  ///
  /// In en, this message translates to:
  /// **'Taught in no course'**
  String get curriculumNotTaught;

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

  /// No description provided for @careerDatabaseAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Database Administrator'**
  String get careerDatabaseAdministrator;

  /// No description provided for @careerCybersecurityAnalyst.
  ///
  /// In en, this message translates to:
  /// **'Cybersecurity Analyst'**
  String get careerCybersecurityAnalyst;

  /// No description provided for @careerItProjectManager.
  ///
  /// In en, this message translates to:
  /// **'IT Project Manager'**
  String get careerItProjectManager;
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
