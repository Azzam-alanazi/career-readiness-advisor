import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';

/// A share from 0 to 1, drawn as a capsule meter: the fill in [color], the
/// track a pale step of the same colour, so the whole bar reads as one scale.
///
/// Every bar in the app stands beside the figure it draws, and that figure is
/// what a screen reader reads. The bar would only say the number again with no
/// name attached, so it stays silent.
class ShareBar extends StatelessWidget {
  const ShareBar(this.value, {super.key, this.minHeight, this.color = AppColors.tint});

  final double value;
  final double? minHeight;

  /// Teal for what is held or taught; indigo for how often the market asks.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fill = CupertinoDynamicColor.resolve(color, context);
    final height = minHeight ?? 6;
    final share = value.clamp(0.0, 1.0).toDouble();
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          child: ColoredBox(
            color: fill.withValues(alpha: 0.16),
            child: FractionallySizedBox(
              // Fills from the reading start: from the right in Arabic.
              alignment: AlignmentDirectional.centerStart,
              widthFactor: share,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
