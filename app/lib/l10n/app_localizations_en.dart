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
  String get careerLabel => 'Target careers';

  @override
  String get careersHint =>
      'Choose one, or up to three to compare side by side.';

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
  String get coursesSearchHint => 'Search by code or title';

  @override
  String get coursesClearSearch => 'Clear search';

  @override
  String coursesSelectShown(int count) {
    return 'Select all shown ($count)';
  }

  @override
  String get coursesNoMatch => 'No course matches your search.';

  @override
  String get coursesQuickSelect => 'Quick select:';

  @override
  String coursesUpToLevel(int level) {
    return 'All $level-level and below';
  }

  @override
  String get trackCollege => 'College requirements';

  @override
  String get trackCore => 'IS core';

  @override
  String get trackElectiveAnalytics => 'Electives: business analytics';

  @override
  String get trackElectiveEcommerce => 'Electives: e-commerce';

  @override
  String get trackOther => 'Other courses';

  @override
  String trackSelected(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String selectedCourses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses selected',
      one: '1 course selected',
      zero: 'No courses selected',
    );
    return '$_temp0';
  }

  @override
  String get coursesReview => 'Review';

  @override
  String get coursesClear => 'Clear';

  @override
  String get coursesCleared => 'Selection cleared.';

  @override
  String get undo => 'Undo';

  @override
  String get coursesReviewTitle => 'Selected courses';

  @override
  String get coursesClearAll => 'Clear all';

  @override
  String get coursesRemove => 'Remove';

  @override
  String get coursesDone => 'Done';

  @override
  String get submit => 'See my readiness';

  @override
  String get submitFailed =>
      'Your profile could not be saved on this device. Try again.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get editProfileTitle => 'Edit your profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String settingsCourses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed courses',
      one: '1 completed course',
      zero: 'No completed courses',
    );
    return '$_temp0';
  }

  @override
  String settingsSkills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count self-reported skills',
      one: '1 self-reported skill',
      zero: 'No self-reported skills',
    );
    return '$_temp0';
  }

  @override
  String get settingsEditProfile => 'Edit profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsStorage => 'Kept on this device';

  @override
  String get settingsLocalOnly =>
      'Your profile is saved on this device only. Nothing about you is stored on a server, and there is no account, so removing the app removes your profile too.';

  @override
  String get settingsDelete => 'Delete profile';

  @override
  String get settingsDeleteTitle => 'Delete your profile?';

  @override
  String get settingsDeleteBody =>
      'This removes your careers, courses and skills from this device, and you start again from the beginning.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get nextToSkills => 'Next: other skills';

  @override
  String get skillsTitle => 'Other skills';

  @override
  String get skillsIntro =>
      'Optional. Tick any skills you have from outside your courses: self-study, certifications or work experience.';

  @override
  String get skillsUnverified =>
      'These are self-reported and unverified. Your readiness shows them apart from your courses.';

  @override
  String get skillsSearchHint => 'Search skills';

  @override
  String skillsSelected(int count) {
    return 'Selected: $count';
  }

  @override
  String get skillFromCourses => 'From your courses';

  @override
  String get skillsNoMatch => 'No skill matches your search.';

  @override
  String coveredFromCoursesTitle(int count) {
    return 'From your courses ($count)';
  }

  @override
  String coveredSelfReportedTitle(int count) {
    return 'Self-reported ($count)';
  }

  @override
  String readinessFromCoursesOnly(String percent) {
    return 'From your courses alone: $percent';
  }

  @override
  String get categoryBusinessAnalysis => 'Business analysis and delivery';

  @override
  String get categoryData => 'Data and analytics';

  @override
  String get categorySoftwareDevelopment => 'Software development';

  @override
  String get categoryInfrastructure => 'Infrastructure, cloud and networks';

  @override
  String get categoryItSupport => 'IT support and service management';

  @override
  String get categorySecurity => 'Security';

  @override
  String get categoryErp => 'ERP and enterprise processes';

  @override
  String get categoryProfessional => 'Professional skills';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeTopGaps => 'Your top gaps';

  @override
  String get homeNoGaps =>
      'No gaps: you have every skill these postings ask for.';

  @override
  String get homeFullReadiness => 'Full readiness';

  @override
  String get homeFullReadinessHint =>
      'Skills you have and still need, and your careers side by side';

  @override
  String get homeSettingsHint => 'Edit your profile or change the language';

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
  String get planTitle => 'Plan courses';

  @override
  String get planIntro =>
      'Mark courses you plan to take. The projection counts them as if completed; your record stays as it is.';

  @override
  String get planNow => 'now';

  @override
  String planWith(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'if you take your $count planned courses',
      one: 'if you take your planned course',
    );
    return '$_temp0';
  }

  @override
  String planPoints(int points) {
    return '+$points points';
  }

  @override
  String get planNothingYet => 'Tick courses below to see what they would add.';

  @override
  String planClosesCount(int closed, int missing) {
    return 'Your plan closes $closed of your $missing gaps.';
  }

  @override
  String get planCoursesTitle => 'Courses you could take';

  @override
  String get planExplained =>
      'Each course lists the gaps it would close for this career, most in demand first. A gap two courses close counts once.';

  @override
  String get planCompletedNote =>
      'Completed courses already count, so they are not listed.';

  @override
  String planCloses(String skills) {
    return 'Closes: $skills';
  }

  @override
  String get planClosesNone =>
      'Closes none of your current gaps for this career.';

  @override
  String planPlannedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planned courses',
      one: '1 planned course',
      zero: 'No planned courses',
    );
    return '$_temp0';
  }

  @override
  String get compareTitle => 'Your careers side by side';

  @override
  String compareCovered(int count) {
    return 'Covered: $count';
  }

  @override
  String compareMissing(int count) {
    return 'Missing: $count';
  }

  @override
  String compareFromCourses(String percent) {
    return 'Courses alone: $percent';
  }

  @override
  String get compareClosest => 'Closest';

  @override
  String get compareNote =>
      'Tap a career to see its details below. Each score rests on the few postings shown under its name, so a few points apart is not a real difference.';

  @override
  String get recommendationsTitle => 'Suggested courses';

  @override
  String recommendationsFor(String career) {
    return 'For $career';
  }

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
  String get navStudent => 'Student';

  @override
  String get navDepartment => 'Department';

  @override
  String get curriculumTitle => 'Curriculum gaps';

  @override
  String get curriculumIntro =>
      'For the department: how the course catalog lines up with what job postings ask for.';

  @override
  String postingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count job postings',
      one: '1 job posting',
    );
    return '$_temp0';
  }

  @override
  String curriculumSampleTitle(String postings) {
    return 'Indicative only: $postings';
  }

  @override
  String curriculumSampleBody(String postings, int min, int max) {
    return 'These gaps come from $postings, $min to $max per career. At that size, a skill one or two postings mention can appear or disappear with the next few. Treat each gap as a question worth looking into, not as grounds on its own for changing the curriculum.';
  }

  @override
  String get curriculumAllCareers => 'All careers';

  @override
  String curriculumCoverageFor(String scope) {
    return 'Coverage: $scope';
  }

  @override
  String curriculumCoverageLine(int taught, int demanded, String postings) {
    return '$taught of the $demanded skills that $postings ask for are taught by at least one course.';
  }

  @override
  String get curriculumCoverageCounting =>
      'Each skill counts once, however many postings ask for it.';

  @override
  String curriculumUncoveredTitle(int count) {
    return 'Asked for, not taught ($count)';
  }

  @override
  String get curriculumUncoveredNote =>
      'Skills the postings ask for that no course in the catalog teaches, most in demand first.';

  @override
  String get curriculumNoneUncovered =>
      'Every skill the postings ask for is taught by at least one course.';

  @override
  String curriculumAskedIn(String careers) {
    return 'Asked for in: $careers';
  }

  @override
  String get curriculumByCareerTitle => 'Coverage by career';

  @override
  String curriculumCareerLine(int taught, int demanded, String postings) {
    return '$taught of $demanded demanded skills taught · $postings';
  }

  @override
  String curriculumNotAskedTitle(int count) {
    return 'Taught, not asked for ($count)';
  }

  @override
  String get curriculumNotAskedNote =>
      'Skills the catalog teaches that no posting in this view asks for. Not asked for is not the same as not needed: a sample this small misses a lot.';

  @override
  String get curriculumNoneNotAsked =>
      'Every skill the catalog teaches is asked for by at least one posting.';

  @override
  String curriculumTaughtIn(String courses) {
    return 'Taught in: $courses';
  }

  @override
  String curriculumThreshold(String k) {
    return 'Counted: skills named in at least $k of a career\'s postings.';
  }

  @override
  String curriculumThresholdLeftOut(int count) {
    return '$count named by fewer are left out and listed below.';
  }

  @override
  String curriculumBelowTitle(int count) {
    return 'Named, but below the threshold ($count)';
  }

  @override
  String curriculumBelowNote(String k) {
    return 'Each is named by at least one posting, but by fewer than $k of any career\'s postings, so it counts as neither demanded nor not asked for. The threshold is a share of postings, so the number of postings it takes grows with the sample.';
  }

  @override
  String get curriculumNotTaught => 'Taught in no course';

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

  @override
  String get careerDatabaseAdministrator => 'Database Administrator';

  @override
  String get careerCybersecurityAnalyst => 'Cybersecurity Analyst';

  @override
  String get careerItProjectManager => 'IT Project Manager';
}
