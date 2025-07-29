// lib/routes/app_routes.dart

import 'package:flutter/material.dart';

// --- Imports des Vues ---
import '../views/auth/splash_screen.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/reset_password_view.dart';

import '../views/dashboard/admin_dashboard_view.dart';
import '../views/dashboard/directeur_dashboard_view.dart';
import '../views/dashboard/chef_dashboard_view.dart';
// --- L'IMPORT CORRESPOND MAINTENANT AU NOM DE VOTRE FICHIER ---
import '../views/dashboard/chef_service_dashboard_view.dart';

import '../views/st2/pages/st2_form_page.dart';
import '../views/st2/st2_detail_view.dart';

// --- Import du Modèle ---
import '../models/st2_model.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    // --- Routes d'Authentification ---
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginView(),
    '/register': (context) => const RegisterView(),
    '/reset-password': (context) => const ResetPasswordView(),

    // --- Routes des Dashboards ---
    '/admin_dashboard': (context) => const AdminDashboardView(),
    '/directeur_dashboard': (context) => const DirecteurDashboardView(),
    '/chef_dashboard': (context) => const ChefDashboardView(),

    // --- CORRECTION FINALE ICI ---
    // La clé de la route correspond à l'appel dans login_view.dart
    // La valeur correspond maintenant au nom exact de votre classe.
    '/chef_service_dashboard': (context) => const ChefServiceDashboardView(),

    // --- Autres Routes ---
    '/st2-form': (context) => const ST2FormPage(),

    '/st2_detail_view': (context) {
      final form = ModalRoute.of(context)!.settings.arguments as ST2Model;
      return ST2DetailView(form: form);
    },
  };
}
