// Copyright 2021 BambinoUA. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:splittable_view/src/theme.dart';
import 'package:splittable_view/src/extensions.dart';

/// Widget which splits two or more widgets in [SplittableView].
class Splitter extends StatelessWidget {
  /// Creates a splitter widget.
  const Splitter({
    Key? key,
    required this.direction,
  }) : super(key: key);

  /// The axis along which the split executes.
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    var splitterTheme = SplitterTheme.of(context);
    var preferredSize = direction.isHorizonal
        ? Size.fromHeight(splitterTheme.space!)
        : Size.fromWidth(splitterTheme.space!);
    var effectiveColor = splitterTheme.color ??
        DividerTheme.of(context).color ??
        Theme.of(context).dividerColor;
    return Container(
      alignment: Alignment.center,
      height: preferredSize.height,
      width: preferredSize.width,
      child: Stack(
        children: [
          // Horizontal divider
          if (direction.isHorizonal)
            Divider(
              color: effectiveColor,
              thickness: splitterTheme.thickness,
              indent: splitterTheme.indent,
              endIndent: splitterTheme.endIndent,
            ),
          // Vartical divider
          if (direction.isVertical)
            VerticalDivider(
              color: effectiveColor,
              thickness: splitterTheme.thickness,
              indent: splitterTheme.indent,
              endIndent: splitterTheme.endIndent,
            ),
          // Icon
          if (splitterTheme.enableIcon!)
            () {
              var rect = direction.isHorizonal
                  ? const Rect.fromLTRB(0.0, -4.0, 0.0, 0.0)
                  : const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
              Widget icon = Icon(
                Icons.drag_handle,
                color: effectiveColor,
              );
              if (direction.isVertical) {
                icon = RotationTransition(
                  turns: const AlwaysStoppedAnimation(0.25),
                  child: icon,
                );
              }
              return Positioned.fill(
                left: rect.left,
                top: rect.top,
                right: rect.right,
                bottom: rect.bottom,
                child: Container(
                  child: icon,
                ),
              );
            }(),
        ],
      ),
    );
  }
}
