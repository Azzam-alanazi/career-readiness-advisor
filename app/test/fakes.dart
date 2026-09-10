import 'package:career_readiness/features/gap/data/gap_repository.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/onboarding/data/catalog_repository.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
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
  {'name': 'Software Developer', 'posting_count': 5},
];

const coursesJson = <Map<String, dynamic>>[
  {'code': 'IS 230', 'name': 'Database Management Systems', 'skill_count': 1},
  {'code': 'IS 240', 'name': 'Systems Analysis and Design', 'skill_count': 1},
  {'code': 'IS 350', 'name': 'Business Process Management', 'skill_count': 1},
];

const gapJson = <String, dynamic>{
  'profile_id': 'p1',
  'career': 'Business Analyst',
  'readiness': 0.0526,
  'readiness_percent': 5,
  'covered': [
    {
      'id': 'SK02',
      'en': 'Requirements elicitation',
      'ar': 'استخلاص المتطلبات من أصحاب المصلحة',
      'category': 'business_analysis',
      'demand': 0.5,
      'demand_percent': 50,
    },
  ],
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
  ],
  'validation': validationJson,
};

const recsJson = <String, dynamic>{
  'profile_id': 'p1',
  'career': 'Business Analyst',
  'recommendations': [
    {
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
  ],
  'validation': validationJson,
};

class FakeCatalogRepository implements CatalogRepository {
  Object? failWith;

  @override
  Future<List<Career>> careers() async {
    if (failWith != null) throw failWith!;
    return careersJson.map(Career.fromJson).toList();
  }

  @override
  Future<List<Course>> courses() async => coursesJson.map(Course.fromJson).toList();
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
      major: draft.major,
      completedCourses: draft.completedCourses,
      createdAt: '2026-09-10T00:00:00+00:00',
    );
  }
}

class FakeGapRepository implements GapRepository {
  final requested = <String>[];

  @override
  Future<GapReport> fetch(String profileId) async {
    requested.add(profileId);
    return GapReport.fromJson(gapJson);
  }
}

class FakeRecommendationsRepository implements RecommendationsRepository {
  @override
  Future<RecommendationsReport> fetch(String profileId, {int limit = 3}) async =>
      RecommendationsReport.fromJson(recsJson);
}
