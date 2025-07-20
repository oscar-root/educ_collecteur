import 'package:flutter/material.dart';

import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/reset_password_view.dart';

import '../views/dashboard/admin_dashboard_view.dart';
import '../views/dashboard/chef_dashboard_view.dart';
import '../views/dashboard/directeur_dashboard_view.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/': (context) => const LoginView(),
    '/register': (context) => const RegisterView(),
    '/reset-password': (context) => const ResetPasswordView(),
    '/admin-dashboard': (context) => const AdminDashboardView(),
    '/chef-dashboard': (context) => const ChefDashboardView(),
    '/directeur-dashboard': (context) => const DirecteurDashboardView(),
  };
}
