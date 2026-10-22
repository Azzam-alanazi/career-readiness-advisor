import 'package:career_readiness/features/curriculum/presentation/curriculum_screen.dart';
import 'package:career_readiness/features/home/presentation/dashboard_screen.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_screen.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The student tab's first screen: onboarding until a profile is saved on this
/// device, and the home dashboard from then on. Onboarding never runs again
/// while a profile is saved.
class StudentRoot extends ConsumerWidget {
  const StudentRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(savedProfileProvider) == null
          ? const OnboardingScreen()
          : const DashboardScreen();
}

/// The app's two audiences side by side in the tab bar: the student flow and
/// the department's curriculum view.
///
/// Each tab keeps its own navigation stack, so opening the department view
/// never loses a half-finished onboarding, and the curriculum view is never a
/// step in the student flow. A tab is built the first time it is opened, so a
/// student who never opens the department view never waits on its request.
/// The system back gesture goes to the visible tab only.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.person_crop_circle),
            activeIcon: const Icon(CupertinoIcons.person_crop_circle_fill),
            label: l.navStudent,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.building_2_fill),
            label: l.navDepartment,
          ),
        ],
      ),
      tabBuilder: (context, i) => CupertinoTabView(
        builder: (_) => i == 0 ? const StudentRoot() : const CurriculumScreen(),
      ),
    );
  }
}
