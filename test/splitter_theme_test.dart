import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:splittable_view/splittable_view.dart';

const _space = 8.0;

void main() {
  test('fallback', () {
    var theme = SplitterThemeData.fallback();
    expect(theme.color, null);
    expect(theme.space, _space);
    expect(theme.thickness, 0.0);
    expect(theme.indent, 0.0);
    expect(theme.endIndent, 0.0);
    expect(theme.enableIcon, false);
  });
  test('copyWith', () {
    var theme = SplitterThemeData().copyWith(
      color: Colors.black26,
      space: _space,
      thickness: 1.0,
      indent: 16.0,
      endIndent: 16.0,
    );
    expect(theme.color, Colors.black26);
    expect(theme.space, _space);
    expect(theme.thickness, 1.0);
    expect(theme.indent, 16.0);
    expect(theme.endIndent, 16.0);
  });
}
