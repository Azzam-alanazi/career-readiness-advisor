import 'dart:async';

import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';

OverlayEntry? _shown;

/// A short message in a capsule that drops in from the top of the screen and
/// leaves on its own after a few seconds, with an optional action such as
/// "Undo". One at a time: a new message replaces the one on screen.
void showToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  hideToast();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      onGone: () {
        if (identical(_shown, entry)) hideToast();
      },
    ),
  );
  _shown = entry;
  overlay.insert(entry);
}

/// Takes the message on screen away at once.
void hideToast() {
  final entry = _shown;
  _shown = null;
  // An entry whose overlay has already gone (the app was closed under it) is
  // left alone: it can no longer be removed, so it cannot be disposed either.
  if (entry == null || !entry.mounted) return;
  entry
    ..remove()
    ..dispose();
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.onGone,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onGone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Long enough to read and reach the action.
    _timer = Timer(const Duration(seconds: 4), _leave);
  }

  Future<void> _leave() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onGone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = AppType.of(context);
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    final top = MediaQuery.paddingOf(context).top + 8;
    return Positioned(
      top: top,
      left: kScreenInset,
      right: kScreenInset,
      child: FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(curve),
          child: Center(
            child: Semantics(
              liveRegion: true,
              container: true,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: CupertinoColors.label.resolveFrom(context).withValues(alpha: 0.88),
                  shape: const StadiumBorder(),
                  shadows: const [
                    BoxShadow(color: Color(0x26000000), blurRadius: 18, offset: Offset(0, 6)),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    20,
                    widget.actionLabel == null ? 12 : 4,
                    widget.actionLabel == null ? 20 : 6,
                    widget.actionLabel == null ? 12 : 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.message,
                          style: type.subheadlineEmphasis.copyWith(
                            color: CupertinoColors.systemBackground.resolveFrom(context),
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null)
                        CupertinoButton(
                          sizeStyle: CupertinoButtonSize.small,
                          onPressed: () {
                            widget.onAction?.call();
                            _leave();
                          },
                          child: Text(
                            widget.actionLabel!,
                            style: type.subheadlineEmphasis.copyWith(
                              color: CupertinoDynamicColor.resolve(
                                // The dark-mode teal reads on the dark capsule,
                                // and the light one on the light capsule.
                                CupertinoDynamicColor.withBrightness(
                                  color: AppColors.tint.darkColor,
                                  darkColor: AppColors.tint.color,
                                ),
                                context,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
