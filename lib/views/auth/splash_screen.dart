import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;

  late AnimationController _bubbleController;
  late Animation<double> _bubbleScale;

  late AnimationController _progressController;
  int _progressPercent = 0;

  @override
  void initState() {
    super.initState();

    // --- Animation logo (pulsation légère) ---
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // --- Animation bulle (respiration) ---
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _bubbleScale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOut),
    );

    // --- Progression (0 → 100 %) ---
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        setState(() {
          _progressPercent = (_progressController.value * 100).toInt();
        });
      });

    _progressController.forward();

    // --- Aller vers /login après 8 sec ---
    Timer(const Duration(seconds: 8), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bubbleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- Bulle bleue animée ---
          Positioned(
            left: -60,
            bottom: -60,
            child: ScaleTransition(
              scale: _bubbleScale,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // --- Contenu principal ---
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: Image.asset(
                  'assets/images/logoeduc.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'EDUC.NC H-L1.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Collecteur des données scolaires',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- Progression + % ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progressController.value,
                      minHeight: 8,
                      color: Colors.blueAccent,
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_progressPercent%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
