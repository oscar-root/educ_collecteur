// lib/widgets/custom_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  const CustomButton(
      {super.key,
      required this.text,
      this.onPressed,
      this.icon,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isLoading || onPressed == null;

    // Conteneur extérieur pour gérer le dégradé et l'ombre
    return DecoratedBox(
      decoration: BoxDecoration(
        // Le dégradé subtil ne s'affiche que si le bouton est actif
        gradient: isDisabled
            ? null
            : LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        // Si le bouton est désactivé, il prend une couleur unie et discrète
        color: isDisabled ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(16.0),
        // Ombre portée moderne pour donner de la profondeur
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          // Styles pour rendre le bouton "transparent" et laisser passer le dégradé
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,

          minimumSize: const Size.fromHeight(56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3.0))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 22, color: Colors.white),
                      const SizedBox(width: 12)
                    ],
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
