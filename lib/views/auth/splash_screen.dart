import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _logoRotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // Animations logo (scale + fade)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Rotation du logo
    _logoRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Progress bar rouge
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();

    _controller.forward();

    // Transition vers /login
    Timer(const Duration(seconds: 8), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoRotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- contenu principal ---
          Expanded(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotationTransition(
                        turns: Tween(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(_logoRotationController),
                        child: Image.asset(
                          'assets/images/logoeduc.png',
                          width: 120,
                          height: 120,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'EDUC.NC H-L1',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
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
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Progress bar rouge en bas ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressController.value,
                  minHeight: 6,
                  color: Colors.red,
                  backgroundColor: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
