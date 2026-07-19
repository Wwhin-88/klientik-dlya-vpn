import 'dart:math';
import 'package:flutter/material.dart';

/// A lightweight animated background that renders floating hearts (upward)
/// and sakura/star particles (downward) using a CustomPainter.
/// Uses ~30 particles at ~30fps — smooth and subtle.
class AnimeBackground extends StatefulWidget {
  const AnimeBackground({super.key});

  @override
  State<AnimeBackground> createState() => _AnimeBackgroundState();
}

class _AnimeBackgroundState extends State<AnimeBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  static const int _particleCount = 30;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle._random(_random));
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Update particles
        for (final p in _particles) {
          p.update();
        }
        return ClipRect(
          child: CustomPaint(
            size: Size.infinite,
            painter: _AnimeBackgroundPainter(_particles),
          ),
        );
      },
    );
  }
}

/// A single floating particle — heart (upward) or sakura/star (downward)
class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double wobblePhase;
  final bool isHeart;
  double rotation;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.wobblePhase,
    required this.isHeart,
    this.rotation = 0,
  });

  factory _Particle._random(Random r) {
    final isHeart = r.nextBool();
    return _Particle(
      x: r.nextDouble() * 1.2 - 0.1, // 0-1 range with overflow
      y: r.nextDouble() * 1.2 - 0.1,
      size: isHeart ? r.nextDouble() * 6 + 6 : r.nextDouble() * 5 + 4, // hearts: 6-12px, sakura: 4-9px
      speed: isHeart ? r.nextDouble() * 0.15 + 0.05 : r.nextDouble() * 0.12 + 0.08,
      opacity: r.nextDouble() * 0.35 + 0.15,
      wobblePhase: r.nextDouble() * 2 * pi,
      isHeart: isHeart,
      rotation: r.nextDouble() * 2 * pi,
    );
  }

  void update() {
    if (isHeart) {
      // Hearts float upward with a gentle wobble
      y -= speed * 0.008;
      wobblePhase += 0.03;
      x += sin(wobblePhase) * 0.003;
      rotation += 0.005;
    } else {
      // Sakura/stars float downward with a gentle wobble
      y += speed * 0.007;
      wobblePhase += 0.025;
      x += cos(wobblePhase) * 0.002;
      rotation -= 0.008;
    }

    // Wrap around
    if (y < -0.1) {
      y = 1.1;
      x = Random().nextDouble();
    }
    if (y > 1.1) {
      y = -0.1;
      x = Random().nextDouble();
    }
    if (x < -0.1) x = 1.1;
    if (x > 1.1) x = -0.1;
  }
}

class _AnimeBackgroundPainter extends CustomPainter {
  final List<_Particle> particles;

  _AnimeBackgroundPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient overlay
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFF0F3).withValues(alpha: 0.3),
          const Color(0xFFFFFAF5).withValues(alpha: 0.6),
          const Color(0xFFFFF0F3).withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradient);

    for (final p in particles) {
      final cx = p.x * size.width;
      final cy = p.y * size.height;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(p.rotation);

      if (p.isHeart) {
        _drawHeart(canvas, p.size, p.opacity);
      } else {
        _drawSakura(canvas, p.size, p.opacity);
      }

      canvas.restore();
    }
  }

  void _drawHeart(Canvas canvas, double size, double opacity) {
    final paint = Paint()
      ..color = const Color(0xFFF8BBD0).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    final s = size / 2;
    // Simple heart shape using cubic beziers
    path.moveTo(0, s * 0.25);
    path.cubicTo(-s * 0.6, -s * 0.4, -s * 1.2, s * 0.15, 0, s * 0.9);
    path.cubicTo(s * 1.2, s * 0.15, s * 0.6, -s * 0.4, 0, s * 0.25);
    path.close();

    // Also draw a secondary slightly larger heart for a soft glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD1B3).withValues(alpha: opacity * 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: size * 0.6)),
      glowPaint,
    );

    canvas.drawPath(path, paint);
  }

  void _drawSakura(Canvas canvas, double size, double opacity) {
    final paint = Paint()
      ..color = const Color(0xFFFFD1B3).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Draw a 5-petal flower (sakura-inspired)
    final petalPaint = Paint()
      ..color = const Color(0xFFFFD1B3).withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.fill;

    final r = size / 2;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - pi / 2;
      final px = cos(angle) * r * 0.5;
      final py = sin(angle) * r * 0.5;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(angle);
      final petalPath = Path()
        ..moveTo(0, -r * 0.3)
        ..cubicTo(r * 0.25, -r * 0.1, r * 0.25, r * 0.1, 0, r * 0.3)
        ..cubicTo(-r * 0.25, r * 0.1, -r * 0.25, -r * 0.1, 0, -r * 0.3)
        ..close();
      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }

    // Center dot
    canvas.drawCircle(Offset.zero, r * 0.15, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimeBackgroundPainter oldDelegate) => true;
}
