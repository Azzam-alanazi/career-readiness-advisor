import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';

/// A section's title, set prominent as in Health and Fitness, in sentence case.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 4, top: 28, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // A heading to screen readers too, so VoiceOver's rotor can jump
            // between sections.
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: AppType.of(context).title3),
              ),
            ),
            ?trailing,
          ],
        ),
      );
}
