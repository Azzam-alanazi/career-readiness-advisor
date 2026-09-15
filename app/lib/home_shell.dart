import 'package:career_readiness/features/curriculum/presentation/curriculum_screen.dart';
import 'package:career_readiness/features/gap/presentation/readiness_screen.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_screen.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The student tab's first screen: onboarding until a profile is saved on this
/// device, and the profile's readiness from then on.
class StudentRoot extends ConsumerWidget {
  const StudentRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(savedProfileProvider) == null
          ? const OnboardingScreen()
          : const ReadinessScreen();
}

/// The app's two audiences side by side: the student flow and the department's
/// curriculum view. Each tab keeps its own navigation stack, so opening the
/// department view never loses a half-finished onboarding, and the curriculum
/// view is never a step in the student flow.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _navigators = [GlobalKey<NavigatorState>(), GlobalKey<NavigatorState>()];
  var _index = 0;

  // A tab is built the first time it is opened, so a student who never opens
  // the department view never waits on its request.
  final _opened = {0};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _tab(0, const StudentRoot()),
          if (_opened.contains(1))
            _tab(1, const CurriculumScreen())
          else
            const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() {
          _index = i;
          _opened.add(i);
        }),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.navStudent,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_outlined),
            selectedIcon: const Icon(Icons.account_balance),
            label: l.navDepartment,
          ),
        ],
      ),
    );
  }

  Widget _tab(int i, Widget root) => NavigatorPopHandler(
        // Only the visible tab answers the system back gesture.
        enabled: _index == i,
        onPopWithResult: (_) => _navigators[i].currentState?.maybePop(),
        child: Navigator(
          key: _navigators[i],
          onGenerateRoute: (settings) =>
              MaterialPageRoute<void>(settings: settings, builder: (_) => root),
        ),
      );
}
