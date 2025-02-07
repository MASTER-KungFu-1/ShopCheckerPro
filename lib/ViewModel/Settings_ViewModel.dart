import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Map<String, ColorScheme> colorScheme = {
  'light': ColorScheme.light(
    surface: Color.fromARGB(232, 255, 255, 255),
    onPrimary: Colors.black,
    primary: Color.fromARGB(255, 255, 255, 255),
    secondary: Colors.purple,
  ),
  'dark': ColorScheme.dark(
    onPrimary: Colors.black,
    primary: Color.fromARGB(255, 255, 255, 255),
    secondary: Colors.orange,
  ),
};

class SettingsBase {
  final String theme;
  final bool activeThemeCheckBox;

  SettingsBase({
    required this.theme,
    this.activeThemeCheckBox = false,
  });

  SettingsBase copyWith({String? theme, bool? activeThemeCheckBox}) {
    return SettingsBase(
      theme: theme ?? this.theme,
      activeThemeCheckBox: activeThemeCheckBox ?? this.activeThemeCheckBox,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsBase> {
  SettingsNotifier() : super(SettingsBase(theme: 'dark'));

  void updateTheme(String theme) {
    state = state.copyWith(
      theme: theme,
      activeThemeCheckBox: theme == 'light',
    );
  }
}

/// Провайдер состояния
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsBase>(
  (ref) => SettingsNotifier(),
);
