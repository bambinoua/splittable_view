// Copyright 2021 BambinoUA. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// Useful extensions.
extension AxisExtension on Axis {
  /// Returs `true` if axis is horizontal.
  bool get isHorizonal => this == Axis.horizontal;

  /// Returs `true` if axis is vertical.
  bool get isVertical => this == Axis.vertical;
}
