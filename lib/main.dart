// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Importe les fichiers de configuration que vous avez créés
import 'firebase_options.dart';
import 'routes/app_routes.dart'; // Votre fichier pour gérer les routes
import 'theme/app_theme.dart'; // Votre nouveau fichier de thème centralisé
import 'providers/theme_provider.dart'; // Le provider qui gère l'état du thème (light/dark)

Future<void> main() async {
  // Assure que les bindings Flutter sont initialisés avant toute opération asynchrone.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase pour connecter votre app aux services Google.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialise les données de formatage pour la locale française (pour les dates, etc.).
  await initializeDateFormatting('fr_FR', null);

  // Lance l'application.
  // On l'enveloppe avec un ChangeNotifierProvider pour que le ThemeProvider
  // soit accessible depuis n'importe où dans l'application.
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
    // Récupère l'instance du ThemeProvider.
    // Le widget `MyApp` va maintenant "écouter" les changements dans ce provider.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EDUC Collecteur',

      // --- APPLICATION DU THÈME CENTRALISÉ ---

      // 1. On définit le thème à utiliser pour le mode clair.
      theme: AppTheme.lightTheme,

      // 2. On définit le thème à utiliser pour le mode sombre.
      darkTheme: AppTheme.darkTheme,

      // 3. On dit à MaterialApp quel mode utiliser ACTUELLEMENT.
      // Cette valeur est contrôlée par le provider.
      themeMode: themeProvider.themeMode,

      // --- CORRECTION DE L'ERREUR ---
      // On remplace AppRoutes.initialRoute par la chaîne de caractères directe,
      // car la variable 'initialRoute' n'est pas définie dans votre fichier AppRoutes.
      // '/' est la convention standard pour la page de démarrage.
      initialRoute: '/',

      // Définit toutes les routes possibles de l'application.
      routes: AppRoutes.routes,
    );
  }
}
