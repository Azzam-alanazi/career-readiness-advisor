import 'package:career_readiness/features/curriculum/data/curriculum_repository.dart';
import 'package:career_readiness/features/curriculum/domain/curriculum_gap.dart';
import 'package:career_readiness/features/gap/data/gap_repository.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/onboarding/data/catalog_repository.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/skill.dart';
import 'package:career_readiness/features/profile/data/profile_repository.dart';
import 'package:career_readiness/features/profile/domain/profile.dart';
import 'package:career_readiness/features/profile/domain/profile_draft.dart';
import 'package:career_readiness/features/recommendations/data/recommendations_repository.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';

// Payloads shaped exactly like the backend's -- snake_case keys, the failed
// gate, Arabic skill names -- so every fake also exercises fromJson.

const validationJson = <String, dynamic>{
  'gate_passed': false,
  'best_f1': 0.503,
  'gate_min_f1': 0.6,
  'course_mapping_validated': false,
  'note': 'Skill matching did not pass its validation gate.',
};

const careersJson = <Map<String, dynamic>>[
  {'name': 'Business Analyst', 'posting_count': 6},
  {'name': 'Data Analyst', 'posting_count': 5},
  {'name': 'Software Developer', 'posting_count': 5},
];

const coursesJson = <Map<String, dynamic>>[
  {
    'code': 'IS 230',
    'name': 'Database Management Systems',
    'skill_count': 2,
    'skills': ['SK16', 'SK17'],
  },
  {
    'code': 'IS 240',
    'name': 'Systems Analysis and Design',
    'skill_count': 1,
    'skills': ['SK02'],
  },
  {
    'code': 'IS 350',
    'name': 'Business Process Management',
    'skill_count': 1,
    'skills': ['SK04'],
  },
];

// Taxonomy order, as GET /skills returns it.
const skillsJson = <Map<String, dynamic>>[
  {
    'id': 'SK02',
    'en': 'Requirements elicitation',
    'ar': 'استخلاص المتطلبات من أصحاب المصلحة',
    'category': 'business_analysis',
  },
  {
    'id': 'SK04',
    'en': 'Business process modelling',
    'ar': 'نمذجة عمليات الأعمال',
    'category': 'business_analysis',
  },
  {
    'id': 'SK05',
    'en': 'Functional specifications',
    'ar': 'المواصفات الوظيفية',
    'category': 'business_analysis',
  },
  {'id': 'SK16', 'en': 'Database management', 'ar': 'إدارة قواعد البيانات', 'category': 'data'},
  {'id': 'SK17', 'en': 'SQL', 'ar': 'لغة الاستعلام الهيكلية SQL', 'category': 'data'},
  {
    'id': 'SK25',
    'en': 'Python programming',
    'ar': 'برمجة بايثون',
    'category': 'software_development',
  },
  {'id': 'SK85', 'en': 'Communication', 'ar': 'مهارات التواصل', 'category': 'professional'},
];

const _requirementsElicitation = <String, dynamic>{
  'id': 'SK02',
  'en': 'Requirements elicitation',
  'ar': 'استخلاص المتطلبات من أصحاب المصلحة',
  'category': 'business_analysis',
  'demand': 0.5,
  'demand_percent': 50,
};

const _communication = <String, dynamic>{
  'id': 'SK85',
  'en': 'Communication',
  'ar': 'مهارات التواصل',
  'category': 'professional',
  'demand': 0.1667,
  'demand_percent': 17,
};

// One skill from a course, one self-reported, so both halves of the readiness
// screen have something to show.
const gapJson = <String, dynamic>{
  'profile_id': 'p1',
  'career': 'Business Analyst',
  'readiness': 0.0968,
  'readiness_percent': 10,
  'readiness_from_courses': 0.0526,
  'readiness_from_courses_percent': 5,
  'covered': [
    {..._requirementsElicitation, 'source': 'courses'},
    {..._communication, 'source': 'self_reported'},
  ],
  'covered_from_courses': [_requirementsElicitation],
  'covered_self_reported': [_communication],
  'missing': [
    {
      'id': 'SK05',
      'en': 'Functional specifications',
      'ar': 'المواصفات الوظيفية',
      'category': 'business_analysis',
      'demand': 0.8333,
      'demand_percent': 83,
    },
    {
      'id': 'SK04',
      'en': 'Business process modelling',
      'ar': 'نمذجة عمليات الأعمال',
      'category': 'business_analysis',
      'demand': 0.5,
      'demand_percent': 50,
    },
    {
      'id': 'SK07',
      'en': 'Workshop facilitation',
      'ar': 'تيسير ورش العمل',
      'category': 'business_analysis',
      'demand': 0.3333,
      'demand_percent': 33,
    },
  ],
  'validation': validationJson,
};

