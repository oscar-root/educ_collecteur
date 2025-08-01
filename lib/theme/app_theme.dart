// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import nécessaire pour FilteringTextInputFormatter

// Classe pour centraliser toutes les couleurs de l'application
class AppColors {
  static const primary = Color(0xFF0D47A1); // Bleu profond et professionnel
  static const accent = Color(0xFF1976D2); // Un bleu un peu plus clair
  static const lightBackground = Color(0xFFF5F7FA); // Blanc cassé
  static const darkBackground = Color(0xFF121212); // Noir standard
  static const lightSurface = Colors.white; // Couleur des cartes en mode clair
  static const darkSurface =
      Color(0xFF1E1E1E); // Couleur des cartes en mode sombre
  static const error = Colors.red;
}

class AppTheme {
  // --- THÈME CLAIR ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineSmall:
          TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.lightSurface,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    // C'est ce thème qui sera utilisé par nos nouvelles méthodes
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.primary),
    ),
  );

  // --- THÈME SOMBRE ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineSmall:
          TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.darkSurface,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.accent),
    ),
  );
}

// =======================================================================
// --- CLASSE "USINE" POUR LES CHAMPS DE FORMULAIRE (CORRIGÉE) ---
// =======================================================================

class AppFormFields {
  /// Construit un champ de texte standard, stylisé selon le thème de l'application.
  static Widget buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLength: maxLength,
      // --- CORRECTION APPLIQUÉE ICI ---
      // On crée une InputDecoration et on lui applique les styles du thème,
      // puis on ajoute le labelText spécifique.
      decoration: InputDecoration(
        labelText: label,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      validator: validator ??
          (value) =>
              (value == null || value.isEmpty) ? 'Ce champ est requis.' : null,
    );
  }

  /// Construit un champ de texte NUMÉRIQUE, stylisé selon le thème
  /// ET qui bloque automatiquement la saisie de caractères non numériques.
  static Widget buildNumberField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLength: maxLength,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      // --- CORRECTION APPLIQUÉE ICI ---
      decoration: InputDecoration(
        labelText: label,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      validator: validator,
    );
  }
}
