// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Career Readiness';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get onboardingTitle => 'Your profile';

  @override
  String get onboardingIntro =>
      'Tell us what you have studied and where you want to work. We compare it with what employers ask for.';

  @override
  String get majorLabel => 'Major';

  @override
  String get majorHint => 'e.g. Information Systems';

  @override
  String get careerLabel => 'Target career';

  @override
  String get careerRequired => 'Choose a career to continue.';

  @override
  String coursesLabel(int count) {
    return 'Completed courses ($count selected)';
  }

  @override
  String get coursesCatalogNote =>
      'Listed as they appear in the course catalog.';

  @override
  String get submit => 'See my readiness';

  @override
  String get submitFailed =>
      'Your profile could not be saved. Check the connection and try again.';

  @override
  String get readinessTitle => 'Readiness';

  @override
  String readinessFor(String career) {
    return 'Readiness for $career';
  }

  @override
  String get readinessExplained =>
      'The share of in-demand skills you already have, weighted by how often employers ask for each.';

  @override
  String coveredTitle(int count) {
    return 'Skills you have ($count)';
  }

  @override
  String get noneCovered =>
      'None of the in-demand skills yet. The list below shows where to start.';

  @override
  String missingTitle(int count) {
    return 'Skills to build, most in demand first ($count)';
  }

  @override
  String demandShare(String percent) {
    return 'in $percent of postings';
  }

  @override
  String get seeRecommendations => 'Suggested courses';

  @override
  String get recommendationsTitle => 'Suggested courses';

  @override
  String get suggestionTitle => 'Suggestions, not verdicts';

  @override
  String get suggestionBody =>
      'Courses are ranked by how much market demand they could help you cover. Treat them as a starting point for a conversation with your academic advisor, not as a decision or a guarantee.';

  @override
  String get couldHelpWith => 'Could help with';

  @override
  String get noRecommendations => 'No course in the catalog covers these gaps.';

  @override
  String get startOver => 'Start over';

  @override
  String universityCoursesTitle(int count) {
    return 'University courses ($count)';
  }

  @override
  String get universityCoursesNote =>
      'From your university\'s catalog. These count toward your degree.';

  @override
  String onlineCoursesTitle(int count) {
    return 'Online courses ($count)';
  }

  @override
  String get onlineCoursesNote =>
      'For skills no university course teaches. These don\'t count toward your degree.';

  @override
  String get countsTowardDegree => 'Counts toward your degree';

  @override
  String get notTowardDegree => 'Doesn\'t count toward your degree';

  @override
  String get free => 'Free';

  @override
  String get paid => 'Paid';

  @override
  String get noOnlineCourses =>
      'No online course is listed yet for the skills your university doesn\'t teach.';

  @override
  String uncoveredTitle(int count) {
    return 'No course listed yet ($count)';
  }

  @override
  String get uncoveredBody =>
      'No university course teaches these skills, and no online course has been listed for them yet.';

  @override
  String get qualityTitle => 'Estimates, not validated results';

  @override
  String get qualityTitlePassed => 'About these figures';

  @override
  String qualityGateFailed(String f1, String floor) {
    return 'In validation, the skill matcher scored F1 $f1, below the $floor it needed to pass. Read these figures as rough estimates.';
  }

  @override
  String get qualityCoursesUnchecked =>
      'Which skills each course teaches has not been checked against hand-labelled courses, so some courses may count for less than they should.';

  @override
  String get qualityEnglishSource =>
      'Market demand comes from English-language job postings. Skill names are shown in your chosen language.';

  @override
  String get errorUnreachable =>
      'Can\'t reach the server. Is the backend running?';

  @override
  String get errorServer => 'The server couldn\'t answer that request.';

  @override
  String get retry => 'Try again';

  @override
  String get careerBusinessAnalyst => 'Business Analyst';

  @override
  String get careerDataAnalyst => 'Data Analyst';

  @override
  String get careerErpConsultant => 'ERP Consultant';

  @override
  String get careerItSupportSpecialist => 'IT Support Specialist';

  @override
  String get careerSoftwareDeveloper => 'Software Developer';
}
