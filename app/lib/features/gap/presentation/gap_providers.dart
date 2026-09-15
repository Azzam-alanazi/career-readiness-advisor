import 'package:career_readiness/features/gap/data/gap_repository.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A gap per query. Queries compare by value, so the same profile content
/// read against the same career is fetched once.
final gapReportProvider = FutureProvider.autoDispose.family<GapReport, GapQuery>(
  (ref, query) => ref.watch(gapRepositoryProvider).fetch(query),
);
