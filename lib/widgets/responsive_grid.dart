import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kao_app/utils/responsive_utils.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final double runSpacing;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;
  final Widget? emptyWidget;
  final int? forceColumnCount;
  final bool addAutomaticKeepAlives;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.padding,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
    this.emptyWidget,
    this.forceColumnCount,
    this.addAutomaticKeepAlives = true,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on screen width
        int columnCount = forceColumnCount ?? _getColumnCount(context, constraints.maxWidth);
        
        return MasonryGridView.count(
          padding: padding,
          crossAxisCount: columnCount,
          mainAxisSpacing: runSpacing,
          crossAxisSpacing: spacing,
          itemCount: children.length,
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          controller: controller,
          shrinkWrap: shrinkWrap,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getColumnCount(BuildContext context, double width) {
    if (ResponsiveUtils.isDesktop(context)) {
      // Desktop layout
      if (width > 1600) return 4;
      if (width > 1200) return 3;
      return 2;
    } else if (ResponsiveUtils.isTablet(context)) {
      // Tablet layout
      return width > 900 ? 3 : 2;
    } else {
      // Mobile layout
      return width > 600 ? 2 : 1;
    }
  }
}

class ResponsiveGridItem extends StatelessWidget {
  final Widget child;
  final int columnSpan;
  final double aspectRatio;

  const ResponsiveGridItem({
    super.key,
    required this.child,
    this.columnSpan = 1,
    this.aspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: child,
    );
  }
}
