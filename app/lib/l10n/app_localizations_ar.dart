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
  String get careerLabel => 'المهنة المستهدفة';

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
  String get submit => 'اعرض جاهزيتي';

  @override
  String get submitFailed => 'تعذّر حفظ ملفك. تحقق من الاتصال وحاول مرة أخرى.';

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
  String get recommendationsTitle => 'المقررات المقترحة';

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
  String get retry => 'حاول مرة أخرى';

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
}
