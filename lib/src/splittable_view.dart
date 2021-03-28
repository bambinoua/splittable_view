// Copyright 2021 BambinoUA. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:splittable_view/src/basic_types.dart';
import 'package:splittable_view/src/enums.dart';
import 'package:splittable_view/src/extensions.dart';

/// A widget that positions its children relative to the edges of its box.
///

/// A widget that displays its children in a vertical array which is splittable.
///
/// This class is useful if you want to place several children along the specied
/// axis and change their dimension (vertical or horizontal) using split widget.
class SplittableView extends StatefulWidget {
  /// Creates a splittable view of child widgets.
  const SplittableView({
    Key? key,
    required this.splitDirection,
    this.initialWeights = const <double>[],
    this.splitterBuilder,
    this.onSplittingEnd,
    this.onResetWeights,
    this.children = const <SplittableChild>[],
  })  : assert(children.length > 1,
            'SplittableView requires at least 2 children.'),
        super(key: key);

  /// The axis along which the split executes.
  final Axis splitDirection;

  /// The data that will be used for initial splitter(s) positions.
  final List<double> initialWeights;

  /// The `splitterBuilder` callback will be used for splitter customization.
  final WidgetBuilder? splitterBuilder;

  /// Callback when pointer that was previously in contact with the screen with
  /// a primary button and moving is no longer in contact with the screen.
  final ValueSetter<List<double>>? onSplittingEnd;

  /// Callback when split weights need to be reset. This can be required when
  /// new children added to [SplittableView] and weights data was already stored
  /// in persistent store.
  final VoidCallback? onResetWeights;

  /// The widgets below this widget in the tree.
  ///
  /// If this list is going to be mutated, it is usually wise to put a [Key] on
  /// each of the child widgets, so that the framework can match old
  /// configurations to new configurations and maintain the underlying render
  /// objects.
  final List<SplittableChild> children;

  @override
  _SplittableViewState createState() => _SplittableViewState();
}

class _SplittableViewState extends State<SplittableView> {
  /// Count of splittable flexes to calculate split weights.
  int flexCount = 0;

  /// List of split weights.
  List<double> weights = [];

  @override
  void initState() {
    super.initState();
    // Calculate the number of flex weights specified in children.
    flexCount = widget.children
        .map((child) => child.flex)
        .reduce((amount, flex) => amount + flex);

    // Get stored weights if they are.
    weights = widget.initialWeights;

    // Or initialize/reset weights.
    if (weights.isEmpty) {
      _initWeights();
    } else if (weights.length != widget.children.length) {
      _resetWeights();
    }
  }

  @override
  void didUpdateWidget(covariant SplittableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _resetWeights();
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var splitterCount = widget.children.length - 1;
    var splitterThickness = SplitterTheme.of(context).space!;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get the diffence between viewport height and available height.
        // This is useful when [MaterialApp] contains [AppBar].
        var minMargin = widget.splitDirection.isHorizonal
            ? mediaQuery.size.height - constraints.maxHeight
            : 0.0;
        // Effective dimension is a dimension without splitter thicknesses.
        var effectiveDimension = (widget.splitDirection.isHorizonal
                ? constraints.maxHeight
                : constraints.maxWidth) -
            splitterThickness * splitterCount;
        return Stack(
          children: [
            // Children
            ...widget.children.asMap().entries.map<Widget>((entry) {
              var index = entry.key;
              var top = _getFoldedWeight(index, IterableModifier.take) *
                      effectiveDimension +
                  splitterThickness * index;
              var bottom = _getFoldedWeight(index + 1, IterableModifier.skip) *
                      effectiveDimension +
                  splitterThickness * (splitterCount - index);
              var rect = widget.splitDirection.isHorizonal
                  ? Rect.fromLTRB(0.0, top, 0.0, bottom)
                  : Rect.fromLTRB(top, 0.0, bottom, 0.0);
              return Positioned.fill(
                left: rect.left,
                top: rect.top,
                right: rect.right,
                bottom: rect.bottom,
                child: entry.value.child,
              );
            }).toList(),
            // Splitters
            ...List.generate(
              splitterCount,
              (index) {
                var top = _getFoldedWeight(index + 1, IterableModifier.take) *
                        effectiveDimension +
                    splitterThickness * index;
                var bottom =
                    _getFoldedWeight(index + 1, IterableModifier.skip) *
                            effectiveDimension +
                        splitterThickness * (splitterCount - index - 1);
                var rect = widget.splitDirection.isHorizonal
                    ? Rect.fromLTRB(0.0, top, 0.0, bottom)
                    : Rect.fromLTRB(top, 0.0, bottom, 0.0);
                var cursor = widget.splitDirection.isHorizonal
                    ? SystemMouseCursors.resizeUpDown
                    : SystemMouseCursors.resizeLeftRight;
                return Positioned.fill(
                  left: rect.left,
                  top: rect.top,
                  right: rect.right,
                  bottom: rect.bottom,
                  child: MouseRegion(
                    cursor: cursor,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Splitter(direction: widget.splitDirection),
                      onVerticalDragEnd: widget.splitDirection.isHorizonal
                          ? (details) => _onDradEnd()
                          : null,
                      onVerticalDragUpdate: widget.splitDirection.isHorizonal
                          ? (details) {
                              setState(() {
                                var effectiveDy =
                                    details.globalPosition.dy - minMargin;
                                if (effectiveDy > 0 &&
                                    effectiveDy <= constraints.maxHeight) {
                                  var skippedWeight = _getFoldedWeight(
                                      index, IterableModifier.take);
                                  var effectiveWeight =
                                      effectiveDy / constraints.maxHeight -
                                          skippedWeight;
                                  var delta = weights[index] - effectiveWeight;
                                  weights[index] = effectiveWeight;
                                  weights[index + 1] =
                                      weights[index + 1] + delta;
                                }
                              });
                            }
                          : null,
                      onHorizontalDragEnd: widget.splitDirection.isVertical
                          ? (details) => _onDradEnd()
                          : null,
                      onHorizontalDragUpdate: widget.splitDirection.isVertical
                          ? (details) {
                              setState(() {
                                var effectiveDx = details.globalPosition.dx -
                                    context.size!.width -
                                    minMargin;
                                if (effectiveDx > 0 &&
                                    effectiveDx <= constraints.maxWidth) {
                                  var skippedWeight = _getFoldedWeight(
                                      index, IterableModifier.take);
                                  var effectiveWeight =
                                      effectiveDx / constraints.maxWidth -
                                          skippedWeight;
                                  var delta = weights[index] - effectiveWeight;
                                  weights[index] = effectiveWeight;
                                  weights[index + 1] =
                                      weights[index + 1] + delta;
                                }
                              });
                            }
                          : null,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Accumulates and returns folded weight value.
  double _getFoldedWeight(int count, IterableModifier modifier) =>
      (modifier == IterableModifier.take
              ? weights.take(count)
              : weights.skip(count))
          .fold<double>(0.0, (amount, ratio) => amount + ratio);

  /// Calculate the split weight for each child.
  void _initWeights() {
    weights = widget.children
        .map((child) => child.flex)
        .map((flex) => flex / flexCount)
        .toList();
  }

  /// Resets split weights.
  void _resetWeights() {
    if (widget.onResetWeights != null) {
      widget.onResetWeights!();
    }
    _initWeights();
  }

  /// Callback when user stopps splitting.
  void _onDradEnd() {
    if (widget.onSplittingEnd != null) {
      widget.onSplittingEnd!(weights);
    }
  }
}

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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'Slider (direction: ${describeEnum(direction)})';
}
