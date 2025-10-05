import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  /// Pass your real app-initialization future here.
  /// When it completes, the logo will exit and navigation occurs.
  final Future<void> loadFuture;

  const SplashScreen({
    super.key,
    required this.loadFuture,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Bubbles
  late final AnimationController _bubbleCtrl;
  late final List<_Bubble> _bubbles;

  // Logo
  late final AnimationController _enterCtrl; // bottom -> center
  late final AnimationController _wiggleCtrl; // lateral wiggle while waiting
  late final AnimationController _exitCtrl; // center -> top

  bool _enteredCenter = false;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();

    // --- BUBBLES ---
    _bubbles = _makeBubbles(22); // tweak count as you like
    _bubbleCtrl = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(); // continuous “conveyor belt” of bubbles

    // --- LOGO ---
    _enterCtrl = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _enteredCenter = true);
        _wiggleCtrl.repeat(reverse: true);
      }
    });

    _wiggleCtrl = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    _exitCtrl = AnimationController(
      duration: const Duration(milliseconds: 480),
      vsync: this,
    );

    // Start entrance animation immediately
    _enterCtrl.forward();

    // Hook to the real loading with minimum duration
    final startTime = DateTime.now();
    widget.loadFuture.then((_) async {
      if (!mounted) return;
      
      // Ensure minimum splash duration of 2 seconds
      final elapsed = DateTime.now().difference(startTime);
      final remainingTime = 2000 - elapsed.inMilliseconds;
      
      if (remainingTime > 0) {
        await Future.delayed(Duration(milliseconds: remainingTime));
      }
      
      if (!mounted) return;
      
      // Trigger exit: stop wiggle, run exit
      setState(() => _exiting = true);
      _wiggleCtrl.stop();
      _exitCtrl.forward(from: 0).then((_) {
        if (mounted) {
          context.go('/'); // navigate when exit animation finishes
        }
      });
    });
  }

  @override
  void dispose() {
    _bubbleCtrl.dispose();
    _enterCtrl.dispose();
    _wiggleCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenW = size.width;
    final screenH = size.height;
    final logoSize = screenW * 0.9;

    // Positions for logo travel
    final startY = screenH + logoSize;       // off-screen bottom
    final centerY = (screenH - logoSize) / 2; // centered vertically
    final endY = -logoSize * 1.2;            // off-screen top

    return Scaffold(
      backgroundColor: AppTheme.lightTeal,
      body: AnimatedBuilder(
        animation: Listenable.merge([_bubbleCtrl, _enterCtrl, _wiggleCtrl, _exitCtrl]),
        builder: (context, _) {
          // --- LOGO POSITION ---
          final enterT = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic).value;
          final exitT = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic).value;

          double logoY;
          if (!_enteredCenter) {
            // moving from bottom to center
            logoY = lerpDouble(startY, centerY, enterT)!;
          } else if (_exiting) {
            // moving from center to top
            logoY = lerpDouble(centerY, endY, exitT)!;
          } else {
            // waiting at center while app loads
            logoY = centerY;
          }

          // Wiggle amplitude reduces a touch during exit for a snappy feel
          final baseWiggle = 10.0;
          final wiggleAmp = _exiting ? baseWiggle * (1 - exitT) : baseWiggle;
          final wiggleX = math.sin(_wiggleCtrl.value * 2 * math.pi) * wiggleAmp;

          return Stack(
            children: [
              // --- BUBBLES LAYER ---
              Positioned.fill(
                child: CustomPaint(
                  painter: _BubblePainter(
                    bubbles: _bubbles,
                    t: _bubbleCtrl.value,
                    screenSize: size,
                    colorFill: AppTheme.primaryTeal.withValues(alpha: 0.28),
                    colorStroke: AppTheme.primaryTeal.withValues(alpha: 0.60),
                  ),
                ),
              ),

              // --- LOGO LAYER ---
              Positioned(
                left: (screenW - logoSize) / 2 + wiggleX,
                top: logoY,
                child: SizedBox(
                  width: logoSize,
                  height: logoSize,
                   child: Opacity(
                     // Slight fade during exit looks nice
                     opacity: _exiting ? (1 - exitT).clamp(0.0, 1.0) : 1.0,
                     child: Image.asset(
                       'assets/images/logo-01.png',
                       fit: BoxFit.contain,
                     ),
                   ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Helpers --------------------------------------------------------------

  List<_Bubble> _makeBubbles(int count) {
    final rnd = math.Random();
    return List.generate(count, (i) {
      // Each bubble gets its own speed, phase (delay), size, and lateral wiggle
      final size = 8 + rnd.nextDouble() * 40;        // 8–30 px
      final startXNorm = rnd.nextDouble();            // 0..1 of width
      final speed = 0.55 + rnd.nextDouble() * 0.7;    // relative speed
      final phase = rnd.nextDouble();                 // 0..1 initial offset
      final wiggle = 12 + rnd.nextDouble() * 42;      // lateral amplitude
      return _Bubble(size: size, startXNorm: startXNorm, speed: speed, phase: phase, wiggle: wiggle);
    });
  }
}

// Bubble model
class _Bubble {
  final double size;
  final double startXNorm; // 0..1 across screen
  final double speed;      // multiplier for vertical progress
  final double phase;      // initial offset 0..1
  final double wiggle;     // px lateral wiggle amplitude

  const _Bubble({
    required this.size,
    required this.startXNorm,
    required this.speed,
    required this.phase,
    required this.wiggle,
  });
}

// Painter for many lightweight bubbles
class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double t; // 0..1 from the repeating controller
  final Size screenSize;
  final Color colorFill;
  final Color colorStroke;

  _BubblePainter({
    required this.bubbles,
    required this.t,
    required this.screenSize,
    required this.colorFill,
    required this.colorStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()..style = PaintingStyle.fill..color = colorFill;
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colorStroke;

    final w = screenSize.width;
    final h = screenSize.height;

    for (final b in bubbles) {
      // Progress for each bubble (wraps 0..1)
      final p = (t * b.speed + b.phase) % 1.0;

      // Vertical: from bottom (off) to top (off) with slight overshoot
      final y = h + b.size - (h + b.size * 2) * p;

      // Lateral wiggle, tapering as it rises
      final wiggleDecay = (1 - p);
      final x = b.startXNorm * w + math.sin(p * math.pi * 3) * b.wiggle * wiggleDecay;

      // Fade out slightly near the top for nicer vanish
      final fade = (1 - p).clamp(0.0, 1.0);
      final fill = paintFill..color = colorFill.withValues(alpha: colorFill.a * fade);
      final stroke = paintStroke..color = colorStroke.withValues(alpha: colorStroke.a * (0.8 * fade + 0.2));

      final rect = Rect.fromCircle(center: Offset(x, y), radius: b.size / 2);
      canvas.drawOval(rect, fill);
      canvas.drawOval(rect, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.bubbles != bubbles || oldDelegate.screenSize != screenSize;
}
