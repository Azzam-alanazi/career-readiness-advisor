import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';

/// A screen: an iOS navigation bar over scrolling content, with an optional
/// bar of actions pinned to the bottom.
///
/// A tab's first screen takes the collapsing large title ([large]); a screen
/// pushed on top of it takes the standard bar, with the back chevron.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.slivers,
    this.large = false,
    this.trailing,
    this.bottomBar,
  });

  final String title;
  final List<Widget> slivers;
  final bool large;
  final Widget? trailing;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final content = SliverMainAxisGroup(slivers: slivers);
    final Widget scroll = large
        ? CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(largeTitle: Text(title), trailing: trailing),
              SliverSafeArea(top: false, bottom: bottomBar == null, sliver: content),
            ],
          )
        : CustomScrollView(
            slivers: [SliverSafeArea(bottom: bottomBar == null, sliver: content)],
          );
    return CupertinoPageScaffold(
      navigationBar: large
          ? null
          : CupertinoNavigationBar(middle: Text(title), trailing: trailing),
      child: bottomBar == null
          ? scroll
          : Column(children: [Expanded(child: scroll), bottomBar!]),
    );
  }
}

/// A screen's content as one padded column of widgets.
class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(kScreenInset, 8, kScreenInset, 32),
        sliver: SliverList.list(children: children),
      );
}

/// Actions pinned below the content, on the bar material, above the home
/// indicator.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).barBackgroundColor,
          border: Border(
            top: BorderSide(
              color: AppColors.separator.resolveFrom(context),
              width: 0, // a hairline
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(kScreenInset, 10, kScreenInset, 10),
            child: child,
          ),
        ),
      );
}
