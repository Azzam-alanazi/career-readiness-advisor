import 'dart:math' as math;

import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';

/// Readiness as a ring, in the manner of the Activity rings: the share held
/// now in solid teal, and, with courses planned, the share the plan would add
/// in a paler teal running on from it.
///
/// It fills once when it first appears, the one motion in the app that is not
/// an answer to a tap; with Reduce Motion on it is simply drawn. The figures
/// beside it are what a screen reader reads, so the ring itself is silent.
class ReadinessRing extends StatelessWidget {
  const ReadinessRing({super.key, required this.now, this.planned, this.size = 76});

  final double now;

  /// Readiness with the planned courses counted; null when none are planned.
  final double? planned;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = CupertinoDynamicColor.resolve(AppColors.tint, context);
    final still = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: still ? 1 : 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(
            now: now.clamp(0.0, 1.0) * t,
            planned: (planned?.clamp(0.0, 1.0) ?? 0) * t,
            color: tint,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.now, required this.planned, required this.color});

  final double now;
  final double planned;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.15;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    Paint paint(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    const top = -math.pi / 2;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint(color.withValues(alpha: 0.16)));
    if (planned > now) {
      canvas.drawArc(rect, top, math.pi * 2 * planned, false, paint(color.withValues(alpha: 0.45)));
    }
    if (now > 0) {
      canvas.drawArc(rect, top, math.pi * 2 * now, false, paint(color));
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.now != now || old.planned != planned || old.color != color;
}
