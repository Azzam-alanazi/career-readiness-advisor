import 'package:career_readiness/features/gap/data/gap_repository.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A profile read against one of its careers.
typedef GapKey = ({String profileId, String career});

final gapReportProvider = FutureProvider.autoDispose.family<GapReport, GapKey>(
  (ref, key) => ref.watch(gapRepositoryProvider).fetch(key.profileId, career: key.career),
);
