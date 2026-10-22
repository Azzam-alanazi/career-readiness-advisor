import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';

/// The rounded card every group of content sits on, with the continuous
/// corners of iOS.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;

  /// Defaults to the grouped surface: white, or raised grey in dark mode.
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: ShapeDecoration(
          color: CupertinoDynamicColor.resolve(color ?? AppColors.surface, context),
          shape: const RoundedSuperellipseBorder(borderRadius: AppRadius.card),
        ),
        child: Padding(padding: padding, child: child),
      );
}

/// Rows on one card, divided by hairlines that start where the text does: the
/// grouped list of Settings.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.dividerIndent = 16,
  });

  final List<Widget> children;
  final Widget? header;

  /// A note under the card, in footnote type.
  final String? footer;

  /// Where the dividers start: 16 under plain rows, more under rows with an
  /// icon, so a divider never runs under the icon.
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final divider = Padding(
      padding: EdgeInsetsDirectional.only(start: dividerIndent),
      child: Container(height: 0.5, color: AppColors.separator.resolveFrom(context)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?header,
        if (children.isNotEmpty)
          ClipRSuperellipse(
            borderRadius: AppRadius.card,
            child: ColoredBox(
              color: AppColors.surface.resolveFrom(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, child) in children.indexed) ...[
                    if (i > 0) divider,
                    child,
                  ],
                ],
              ),
            ),
          ),
        if (footer != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
            child: Text(footer!, style: AppType.of(context).footnote),
          ),
      ],
    );
  }
}

/// A row in a [Section]: optional icon, a title that wraps rather than
/// truncating, an optional subtitle, and whatever stands at the end. Tappable
/// rows darken while pressed, as list rows do on iOS.
class ListRow extends StatefulWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.chevron = false,
    this.titleStyle,
    this.checked,
    this.detail,
  });

  final String title;
  final String? subtitle;

  /// More under the subtitle, when one line of footnote is not enough.
  final Widget? detail;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Shows a disclosure chevron: the row opens another screen.
  final bool chevron;
  final TextStyle? titleStyle;

  /// For a row that is chosen or not: said to VoiceOver with the row.
  final bool? checked;

  @override
  State<ListRow> createState() => _ListRowState();
}

class _ListRowState extends State<ListRow> {
  var _pressed = false;

  void _press(bool down) {
    if (widget.onTap != null && _pressed != down) setState(() => _pressed = down);
  }

  @override
  Widget build(BuildContext context) {
    final type = AppType.of(context);
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 11, 12, 11),
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: widget.titleStyle ?? type.body),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(widget.subtitle!, style: type.footnote),
                  ],
                  if (widget.detail != null) ...[
                    const SizedBox(height: 4),
                    widget.detail!,
                  ],
                ],
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
            if (widget.chevron) ...[
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 17,
                color: AppColors.tertiaryLabel.resolveFrom(context),
              ),
            ],
          ],
        ),
      ),
    );
    if (widget.onTap == null) {
      return MergeSemantics(child: Semantics(checked: widget.checked, child: row));
    }
    return MergeSemantics(
      child: Semantics(
        button: true,
        checked: widget.checked,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _press(true),
          onTapUp: (_) => _press(false),
          onTapCancel: () => _press(false),
          onTap: widget.onTap,
          child: ColoredBox(
            color: _pressed
                ? CupertinoColors.systemGrey4.resolveFrom(context)
                : const Color(0x00000000),
            child: row,
          ),
        ),
      ),
    );
  }
}

/// A row that is chosen or not, with the round check of iOS selection lists.
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.detail,
  });

  final String title;
  final String? subtitle;
  final Widget? detail;
  final bool value;

  /// Null when the row cannot be changed now; it is then dimmed.
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onChanged == null && !value ? 0.4 : 1,
        child: ListRow(
          title: title,
          subtitle: subtitle,
          detail: detail,
          leading: CheckCircle(value: value),
          onTap: onChanged,
          checked: value,
        ),
      );
}

/// The selection mark: an empty ring, or a filled teal disc with a check.
class CheckCircle extends StatelessWidget {
  const CheckCircle({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Icon(
          value ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
          size: 24,
          color: value
              ? CupertinoTheme.of(context).primaryColor
              : CupertinoColors.systemGrey3.resolveFrom(context),
        ),
      );
}

/// A white glyph on a coloured rounded square: the icon of a Settings row.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: CupertinoDynamicColor.resolve(color, context),
            shape: const RoundedSuperellipseBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
          ),
          child: SizedBox.square(
            dimension: 29,
            child: Icon(icon, size: 18, color: CupertinoColors.white),
          ),
        ),
      );
}

/// One of a few mutually exclusive choices, as a capsule: a career to show,
/// or every career.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = CupertinoTheme.of(context).primaryColor;
    final type = AppType.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: ShapeDecoration(
            color: selected ? tint : AppColors.surface.resolveFrom(context),
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            style: selected
                ? type.subheadlineEmphasis.copyWith(
                    color: CupertinoTheme.of(context).primaryContrastingColor,
                  )
                : type.subheadline,
          ),
        ),
      ),
    );
  }
}

/// A small action in a capsule, tinted: a shortcut beside the list it acts on.
class ActionPill extends StatelessWidget {
  const ActionPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final IconData? icon;

  /// Null when there is nothing for it to do; it then greys out.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled
        ? CupertinoTheme.of(context).primaryColor
        : AppColors.tertiaryLabel.resolveFrom(context);
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: ShapeDecoration(
            color: enabled
                ? color.withValues(alpha: 0.12)
                : AppColors.fill.resolveFrom(context),
            shape: const StadiumBorder(),
          ),
          // A plain Text beside the icon, so the label is found and read as
          // written.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppType.of(context).subheadlineEmphasis.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label in a small rounded box: a skill, a price, whether a course counts.
/// Text, not a control, so it wraps in a narrow column instead of overflowing.
class Tag extends StatelessWidget {
  const Tag({super.key, required this.label, this.icon, this.color});

  final String label;
  final IconData? icon;

  /// The meaning the tag carries; neutral grey when none.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final type = AppType.of(context);
    final accent = color == null ? null : CupertinoDynamicColor.resolve(color!, context);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: accent?.withValues(alpha: 0.14) ?? AppColors.fill.resolveFrom(context),
        shape: const RoundedSuperellipseBorder(borderRadius: AppRadius.tag),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: accent ?? AppColors.secondaryLabel.resolveFrom(context)),
              const SizedBox(width: 4),
            ],
            // The words stay in text colour; the icon and the wash carry the
            // meaning, so it never rests on colour alone.
            Flexible(
              child: Text(
                label,
                style: type.footnote.copyWith(color: AppColors.label.resolveFrom(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tags laid out in lines.
class TagWrap extends StatelessWidget {
  const TagWrap({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 6, runSpacing: 6, children: children);
}

/// Something the reader must take in before the figures: an icon, a title and
/// a few lines, on a wash of the colour that names its kind.
class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final type = AppType.of(context);
    final accent = CupertinoDynamicColor.resolve(color, context);
    return Panel(
      color: Color.alphaBlend(
        accent.withValues(alpha: 0.13),
        AppColors.surface.resolveFrom(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: type.headline),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(line, style: type.subheadline),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
