import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<String, ColorScheme> colorScheme = {
  'ligth': const ColorScheme.light(
      background: Color.fromARGB(232, 255, 255, 255),
      onPrimary: Colors.black,
      primary: Color.fromARGB(255, 255, 255, 255),
      secondary: Colors.purple),
  'dark': const ColorScheme.dark(
      onPrimary: Colors.black,
      primary: Color.fromARGB(255, 255, 255, 255),
      secondary: Colors.amber),
};

class SettingsBase {
  final String theme;

  SettingsBase({required this.theme});

  SettingsBase copyWith({String? theme}) {
    return SettingsBase(theme: theme ?? this.theme);
  }
}

class SettingsNotifier extends StateNotifier<SettingsBase> {
  SettingsNotifier() : super(SettingsBase(theme: 'light'));

  void updateTheme(String theme) {
    state = state.copyWith(theme: theme);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsBase>(
    (ref) => SettingsNotifier());
