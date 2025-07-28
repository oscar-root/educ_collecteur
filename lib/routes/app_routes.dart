// lib/app_routes.dart

import 'package:flutter/material.dart';

// Imports des vues principales
import '../views/auth/splash_screen.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/reset_password_view.dart';

// Imports des Dashboards pour chaque rôle
import '../views/dashboard/admin_dashboard_view.dart';
import '../views/dashboard/directeur_dashboard_view.dart';
import '../views/dashboard/chef_dashboard_view.dart'; // L'import est correct

// Import de la page unique du formulaire ST2
import '../views/st2/pages/st2_form_page.dart';

class AppRoutes {
  /// Map de toutes les routes nommées de l'application.
  /// Une route nommée permet de naviguer vers un écran sans avoir à l'importer directement.
  static final Map<String, WidgetBuilder> routes = {
    // --- Routes d'Authentification et de démarrage ---
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginView(),
    '/register': (context) => const RegisterView(),
    '/reset-password': (context) => const ResetPasswordView(),

    // --- Routes des Dashboards par Rôle ---
    '/admin-dashboard': (context) => const AdminDashboardView(),
    '/directeur-dashboard': (context) => const DirecteurDashboardView(),

    // CORRECTION : Utilisation du nom de widget correct 'ChefDashboardView'.
    '/chef-dashboard': (context) => const ChefDashboardView(),

    // --- Routes des formulaires et autres pages ---

    // AJOUT : Une route propre et unique pour le formulaire ST2 complet.
    '/st2-form': (context) => const ST2FormPage(),

    // SUPPRESSION : L'ancienne route '/form1' est retirée car elle est obsolète.
    // Les routes pour form2, form3, etc., sont également inutiles.
  };
}
