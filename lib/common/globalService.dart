import 'package:flutter/material.dart';

class GlobalService {
  Future<ThemeMode> themeMode() async => ThemeMode.system;
  Future<void> updateThemeMode(ThemeMode theme) async {}
}