const _sql = <String, dynamic>{
  'id': 'SK17',
  'en': 'SQL',
  'ar': 'لغة الاستعلام الهيكلية SQL',
  'category': 'data',
};
const _databases = <String, dynamic>{
  'id': 'SK16',
  'en': 'Database management',
  'ar': 'إدارة قواعد البيانات',
  'category': 'data',
};
const _modelling = <String, dynamic>{
  'id': 'SK15',
  'en': 'Data modelling',
  'ar': 'نمذجة البيانات',
  'category': 'data',
};
const _python = <String, dynamic>{
  'id': 'SK25',
  'en': 'Python programming',
  'ar': 'برمجة بايثون',
  'category': 'software_development',
};
const _javascript = <String, dynamic>{
  'id': 'SK29',
  'en': 'JavaScript',
  'ar': 'جافاسكريبت',
  'category': 'software_development',
};

// The same student read against the other two careers. Software Developer is
// the furthest along (35% against 10% and 20%), so a comparison has a closest
// career to mark, and every count differs: 2, 3 and 1 covered; 3, 2 and 4 missing.
const gapDeveloperJson = <String, dynamic>{
  'profile_id': 'p1',
  'career': 'Software Developer',
  'readiness': 0.35,
  'readiness_percent': 35,
  'readiness_from_courses': 0.35,
  'readiness_from_courses_percent': 35,
  'covered': [
    {..._sql, 'demand': 0.6, 'demand_percent': 60, 'source': 'courses'},
    {..._databases, 'demand': 0.4, 'demand_percent': 40, 'source': 'courses'},
    {..._modelling, 'demand': 0.2, 'demand_percent': 20, 'source': 'courses'},
  ],
  'covered_from_courses': [
    {..._sql, 'demand': 0.6, 'demand_percent': 60},
    {..._databases, 'demand': 0.4, 'demand_percent': 40},
    {..._modelling, 'demand': 0.2, 'demand_percent': 20},
  ],
  'covered_self_reported': <dynamic>[],
  'missing': [
    {..._python, 'demand': 0.8, 'demand_percent': 80},
    {..._javascript, 'demand': 0.4, 'demand_percent': 40},
  ],
  'validation': validationJson,
};

const gapDataJson = <String, dynamic>{
  'profile_id': 'p1',
  'career': 'Data Analyst',
  'readiness': 0.2,
  'readiness_percent': 20,
  'readiness_from_courses': 0.2,
  'readiness_from_courses_percent': 20,
  'covered': [
    {..._databases, 'demand': 0.4, 'demand_percent': 40, 'source': 'courses'},
  ],
  'covered_from_courses': [
    {..._databases, 'demand': 0.4, 'demand_percent': 40},
  ],
  'covered_self_reported': <dynamic>[],
  'missing': [
    {..._python, 'demand': 0.6, 'demand_percent': 60},
    {..._sql, 'demand': 0.6, 'demand_percent': 60},
    {..._modelling, 'demand': 0.4, 'demand_percent': 40},
    {..._javascript, 'demand': 0.2, 'demand_percent': 20},
  ],
  'validation': validationJson,
};

// One of each: a catalog course for the skill the university teaches, an online
// course for one it does not, and a skill with neither. The online course is a
// placeholder, not a real listing.
const recsJson = <String, dynamic>{
  'profile_id': 'p1',
  'career': 'Business Analyst',
  'recommendations': [
    {
      'source': 'university',
      'code': 'IS 350',
      'name': 'Business Process Management',
      'value': 0.5,
      'closes': [
        {
          'id': 'SK04',
          'en': 'Business process modelling',
          'ar': 'نمذجة عمليات الأعمال',
          'demand_percent': 50,
        },
      ],
    },
    {
      'source': 'online',
      'provider': 'Example Academy',
      'title': 'Writing functional specifications',
      'url': 'https://example.com/functional-specs',
      'is_free': true,
      'value': 0.8333,
      'closes': [
        {
          'id': 'SK05',
          'en': 'Functional specifications',
          'ar': 'المواصفات الوظيفية',
          'demand_percent': 83,
        },
      ],
    },
  ],
  'uncovered': [
    {
      'id': 'SK07',
      'en': 'Workshop facilitation',
      'ar': 'تيسير ورش العمل',
      'demand_percent': 33,
    },
  ],
  'validation': validationJson,
};

// The department view over the two careers above: 11 postings, 6 and 5.
// Business Analyst asks for SK02, SK04, SK05, SK07 and the catalog teaches the
// first two; Software Developer asks for SK17, SK25, SK29 and only SK17 is taught.
const _functionalSpecs = <String, dynamic>{
  'id': 'SK05',
  'en': 'Functional specifications',
  'ar': 'المواصفات الوظيفية',
  'category': 'business_analysis',
};

const _workshops = <String, dynamic>{
  'id': 'SK07',
  'en': 'Workshop facilitation',
  'ar': 'تيسير ورش العمل',
  'category': 'business_analysis',
};

