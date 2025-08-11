// lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final bool enabled;
  final Widget? suffixIcon;

  const CustomTextField(
      {super.key,
      this.controller,
      required this.labelText,
      required this.icon,
      this.obscureText = false,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.inputFormatters,
      this.initialValue,
      this.enabled = true,
      this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,

      // Style du texte tapé par l'utilisateur
      style: GoogleFonts.poppins(
          color: Colors.black87, fontWeight: FontWeight.w500),
      cursorColor: Colors.blue.shade700,

      // --- NOUVELLE DÉCORATION ULTRA-AFFINÉE ---
      decoration: InputDecoration(
        // Le label est maintenant à l'intérieur et flotte au-dessus au focus
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        floatingLabelStyle: GoogleFonts.poppins(
            color: Colors.blue.shade700, fontWeight: FontWeight.w600),

        prefixIcon: Icon(icon, color: Colors.grey[500]),
        suffixIcon: suffixIcon,

        // Bordures très discrètes pour un look minimaliste
        filled: true,
        fillColor: Colors.grey.shade50.withOpacity(0.5), // Fond très subtil

        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 16),

        // Bordure quand le champ est inactif
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        // Bordure quand l'utilisateur clique sur le champ
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2.5),
        ),
        // Bordure pour les erreurs
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2.5),
        ),
      ),
    );
  }
}
