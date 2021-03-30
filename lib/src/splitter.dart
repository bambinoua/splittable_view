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
    var splitterSize = direction.isHorizonal
        ? Size.fromHeight(splitterTheme.space!)
        : Size.fromWidth(splitterTheme.space!);
    var iconSize = IconTheme.of(context).size;
    return Container(
      alignment: Alignment.center,
      height: splitterSize.height,
      width: splitterSize.width,
      child: Stack(
        children: [
          // Horizontal divider
          if (direction.isHorizonal)
            Divider(
              color: splitterTheme.color,
              thickness: splitterTheme.thickness,
              indent: splitterTheme.indent,
              endIndent: splitterTheme.endIndent,
            ),
          // Vartical divider
          if (direction.isVertical)
            VerticalDivider(
              color: splitterTheme.color,
              thickness: splitterTheme.thickness,
              indent: splitterTheme.indent,
              endIndent: splitterTheme.endIndent,
            ),
          // Icon
          if (splitterTheme.enableIcon!)
            () {
              var rect = direction.isHorizonal
                  ? Rect.fromLTRB(0.0,
                      (iconSize! - splitterTheme.space!) / -2 - 0.5, 0.0, 0.0)
                  : Rect.zero;
              Widget icon = Icon(
                Icons.drag_handle,
                color: splitterTheme.color,
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
