# splittable_view

A splittable view is a widget that manages child widgets in a separated
(split) areas. I supports more that 2 children in a single splittable view.

## Example

```dart
SplitterTheme(
  data: SplitterThemeData(
    indent: 16.0,
    endIndent: 16.0,
    space: 12.0,
  ),
  child: SplittableColumn(
    initialWeights: initialWeights,
    onSplittingEnd: (weights) => preferences.setStringList(
        storageKey, weights.map((ratio) => '$ratio').toList()),
    onResetWeights: () => preferences.remove(storageKey),
    children: [
      Scrollbar(
        child: ListView(
          children: List.generate(
            50,
            (index) => ListTile(
              title: Text('Location $index'),
            ),
          ),
        ),
      ),
      Scrollbar(
        child: ListView(
          children: List.generate(
            50,
            (index) => ListTile(
              title: Text('Camera $index'),
            ),
          ),
        ),
      ),
    ],
  ),
),
```

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.
