// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  // Le getter que `main.dart` utilise pour définir le thème de MaterialApp.
  ThemeMode get themeMode => _themeMode;

  // --- AJOUT DE LA LIGNE MANQUANTE ---
  // C'est le getter qui manquait. Il renvoie `true` si le thème est sombre,
  // et `false` sinon. C'est exactement ce dont le SwitchListTile a besoin
  // pour sa propriété `value`.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Méthode pour basculer le thème, appelée par le Switch.
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Notifie tous les widgets qui écoutent ce provider qu'un changement a eu lieu,
    // afin qu'ils se reconstruisent avec le nouveau thème.
    notifyListeners();
  }
}
