// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  // Assure que les bindings Flutter sont initialisés.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialise les données de formatage pour la locale française.
  await initializeDateFormatting('fr_FR', null);

  // Lance l'application en l'enveloppant avec le Provider pour la gestion du thème.
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupère l'instance du ThemeProvider pour écouter les changements de thème.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EDUC Collecteur',

      // Ces lignes sont maintenant valides car AppTheme.darkTheme existe.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Le mode actuel (light/dark) est contrôlé par le provider.
      themeMode: themeProvider.themeMode,

      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
