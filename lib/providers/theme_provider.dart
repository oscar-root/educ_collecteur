// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Méthode pour basculer le thème
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    // Notifie tous les widgets qui écoutent ce provider qu'un changement a eu lieu,
    // afin qu'ils se reconstruisent avec le nouveau thème.
    notifyListeners();
  }
}
