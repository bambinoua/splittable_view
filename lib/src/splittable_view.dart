// Copyright 2021 BambinoUA. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:splittable_view/src/theme.dart';
import 'package:splittable_view/src/enums.dart';
import 'package:splittable_view/src/extensions.dart';
import 'package:splittable_view/src/splitter.dart';

/// A widget that displays its children in a space which is splittable horizontally.
///
/// ```dart
/// SplittableRow(
///   initialWeights: [0.5, 0.5],
///   onSplittingEnd: (weights) => _saveWeights(weight),
///   onResetWeights: () => _resetWeight(),
///   children: [
///     ListView(),
///     ListView(),
///   ],
/// ),
/// ```
///
class SplittableRow extends _SplittableView {
  const SplittableRow({
    Key? key,
    List<double>? initialWeights,
    WidgetBuilder? splitterBuilder,
    ValueSetter<List<double>>? onSplittingEnd,
    VoidCallback? onResetWeights,
    List<Widget> children = const <Widget>[],
  }) : super(
            key: key,
            splitDirection: Axis.vertical,
            initialWeights: initialWeights,
            splitterBuilder: splitterBuilder,
            onSplittingEnd: onSplittingEnd,
            onResetWeights: onResetWeights,
            children: children);
}

/// A widget that displays its children in a space which is splittable vertically.
///
/// ```dart
/// SplittableColumn(
///   initialWeights: [0.33, 0.33, 0.34],
///   onSplittingEnd: (weights) => _saveWeights(weight),
///   onResetWeights: () => _resetWeight(),
///   children: [
///     ListView(),
///     ListView(),
///     Container(),
///   ],
/// ),
/// ```
///
class SplittableColumn extends _SplittableView {
  const SplittableColumn({
    Key? key,
    List<double>? initialWeights,
    WidgetBuilder? splitterBuilder,
    ValueSetter<List<double>>? onSplittingEnd,
    VoidCallback? onResetWeights,
    List<Widget> children = const <Widget>[],
  }) : super(
            key: key,
            splitDirection: Axis.horizontal,
            initialWeights: initialWeights,
            splitterBuilder: splitterBuilder,
            onSplittingEnd: onSplittingEnd,
            onResetWeights: onResetWeights,
            children: children);
}

/// A widget that displays its children in a space which is splittable.
///
/// This class is useful if you want to place several children along the specied
/// axis and change their dimensions (vertical or horizontal) using split widget.
class _SplittableView extends StatefulWidget {
  /// Creates a splittable view of child widgets.
  const _SplittableView({
    Key? key,
    required this.splitDirection,
    this.initialWeights,
    this.splitterBuilder,
    this.onSplittingEnd,
    this.onResetWeights,
    this.children = const <Widget>[],
  })  : assert(children.length > 1,
            'SplittableView requires at least 2 children.'),
        super(key: key);

  /// The axis along which the split executes.
  final Axis splitDirection;

  /// The data that will be used for initial splitter(s) positions.
  final List<double>? initialWeights;

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
  final List<Widget> children;

  @override
  _SplittableViewState createState() => _SplittableViewState();
}

class _SplittableViewState extends State<_SplittableView> {
  /// List of children split weights.
  late List<double> weights;

  @override
  void initState() {
    super.initState();
    // Get stored weights if they are.
    weights = widget.initialWeights ?? <double>[];
    // Or initialize/reset weights.
    if (weights.isEmpty) {
      _initWeights();
    } else if (weights.length != widget.children.length) {
      _resetWeights();
    }
  }

  @override
  void didUpdateWidget(covariant _SplittableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _resetWeights();
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var splitterCount = widget.children.length - 1;
    var splitterSpace = SplitterTheme.of(context).space!;
    var splitterCursor = widget.splitDirection.isHorizonal
        ? SystemMouseCursors.resizeUpDown
        : SystemMouseCursors.resizeLeftRight;
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
            splitterSpace * splitterCount;
        return Stack(
          children: [
            // Children
            ...widget.children.asMap().entries.map<Widget>((entry) {
              var index = entry.key;
              var top = _getFoldedWeight(index, IterableModifier.take) *
                      effectiveDimension +
                  splitterSpace * index;
              var bottom = _getFoldedWeight(index + 1, IterableModifier.skip) *
                      effectiveDimension +
                  splitterSpace * (splitterCount - index);
              var rect = widget.splitDirection.isHorizonal
                  ? Rect.fromLTRB(0.0, top, 0.0, bottom)
                  : Rect.fromLTRB(top, 0.0, bottom, 0.0);
              return Positioned.fill(
                left: rect.left,
                top: rect.top,
                right: rect.right,
                bottom: rect.bottom,
                child: entry.value,
              );
            }).toList(),
            // Splitters
            ...List.generate(
              splitterCount,
              (index) {
                var top = _getFoldedWeight(index + 1, IterableModifier.take) *
                        effectiveDimension +
                    splitterSpace * index;
                var bottom =
                    _getFoldedWeight(index + 1, IterableModifier.skip) *
                            effectiveDimension +
                        splitterSpace * (splitterCount - index - 1);
                var rect = widget.splitDirection.isHorizonal
                    ? Rect.fromLTRB(0.0, top, 0.0, bottom)
                    : Rect.fromLTRB(top, 0.0, bottom, 0.0);
                return Positioned.fill(
                  left: rect.left,
                  top: rect.top,
                  right: rect.right,
                  bottom: rect.bottom,
                  child: MouseRegion(
                    cursor: splitterCursor,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
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
                      child: widget.splitterBuilder == null
                          ? Splitter(direction: widget.splitDirection)
                          : widget.splitterBuilder!(context),
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
    weights = List.generate(
        widget.children.length, (index) => 1 / widget.children.length);
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
