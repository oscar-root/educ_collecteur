// lib/views/splash_screen.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// === CORRECTION PRINCIPALE ICI ===
// On utilise TickerProviderStateMixin qui peut gérer plusieurs animations
// au lieu de SingleTickerProviderStateMixin qui n'en gère qu'une seule.
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  Duration _elapsed = Duration.zero;

  late AnimationController _contentAnimationController;
  late Animation<Offset> _slideAnimation;

  final List<Bubble> _bubbles = [];
  final int _numberOfBubbles = 40;

  @override
  void initState() {
    super.initState();
    final random = Random();
    for (int i = 0; i < _numberOfBubbles; i++) {
      _bubbles.add(Bubble(
        color: Colors.white.withOpacity(random.nextDouble() * 0.4 + 0.1),
        size: random.nextDouble() * 50 + 10,
        initialPosition: Offset(random.nextDouble(), 1.2),
        speed: random.nextDouble() * 12 + 8,
        amplitude: random.nextDouble() * 50 + 20,
        phase: random.nextDouble() * pi * 2,
      ));
    }

    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsed = elapsed;
      });
    });
    _ticker.start();

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.015),
      end: const Offset(0, 0.015),
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeInOut,
    ));

    // La transition de 5 secondes est conservée
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue.shade200, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          CustomPaint(
            painter: BubblePainter(bubbles: _bubbles, elapsed: _elapsed),
            size: MediaQuery.of(context).size,
          ),
          Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 90,
                    color: Color(0xFF132F40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'EDUC.NC H-L1',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF132F40).withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Collecteur des données scolaires',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF3B566E).withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Le reste du code (Bubble, BubblePainter) reste parfaitement identique
class Bubble {
  final Color color;
  final double size;
  final Offset initialPosition;
  final double speed;
  final double amplitude;
  final double phase;

  Bubble({
    required this.color,
    required this.size,
    required this.initialPosition,
    required this.speed,
    required this.amplitude,
    required this.phase,
  });
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final Duration elapsed;

  BubblePainter({required this.bubbles, required this.elapsed});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final time = elapsed.inMilliseconds / 1000.0;
      final verticalProgress = (time * bubble.speed) / size.height;
      final currentY = size.height * (1 - (verticalProgress % 1.0));
      final currentX = size.width * bubble.initialPosition.dx +
          bubble.amplitude * sin(bubble.phase + time);

      final paint = Paint()..color = bubble.color;
      canvas.drawCircle(Offset(currentX, currentY), bubble.size, paint);

      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(currentX, currentY), bubble.size, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
