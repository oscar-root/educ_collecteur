import 'package:flutter/material.dart';

import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/reset_password_view.dart';
import '../views/dashboard/admin_dashboard_view.dart';
import '../views/dashboard/directeur_dashboard_view.dart';
import '../views/dashboard/chef_dashboard_view.dart';
import '../views/auth/splash_screen.dart';
import '../views/st2/st2_form_view.dart' show ST2FormView; // Chemin corrigé

class AppRoutes {
  // CORRECTION ICI : on retourne directement un map statique
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(), // Page de lancement
    '/login': (context) => const LoginView(), // Connexion
    '/register': (context) => const RegisterView(), // Inscription
    '/reset-password':
        (context) => const ResetPasswordView(), // Réinitialisation
    '/admin-dashboard': (context) => const AdminDashboardView(),
    '/directeur-dashboard': (context) => const DirecteurDashboardView(),
    '/chef-dashboard': (context) => const ChefDashboardView(),
    '/st2-form': (context) => const ST2FormView(),
    // Tu peux ajouter d'autres routes ici
  };
}
