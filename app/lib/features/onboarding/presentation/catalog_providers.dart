import 'package:career_readiness/features/onboarding/data/catalog_repository.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final careersProvider = FutureProvider<List<Career>>(
  (ref) => ref.watch(catalogRepositoryProvider).careers(),
);

final coursesProvider = FutureProvider<List<Course>>(
  (ref) => ref.watch(catalogRepositoryProvider).courses(),
);
