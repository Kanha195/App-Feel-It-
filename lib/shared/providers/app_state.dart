import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppMode { traveler, captain }

class AppModeController extends Notifier<AppMode> {
  @override
  AppMode build() => AppMode.traveler;

  void setMode(AppMode mode) => state = mode;
}

final appModeProvider =
    NotifierProvider<AppModeController, AppMode>(AppModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class MascotOutfitsController extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {
        'dowie': 'trail',
        'snowie': 'summit',
      };

  void equip(String mascot, String outfit) {
    state = {...state, mascot: outfit};
  }
}

final mascotOutfitsProvider =
    NotifierProvider<MascotOutfitsController, Map<String, String>>(
  MascotOutfitsController.new,
);
