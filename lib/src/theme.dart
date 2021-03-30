// Copyright 2021 BambinoUA. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    double? space,
    double? thickness,
    double? indent,
    double? endIndent,
    this.enableIcon = false,
  }) : super(
          color: color,
          space: space,
          thickness: thickness,
          indent: indent,
          endIndent: endIndent,
        );

  /// The default [Splitter] color theme.
  ///
  /// This is used by [SplitterTheme.of] when no theme has been specified.
  const SplitterThemeData.fallback({
    double space = 8.0,
    double thickness = 0.0,
    double indent = 0.0,
    double endIndent = 0.0,
    bool enableIcon = false,
  }) : this(
          space: space,
          thickness: thickness,
          indent: indent,
          endIndent: endIndent,
          enableIcon: enableIcon,
        );

  /// Indicates whether icon is enabled on [Splitter].
  final bool? enableIcon;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  @override
  SplitterThemeData copyWith({
    Color? color,
    double? space,
    double? thickness,
    double? indent,
    double? endIndent,
    bool? enableIcon,
  }) =>
      SplitterThemeData(
        color: color ?? this.color,
        space: space ?? this.space,
        thickness: thickness ?? this.thickness,
        indent: indent ?? this.indent,
        endIndent: endIndent ?? this.endIndent,
        enableIcon: enableIcon ?? this.enableIcon,
      );

  @override
  int get hashCode => hashValues(super.hashCode, enableIcon);

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

/// Applies a theme to descendant [Splitter] widget.
///
/// Descendant widget obtain the current theme's [SplitterThemeData] object using
/// [SplitterTheme.of]. When a widget uses [SplitterTheme.of], it is automatically
/// rebuilt if the theme later changes, so that the changes can be applied.
class SplitterTheme extends InheritedTheme {
  /// Creates a splitter theme that controls the theme configuration for [Splitter].
  const SplitterTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [Splitter].
  final SplitterThemeData data;

  /// The closest instance of this class's [data] value that encloses the given
  /// context.
  static SplitterThemeData of(BuildContext context) {
    var splitterTheme =
        context.dependOnInheritedWidgetOfExactType<SplitterTheme>();
    if (splitterTheme == null) {
      return SplitterThemeData.fallback()
          .copyWith(color: Theme.of(context).dividerColor);
    }
    var splitterThemeData = splitterTheme.data;
    // Set default splitter space
    if (splitterTheme.data.space == null) {
      splitterThemeData = splitterThemeData.copyWith(space: 8.0);
    }
    // Set default splitter color
    if (splitterTheme.data.color == null) {
      splitterThemeData = splitterThemeData.copyWith(
          color:
              DividerTheme.of(context).color ?? Theme.of(context).dividerColor);
    }
    return splitterThemeData;
  }

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SplitterTheme(data: data, child: child);

  @override
  bool updateShouldNotify(SplitterTheme oldWidget) => data != oldWidget.data;
}
