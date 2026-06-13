import 'dart:math' as math;
import 'package:flutter/material.dart';

class CyberGlowBackground extends StatefulWidget {
  final Widget child;
  const CyberGlowBackground({super.key, required this.child});

  @override
  State<CyberGlowBackground> createState() => _CyberGlowBackgroundState();
}

class _CyberGlowBackgroundState extends State<CyberGlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          
          // Smooth circular/figure-8 paths for drift
          final dx1 = math.sin(t * 2 * math.pi) * 60;
          final dy1 = math.cos(t * 2 * math.pi) * 60;

          final dx2 = math.cos(t * 2 * math.pi + math.pi / 3) * 80;
          final dy2 = math.sin(t * 2 * math.pi + math.pi / 3) * 50;

          final dx3 = math.sin(t * 2 * math.pi + 2 * math.pi / 3) * 50;
          final dy3 = math.cos(t * 2 * math.pi + 2 * math.pi / 3) * 70;

          return Stack(
            children: [
              // Dark elegant background
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF060608),
                ),
              ),
              // Top-Left Cyan Glow
              Positioned(
                top: -100 + dy1,
                left: -100 + dx1,
                child: const _GlowOrb(color: Color(0xFF00F2FE), size: 340),
              ),
              // Bottom-Right Blue/Cyan Glow
              Positioned(
                bottom: -50 + dy2,
                right: -100 + dx2,
                child: const _GlowOrb(color: Color(0xFF4FACFE), size: 320),
              ),
              // Center-Left Purple/Violet Glow
              Positioned(
                top: size.height * 0.35 + dy3,
                left: -140 + dx3,
                child: const _GlowOrb(color: Color(0xFF7F00FF), size: 300),
              ),
              // Overlay for blending and dark contrast
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Actual content child
              child!,
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.24),
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}
