import 'dart:async';
import 'dart:math';
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
  late AnimationController _bubblesController;

  final Random _random = Random();

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

    // Animation des bulles
    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _controller.forward();

    // Durée prolongée à 5 secondes
    Timer(const Duration(seconds: 8), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoRotationController.dispose();
    _bubblesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- bulles animées en arrière-plan ---
          AnimatedBuilder(
            animation: _bubblesController,
            builder: (context, child) {
              return CustomPaint(
                painter: BubblePainter(
                  animationValue: _bubblesController.value,
                  random: _random,
                ),
                child: Container(),
              );
            },
          ),

          // --- contenu principal ---
          Center(
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
                      'EDUC.NC DIPRO H-L1',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painter pour bulles rouges animées ---
class BubblePainter extends CustomPainter {
  final double animationValue;
  final Random random;

  BubblePainter({required this.animationValue, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red.withOpacity(0.2);

    for (int i = 0; i < 20; i++) {
      final dx = (size.width / 20) * i + (10 * sin(animationValue * 2 * pi));
      final dy = size.height * (0.2 + (0.8 * ((i + animationValue) % 1)));

      final radius = 10 + (5 * sin((animationValue * 2 * pi) + i));

      canvas.drawCircle(Offset(dx, dy), radius.abs(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
