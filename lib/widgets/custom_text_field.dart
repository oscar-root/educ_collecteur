// lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package.flutter/services.dart';

class CustomTextField extends StatelessWidget {
  // Le contrôleur est rendu optionnel pour plus de flexibilité
  final TextEditingController? controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  // Nouveaux paramètres optionnels pour la page d'édition
  final String? initialValue;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.initialValue,

    // --- CORRECTION MAJEURE APPLIQUÉE ICI ---
    // 1. Le mot-clé 'required' est supprimé.
    // 2. Une valeur par défaut 'true' est assignée.
    this.enabled = true,
  }) : assert(
         initialValue == null || controller == null,
         'Un CustomTextField ne peut pas avoir à la fois un "controller" et une "initialValue".',
       );

  @override
  Widget build(BuildContext context) {
    // On utilise TextFormField pour une meilleure intégration avec les formulaires (Form)
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled, // Le paramètre est maintenant utilisé ici
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        // Style visuel pour les champs désactivés
        filled: !enabled,
        fillColor:
            !enabled ? Theme.of(context).hoverColor.withOpacity(0.5) : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
    );
  }
}
