// Copyright 2021 BambinoUA. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Provides weight data for this `child`.
@immutable
class SplittableChild {
  /// Creates instane of split `child` with `flex`.
  const SplittableChild({
    required this.child,
    this.flex = 1,
  }) : assert(flex > 0);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Contains weight of this split child in natural numbers.
  final int flex;
}

/// Defines the visual properties of [Splitter].
///
/// Descendant widgets obtain the current [SplitterThemeData] object using
/// `SplitterTheme.of(context)`. Instances of [SplitterThemeData]
/// can be customized with [SplitterThemeData.copyWith].
@immutable
class SplitterThemeData extends DividerThemeData {
  /// Creates a theme that can be used for [SplitterTheme].
  const SplitterThemeData({
    Color? color,
    double space = 16.0,
    double thickness = 0.0,
    double indent = 0.0,
    double endIndent = 0.0,
    this.enableIcon = true,
  }) : super(
            color: color,
            space: space,
            thickness: thickness,
            indent: indent,
            endIndent: endIndent);

  /// Indicates whether icon is enabled on [Splitter].
  final bool? enableIcon;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  @override
  SplitterThemeData copyWith(
      {Color? color,
      double? space,
      double? thickness,
      double? indent,
      double? endIndent,
      bool? enableIcon}) {
    return copyWith(
      color: color ?? this.color,
      space: space ?? this.space,
      thickness: thickness ?? this.thickness,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? endIndent,
      enableIcon: enableIcon ?? enableIcon,
    );
  }

  @override
  int get hashCode {
    return hashValues(
      super.hashCode,
      enableIcon,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is SplitterThemeData &&
        other.color == color &&
        other.space == space &&
        other.thickness == thickness &&
        other.indent == indent &&
        other.endIndent == endIndent &&
        other.enableIcon == enableIcon;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('enableIcon', enableIcon,
        defaultValue: true));
  }
}

/// An inherited widget that defines the configuration for
/// [Splitter]s, [SplitterDivider]s in this widget's subtree.
class SplitterTheme extends InheritedTheme {
  /// Creates a splitter theme that controls the configurations for
  /// [Splitter]s, [SplitterDivider]s in its widget subtree.
  const SplitterTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [Splitter]s, [SplitterDivider]s.
  final SplitterThemeData data;

  /// The closest instance of this class's [data] value that encloses the given
  /// context.
  static SplitterThemeData of(BuildContext context) {
    var splitterTheme =
        context.dependOnInheritedWidgetOfExactType<SplitterTheme>();
    return splitterTheme != null
        ? splitterTheme.data
        : SplitterThemeData(color: Theme.of(context).dividerColor);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SplitterTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(SplitterTheme oldWidget) => data != oldWidget.data;
}
