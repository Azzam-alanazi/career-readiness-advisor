// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الجاهزية المهنية';

  @override
  String get switchLanguage => 'English';

  @override
  String get onboardingTitle => 'ملفك الشخصي';

  @override
  String get onboardingIntro =>
      'أخبرنا بما درسته وأين تريد أن تعمل، وسنقارنه بما يطلبه أصحاب العمل.';

  @override
  String get majorLabel => 'التخصص';

  @override
  String get majorHint => 'مثل: نظم المعلومات';

  @override
  String get careerLabel => 'المهن المستهدفة';

  @override
  String get careersHint => 'اختر مهنة واحدة، أو حتى ثلاث مهن للمقارنة بينها.';

  @override
  String get careerRequired => 'اختر مهنة للمتابعة.';

  @override
  String coursesLabel(int count) {
    return 'المقررات المكتملة ($count مختارة)';
  }

  @override
  String get coursesCatalogNote =>
      'مدرجة كما وردت في دليل المقررات (بالإنجليزية).';

  @override
  String get coursesSearchHint => 'ابحث برمز المقرر أو اسمه';

  @override
  String get coursesClearSearch => 'مسح البحث';

  @override
  String coursesSelectShown(int count) {
    return 'اختر كل المعروض ($count)';
  }

  @override
  String get coursesNoMatch => 'لا يوجد مقرر يطابق بحثك.';

  @override
  String get coursesQuickSelect => 'اختيار سريع:';

  @override
  String coursesUpToLevel(int level) {
    return 'كل المستوى $level وما دونه';
  }

  @override
  String get trackCollege => 'متطلبات الكلية';

  @override
  String get trackCore => 'المقررات الأساسية للتخصص';

  @override
  String get trackElectiveAnalytics => 'مقررات اختيارية: تحليلات الأعمال';

  @override
  String get trackElectiveEcommerce => 'مقررات اختيارية: التجارة الإلكترونية';

  @override
  String get trackOther => 'مقررات أخرى';

  @override
  String trackSelected(int selected, int total) {
    return '$selected من $total مختارة';
  }

  @override
  String selectedCourses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقرر مختار',
      many: '$count مقررًا مختارًا',
      few: '$count مقررات مختارة',
      two: 'مقرران مختاران',
      one: 'مقرر واحد مختار',
      zero: 'لم تختر أي مقرر',
    );
    return '$_temp0';
  }

  @override
  String get coursesReview => 'مراجعة';

  @override
  String get coursesClear => 'مسح';

  @override
  String get coursesCleared => 'مُسح الاختيار.';

  @override
  String get undo => 'تراجع';

  @override
  String get coursesReviewTitle => 'المقررات المختارة';

  @override
  String get coursesClearAll => 'مسح الكل';

  @override
  String get coursesRemove => 'إزالة';

  @override
  String get coursesDone => 'تم';

  @override
  String get submit => 'اعرض جاهزيتي';

  @override
  String get submitFailed => 'تعذّر حفظ ملفك على هذا الجهاز. حاول مرة أخرى.';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get editProfileTitle => 'تعديل ملفك';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsProfile => 'الملف الشخصي';

  @override
  String settingsCourses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقرر مكتمل',
      many: '$count مقررًا مكتملًا',
      few: '$count مقررات مكتملة',
      two: 'مقرران مكتملان',
      one: 'مقرر مكتمل واحد',
      zero: 'لا مقررات مكتملة',
    );
    return '$_temp0';
  }

  @override
  String settingsSkills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهارة ذكرتها بنفسك',
      many: '$count مهارة ذكرتها بنفسك',
      few: '$count مهارات ذكرتها بنفسك',
      two: 'مهارتان ذكرتهما بنفسك',
      one: 'مهارة واحدة ذكرتها بنفسك',
      zero: 'لا مهارات ذكرتها بنفسك',
    );
    return '$_temp0';
  }

  @override
  String get settingsEditProfile => 'تعديل الملف';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsStorage => 'محفوظ على هذا الجهاز';

  @override
  String get settingsLocalOnly =>
      'يُحفظ ملفك على هذا الجهاز فقط. لا يُخزَّن شيء عنك على أي خادم، ولا يوجد حساب، لذا فإن حذف التطبيق يحذف ملفك أيضًا.';

  @override
  String get settingsDelete => 'حذف الملف';

  @override
  String get settingsDeleteTitle => 'حذف ملفك؟';

  @override
  String get settingsDeleteBody =>
      'سيُحذف من هذا الجهاز ما اخترته من مهن ومقررات ومهارات، وستبدأ من جديد.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get nextToSkills => 'التالي: مهارات أخرى';

  @override
  String get skillsTitle => 'مهارات أخرى';

  @override
  String get skillsIntro =>
      'اختياري. حدّد أي مهارات اكتسبتها خارج مقرراتك: بالتعلم الذاتي أو الشهادات أو الخبرة العملية.';

  @override
  String get skillsUnverified =>
      'هذه مهارات تذكرها بنفسك ولا يُتحقق منها، وتظهر في جاهزيتك منفصلة عن مقرراتك.';

  @override
  String get skillsSearchHint => 'ابحث عن مهارة';

  @override
  String skillsSelected(int count) {
    return 'المختارة: $count';
  }

  @override
  String get skillFromCourses => 'من مقرراتك';

  @override
  String get skillsNoMatch => 'لا توجد مهارة تطابق بحثك.';

  @override
  String coveredFromCoursesTitle(int count) {
    return 'من مقرراتك ($count)';
  }

  @override
  String coveredSelfReportedTitle(int count) {
    return 'ذكرتها بنفسك ($count)';
  }

  @override
  String readinessFromCoursesOnly(String percent) {
    return 'من مقرراتك وحدها: $percent';
  }

  @override
  String get categoryBusinessAnalysis => 'تحليل الأعمال والتنفيذ';

  @override
  String get categoryData => 'البيانات والتحليلات';

  @override
  String get categorySoftwareDevelopment => 'تطوير البرمجيات';

  @override
  String get categoryInfrastructure => 'البنية التحتية والسحابة والشبكات';

  @override
  String get categoryItSupport => 'الدعم الفني وإدارة الخدمات';

  @override
  String get categorySecurity => 'الأمن';

  @override
  String get categoryErp => 'أنظمة تخطيط موارد المؤسسات وعملياتها';

  @override
  String get categoryProfessional => 'المهارات المهنية';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get homeTopGaps => 'أبرز فجواتك';

  @override
  String get homeNoGaps => 'لا فجوات: تمتلك كل مهارة تطلبها هذه الإعلانات.';

  @override
  String get homeFullReadiness => 'الجاهزية الكاملة';

  @override
  String get homeFullReadinessHint =>
      'المهارات التي تمتلكها والتي تحتاجها، ومهنك جنبًا إلى جنب';

  @override
  String get homeSettingsHint => 'عدّل ملفك أو غيّر اللغة';

  @override
  String get readinessTitle => 'الجاهزية';

  @override
  String readinessFor(String career) {
    return 'الجاهزية لمهنة $career';
  }

  @override
  String get readinessExplained =>
      'نسبة المهارات المطلوبة التي تمتلكها، مرجّحة بعدد مرات طلب أصحاب العمل لكل منها.';

  @override
  String coveredTitle(int count) {
    return 'مهارات تمتلكها ($count)';
  }

  @override
  String get noneCovered =>
      'لا تمتلك أيًا من المهارات المطلوبة بعد، والقائمة أدناه توضح من أين تبدأ.';

  @override
  String missingTitle(int count) {
    return 'مهارات تحتاج إلى بنائها، الأكثر طلبًا أولًا ($count)';
  }

  @override
  String demandShare(String percent) {
    return 'في $percent من الإعلانات';
  }

  @override
  String get seeRecommendations => 'المقررات المقترحة';

  @override
  String get planTitle => 'خطط لمقرراتك';

  @override
  String get planIntro =>
      'حدّد المقررات التي تنوي أخذها. يحتسبها التوقع كأنها مكتملة، ويبقى سجلك كما هو.';

  @override
  String get planNow => 'الآن';

  @override
  String planWith(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إذا أخذت ما خططت له من مقررات ($count)',
      one: 'إذا أخذت المقرر الذي خططت له',
    );
    return '$_temp0';
  }

  @override
  String planPoints(int points) {
    return '+$points نقطة';
  }

  @override
  String get planNothingYet => 'حدّد مقررات أدناه لترى ما ستضيفه.';

  @override
  String planClosesCount(int closed, int missing) {
    return 'تسد خطتك $closed من أصل $missing فجوة.';
  }

  @override
  String get planCoursesTitle => 'مقررات يمكنك أخذها';

  @override
  String get planExplained =>
      'يعرض كل مقرر الفجوات التي يسدها لهذه المهنة، الأكثر طلبًا أولًا. والفجوة التي يسدها مقرران تُحتسب مرة واحدة.';

  @override
  String get planCompletedNote =>
      'المقررات المكتملة محتسبة أصلًا، لذا لا تظهر هنا.';

  @override
  String planCloses(String skills) {
    return 'يسد: $skills';
  }

  @override
  String get planClosesNone => 'لا يسد أيًا من فجواتك الحالية لهذه المهنة.';

  @override
  String planPlannedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقرر مخطط له',
      many: '$count مقررًا مخططًا له',
      few: '$count مقررات مخطط لها',
      two: 'مقرران مخطط لهما',
      one: 'مقرر واحد مخطط له',
      zero: 'لا مقررات مخطط لها',
    );
    return '$_temp0';
  }

  @override
  String get compareTitle => 'مهنك جنبًا إلى جنب';

  @override
  String compareCovered(int count) {
    return 'متوفرة: $count';
  }

  @override
  String compareMissing(int count) {
    return 'ناقصة: $count';
  }

  @override
  String compareFromCourses(String percent) {
    return 'من المقررات وحدها: $percent';
  }

  @override
  String get compareClosest => 'الأقرب';

  @override
  String get compareNote =>
      'اضغط على مهنة لعرض تفاصيلها أدناه. تستند كل نتيجة إلى الإعلانات القليلة المذكورة تحت اسمها، لذا فإن فارق بضع نقاط لا يعني فرقًا حقيقيًا.';

  @override
  String get recommendationsTitle => 'المقررات المقترحة';

  @override
  String recommendationsFor(String career) {
    return 'لمهنة $career';
  }

  @override
  String get suggestionTitle => 'اقتراحات، لا أحكام';

  @override
  String get suggestionBody =>
      'رُتّبت المقررات بحسب مقدار الطلب في سوق العمل الذي قد تساعدك على تغطيته. اعتبرها نقطة انطلاق للنقاش مع مرشدك الأكاديمي، لا قرارًا ولا ضمانًا.';

  @override
  String get couldHelpWith => 'قد يساعد في';

  @override
  String get noRecommendations =>
      'لا يوجد في دليل المقررات مقرر يغطي هذه الفجوات.';

  @override
  String get startOver => 'ابدأ من جديد';

  @override
  String universityCoursesTitle(int count) {
    return 'مقررات جامعية ($count)';
  }

  @override
  String get universityCoursesNote =>
      'من دليل مقررات جامعتك، وتُحتسب ضمن متطلبات التخرج.';

  @override
  String onlineCoursesTitle(int count) {
    return 'دورات عبر الإنترنت ($count)';
  }

  @override
  String get onlineCoursesNote =>
      'لمهارات لا يغطيها أي مقرر جامعي، ولا تُحتسب ضمن متطلبات التخرج.';

  @override
  String get countsTowardDegree => 'يُحتسب ضمن متطلبات التخرج';

  @override
  String get notTowardDegree => 'لا تُحتسب ضمن متطلبات التخرج';

  @override
  String get free => 'مجانية';

  @override
  String get openCourse => 'افتح الدورة';

  @override
  String get openCourseFailed => 'تعذّر فتح الرابط.';

  @override
  String get paid => 'مدفوعة';

  @override
  String get noOnlineCourses =>
      'لم تُدرج بعد دورات عبر الإنترنت للمهارات التي لا تغطيها مقررات جامعتك.';

  @override
  String uncoveredTitle(int count) {
    return 'لا يوجد مقرر مدرج بعد ($count)';
  }

  @override
  String get uncoveredBody =>
      'لا يغطي أي مقرر جامعي هذه المهارات، ولم تُدرج لها دورات عبر الإنترنت بعد.';

  @override
  String get qualityTitle => 'تقديرات، وليست نتائج موثّقة';

  @override
  String get qualityTitlePassed => 'حول هذه الأرقام';

  @override
  String qualityGateFailed(String f1, String floor) {
    return 'في اختبار التحقق، حصلت أداة مطابقة المهارات على قيمة F1 بلغت $f1، وهي أقل من $floor المطلوبة للنجاح. تعامل مع هذه الأرقام كتقديرات تقريبية.';
  }

  @override
  String get qualityCoursesUnchecked =>
      'لم يُتحقق من المهارات التي يغطيها كل مقرر مقارنةً بمقررات موسومة يدويًا، لذا قد يُحتسب بعض المقررات بأقل مما يستحق.';

  @override
  String get qualityEnglishSource =>
      'يعتمد الطلب في السوق على إعلانات وظائف باللغة الإنجليزية، وتُعرض أسماء المهارات باللغة التي اخترتها.';

  @override
  String get errorUnreachable =>
      'تعذّر الوصول إلى الخادم. هل الخادم الخلفي قيد التشغيل؟';

  @override
  String get errorServer => 'لم يتمكن الخادم من الإجابة عن هذا الطلب.';

  @override
  String get errorCareerGone =>
      'إحدى المهن في ملفك لم تعد ضمن إعلانات الوظائف. عدّل ملفك لاختيار مهنة أخرى.';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get navStudent => 'الطالب';

  @override
  String get navDepartment => 'القسم';

  @override
  String get curriculumTitle => 'فجوات المنهج';

  @override
  String get curriculumIntro =>
      'للقسم الأكاديمي: مدى توافق دليل المقررات مع ما تطلبه إعلانات الوظائف.';

  @override
  String postingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إعلان',
      many: '$count إعلانًا',
      few: '$count إعلانات',
      two: 'إعلانان',
      one: 'إعلان واحد',
      zero: 'لا إعلانات',
    );
    return '$_temp0';
  }

  @override
  String curriculumSampleTitle(String postings) {
    return 'مؤشرات أولية فقط: $postings';
  }

  @override
  String curriculumSampleBody(String postings, int min, int max) {
    return 'تستند هذه الفجوات إلى $postings، بين $min و$max لكل مهنة. وبهذا الحجم قد تظهر مهارة يذكرها إعلان أو إعلانان أو تختفي مع الإعلانات القليلة التالية. تعامل مع كل فجوة كسؤال يستحق البحث، لا كسبب كافٍ وحده لتغيير المنهج.';
  }

  @override
  String get curriculumAllCareers => 'جميع المهن';

  @override
  String curriculumCoverageFor(String scope) {
    return 'التغطية: $scope';
  }

  @override
  String curriculumCoverageLine(int taught, int demanded, String postings) {
    return '$taught من أصل $demanded مهارة تطلبها $postings يدرّسها مقرر واحد على الأقل.';
  }

  @override
  String get curriculumCoverageCounting =>
      'تُحتسب كل مهارة مرة واحدة مهما كان عدد الإعلانات التي تطلبها.';

  @override
  String curriculumUncoveredTitle(int count) {
    return 'مطلوبة ولا يدرّسها أي مقرر ($count)';
  }

  @override
  String get curriculumUncoveredNote =>
      'مهارات تطلبها الإعلانات ولا يدرّسها أي مقرر في الدليل، الأكثر طلبًا أولًا.';

  @override
  String get curriculumNoneUncovered =>
      'كل مهارة تطلبها الإعلانات يدرّسها مقرر واحد على الأقل.';

  @override
  String curriculumAskedIn(String careers) {
    return 'مطلوبة في: $careers';
  }

  @override
  String get curriculumByCareerTitle => 'التغطية حسب المهنة';

  @override
  String curriculumCareerLine(int taught, int demanded, String postings) {
    return '$taught من $demanded مهارة مطلوبة تُدرَّس · $postings';
  }

  @override
  String curriculumNotAskedTitle(int count) {
    return 'يدرّسها المنهج ولا تطلبها الإعلانات ($count)';
  }

  @override
  String get curriculumNotAskedNote =>
      'مهارات يدرّسها الدليل ولا يطلبها أي إعلان في هذا العرض. وعدم طلبها لا يعني عدم الحاجة إليها، فعيّنة بهذا الحجم تغفل الكثير.';

  @override
  String get curriculumNoneNotAsked =>
      'كل مهارة يدرّسها الدليل يطلبها إعلان واحد على الأقل.';

  @override
  String curriculumTaughtIn(String courses) {
    return 'تُدرَّس في: $courses';
  }

  @override
  String curriculumThreshold(String k) {
    return 'تُحتسب المهارة إذا ذكرها ما لا يقل عن $k من إعلانات المهنة.';
  }

  @override
  String curriculumThresholdLeftOut(int count) {
    return 'المستبعدة لأن إعلانات أقل ذكرتها: $count، وهي مدرجة أدناه.';
  }

  @override
  String curriculumBelowTitle(int count) {
    return 'مذكورة لكن دون الحد ($count)';
  }

  @override
  String curriculumBelowNote(String k) {
    return 'ذكر كلًّا منها إعلان واحد على الأقل، لكن أقل من $k من إعلانات أي مهنة، فلا تُحتسب مطلوبة ولا غير مطلوبة. والحد نسبة من الإعلانات، فيرتفع عدد الإعلانات الذي يتطلبه كلما كبرت العيّنة.';
  }

  @override
  String get curriculumNotTaught => 'لا يدرّسها أي مقرر';

  @override
  String get careerBusinessAnalyst => 'محلل أعمال';

  @override
  String get careerDataAnalyst => 'محلل بيانات';

  @override
  String get careerErpConsultant => 'مستشار أنظمة تخطيط موارد المؤسسات';

  @override
  String get careerItSupportSpecialist => 'أخصائي دعم تقنية المعلومات';

  @override
  String get careerSoftwareDeveloper => 'مطور برمجيات';

  @override
  String get careerDatabaseAdministrator => 'مسؤول قواعد البيانات';

  @override
  String get careerCybersecurityAnalyst => 'محلل الأمن السيبراني';

  @override
  String get careerItProjectManager => 'مدير مشاريع تقنية المعلومات';
}
