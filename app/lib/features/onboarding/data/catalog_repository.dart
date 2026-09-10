import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogRepository {
  CatalogRepository(this._api);

  final ApiClient _api;

  Future<List<Career>> careers() async =>
      (await _api.get('/careers') as List).cast<Json>().map(Career.fromJson).toList();

  Future<List<Course>> courses() async =>
      (await _api.get('/courses') as List).cast<Json>().map(Course.fromJson).toList();
}

final catalogRepositoryProvider =
    Provider<CatalogRepository>((ref) => CatalogRepository(ref.watch(apiClientProvider)));
