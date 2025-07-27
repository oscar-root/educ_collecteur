import 'package:flutter/material.dart';

import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/reset_password_view.dart';
import '../views/dashboard/admin_dashboard_view.dart';
import '../views/dashboard/directeur_dashboard_view.dart';
import '../views/dashboard/chef_dashboard_view.dart';
import '../views/auth/splash_screen.dart';
import '../views/st2/pages/st2_form_page1.dart';
import '../views/st2/pages/st2_form_page2.dart'; // Import des pages du formulaire ST2
import '../views/st2/pages/st2_form_page3.dart';
import '../views/st2/pages/st2_form_page4.dart';

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
    '/form1':
        (context) => ST2FormPage1(
          onNext: () => Navigator.pushNamed(context, '/form2'),
          onSave: (data) {
            // stocker les données dans un Provider, controller, etc.
          },
        ),
    '/form2':
        (context) => ST2FormPage2(
          onPrevious: () => Navigator.pop(context),
          onNext: () => Navigator.pushNamed(context, '/form3'),
          onSave: (data) {},
        ),
    '/form3':
        (context) => ST2FormPage3(
          niveauEcole: 'primaire', // valeur à passer dynamiquement si possible
          onPrevious: () => Navigator.pop(context),
          onNext: () => Navigator.pushNamed(context, '/form4'),
          onSave: (data) {},
        ),
    '/form4':
        (context) => ST2FormPage4(
          niveauEcole: 'primaire',
          onPrevious: () => Navigator.pop(context),
          onSubmit: () {
            // envoyer à Firebase ici
          },
          onSave: (data) {},
        ),

    // Tu peux ajouter d'autres routes ici
  };
}
