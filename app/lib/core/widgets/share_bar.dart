import 'package:flutter/material.dart';

/// A share from 0 to 1, drawn as a bar.
///
/// Every bar in the app stands beside the figure it draws, and that figure is
/// what a screen reader reads. The bar would only say the number again with no
/// name attached, so it stays silent.
class ShareBar extends StatelessWidget {
  const ShareBar(this.value, {super.key, this.minHeight});

  final double value;
  final double? minHeight;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0).toDouble(),
          minHeight: minHeight,
        ),
      );
}
