import 'package:career_readiness/features/gap/data/gap_repository.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gapReportProvider = FutureProvider.autoDispose.family<GapReport, String>(
  (ref, profileId) => ref.watch(gapRepositoryProvider).fetch(profileId),
);