const _networks = <String, dynamic>{
  'id': 'SK60',
  'en': 'Network administration',
  'ar': 'إدارة الشبكات',
  'category': 'infrastructure',
  'courses': ['CIT 201', 'CIT 202'],
};

const _perCareerJson = <Map<String, dynamic>>[
  {
    'career': 'Business Analyst',
    'posting_count': 6,
    'demanded': 4,
    'taught': 2,
    'coverage': 0.5,
    'coverage_percent': 50,
  },
  {
    'career': 'Software Developer',
    'posting_count': 5,
    'demanded': 3,
    'taught': 1,
    'coverage': 0.3333,
    'coverage_percent': 33,
  },
];

const curriculumAllJson = <String, dynamic>{
  'career': null,
  'posting_count': 11,
  'min_demand': 0.15,
  'demanded': 7,
  'taught': 3,
  'coverage': 0.4286,
  'coverage_percent': 43,
  'uncovered': [
    {
      ..._functionalSpecs,
      'postings': 5,
      'demand': 0.4545,
      'demand_percent': 45,
      'careers': ['Business Analyst'],
    },
    {
      'id': 'SK25',
      'en': 'Python programming',
      'ar': 'برمجة بايثون',
      'category': 'software_development',
      'postings': 4,
      'demand': 0.3636,
      'demand_percent': 36,
      'careers': ['Software Developer'],
    },
    {
      ..._workshops,
      'postings': 2,
      'demand': 0.1818,
      'demand_percent': 18,
      'careers': ['Business Analyst'],
    },
    {
      'id': 'SK29',
      'en': 'JavaScript',
      'ar': 'جافاسكريبت',
      'category': 'software_development',
      'postings': 1,
      'demand': 0.0909,
      'demand_percent': 9,
      'careers': ['Software Developer'],
    },
  ],
  'not_asked': [_networks],
  'per_career': _perCareerJson,
  'sample_note': 'Based on 11 job postings, 5 to 6 per career.',
  'validation': validationJson,
};

const curriculumAnalystJson = <String, dynamic>{
  'career': 'Business Analyst',
  'posting_count': 6,
  'min_demand': 0.15,
  'demanded': 4,
  'taught': 2,
  'coverage': 0.5,
  'coverage_percent': 50,
  'uncovered': [
    {
      ..._functionalSpecs,
      'postings': 5,
      'demand': 0.8333,
      'demand_percent': 83,
      'careers': ['Business Analyst'],
    },
    {
      ..._workshops,
      'postings': 2,
      'demand': 0.3333,
      'demand_percent': 33,
      'careers': ['Business Analyst'],
    },
  ],
  'not_asked': [
    {
      'id': 'SK17',
      'en': 'SQL',
      'ar': 'لغة الاستعلام الهيكلية SQL',
      'category': 'data',
      'courses': ['IS 230'],
    },
    _networks,
  ],
  'per_career': _perCareerJson,
  'sample_note': 'Based on 11 job postings, 5 to 6 per career.',
  'validation': validationJson,
};

class FakeCurriculumRepository implements CurriculumRepository {
  final requested = <String?>[];

  @override
  Future<CurriculumGap> fetch(String? career) async {
    requested.add(career);
    return CurriculumGap.fromJson(career == null ? curriculumAllJson : curriculumAnalystJson);
  }
}

class FakeCatalogRepository implements CatalogRepository {
  Object? failWith;

  @override
  Future<List<Career>> careers() async {
    if (failWith != null) throw failWith!;
    return careersJson.map(Career.fromJson).toList();
  }

  @override
  Future<List<Course>> courses() async => coursesJson.map(Course.fromJson).toList();

  @override
  Future<List<Skill>> skills() async => skillsJson.map(Skill.fromJson).toList();
}

class FakeProfileRepository implements ProfileRepository {
  ProfileDraft? lastDraft;
  Object? failWith;

  @override
  Future<Profile> create(ProfileDraft draft) async {
    lastDraft = draft;
    if (failWith != null) throw failWith!;
    return Profile(
      id: 'p1',
      career: draft.career,
      otherCareers: draft.otherCareers,
      major: draft.major,
      completedCourses: draft.completedCourses,
      selfReportedSkills: draft.selfReportedSkills,
      createdAt: '2026-09-10T00:00:00+00:00',
    );
  }
}

class FakeGapRepository implements GapRepository {
  final requested = <String>[];
  final careers = <String?>[];

  @override
  Future<GapReport> fetch(String profileId, {String? career}) async {
    requested.add(profileId);
    careers.add(career);
    return GapReport.fromJson(switch (career) {
      'Software Developer' => gapDeveloperJson,
      'Data Analyst' => gapDataJson,
      _ => gapJson,
    });
  }
}

class FakeRecommendationsRepository implements RecommendationsRepository {
  final careers = <String?>[];

  @override
  Future<RecommendationsReport> fetch(String profileId, {String? career}) async {
    careers.add(career);
    return RecommendationsReport.fromJson(recsJson);
  }
}
