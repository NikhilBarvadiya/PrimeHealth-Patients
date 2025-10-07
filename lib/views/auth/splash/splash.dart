import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/auth/splash/splash_ctrl.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation, _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1800), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashCtrl>(
      init: SplashCtrl(),
      builder: (context) {
        return Scaffold(
          backgroundColor: AppTheme.primaryTeal,
          body: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.primaryTeal, AppTheme.primaryDark, AppTheme.primaryDark]),
                ),
                child: Stack(
                  children: [
                    _buildBackgroundElements(),
                    Center(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildAppLogo(),
                                const SizedBox(height: 32),
                                _buildAppName(),
                                const SizedBox(height: 12),
                                _buildTagline(),
                                const SizedBox(height: 48),
                                _buildLoadingIndicator(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildFooter(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBackgroundElements() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.03)),
            ),
          ),
          Positioned(
            top: 120,
            left: 60,
            child: Opacity(
              opacity: _fadeAnimation.value * 0.4,
              child: Icon(Icons.favorite_rounded, size: 24, color: Colors.white.withOpacity(0.3)),
            ),
          ),
          Positioned(
            bottom: 180,
            right: 80,
            child: Opacity(
              opacity: _fadeAnimation.value * 0.3,
              child: Icon(Icons.medical_services_rounded, size: 32, color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Center(child: Icon(Icons.health_and_safety_rounded, size: 48, color: AppTheme.primaryTeal)),
          if (_controller.status == AnimationStatus.forward)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RipplePainter(progress: _controller.value, color: Colors.white.withOpacity(0.3)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppName() {
    return Text(
      'Prime Health',
      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Your Health, Our Priority',
      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.8), letterSpacing: 0.3),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(_controller.value >= (index + 1) * 0.3 ? 1.0 : 0.3)),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text('Preparing your experience...', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0))),
        child: Column(
          children: [
            Text('Secure • Private • Trusted', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 8),
            Text('HIPAA Compliant', style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.8;

    for (int i = 0; i < 3; i++) {
      final rippleProgress = (progress - i * 0.2).clamp(0.0, 1.0);
      if (rippleProgress > 0) {
        final radius = maxRadius * rippleProgress;
        final alpha = (1 - rippleProgress).clamp(0.0, 1.0);
        paint.color = color.withOpacity(alpha * 0.5);
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}
