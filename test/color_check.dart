import 'package:flutter/material.dart';

void main() {
  final seed = const Color(0xFF00BCD4);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  print('Seed Color: ${seed.value.toRadixString(16).toUpperCase()}');
  print(
    'Generated Primary: ${scheme.primary.value.toRadixString(16).toUpperCase()}',
  );

  if (seed.value != scheme.primary.value) {
    print('DIFFERENT! Material 3 generates a minimal tonal palette pivot.');
  } else {
    print('SAME!');
  }
}
