import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/onboarding_provider.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

class _PageData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const _PageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}

const _pages = [
  _PageData(
    title: 'Manage Your Store',
    description:
        'Take full control of your products, inventory, and shop settings from one powerful dashboard.',
    icon: Icons.storefront_rounded,
    gradientColors: [AppColors.primary, AppColors.secondary],
  ),
  _PageData(
    title: 'Reach Nearby Customers',
    description:
        'List your shop on the map and get discovered by customers in your area looking for exactly what you sell.',
    icon: Icons.location_on_rounded,
    gradientColors: [AppColors.secondary, AppColors.tertiary],
  ),
  _PageData(
    title: 'Grow Your Business',
    description:
        'Access detailed analytics and insights to scale your vendor business smarter and faster.',
    icon: Icons.trending_up_rounded,
    gradientColors: [AppColors.tertiary, AppColors.primary],
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<AnimationController> _floatControllers;

  @override
  void initState() {
    super.initState();
    _floatControllers = List.generate(
      _pages.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 2200 + i * 300),
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _floatControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    await ref.read(onboardingNotifierProvider.notifier).markSeen();
    if (mounted) context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isDarkModeProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Pages
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) => isTablet
                  ? _TabletPage(
                      data: _pages[i],
                      floatController: _floatControllers[i],
                    )
                  : _MobilePage(
                      data: _pages[i],
                      floatController: _floatControllers[i],
                    ),
            ),

            // Skip button
            if (_currentPage < _pages.length - 1)
              Positioned(
                top: 12,
                right: 16,
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomControls(
                currentPage: _currentPage,
                total: _pages.length,
                accentColor: _pages[_currentPage].gradientColors.first,
                isLast: _currentPage == _pages.length - 1,
                gradientColors: _pages[_currentPage].gradientColors,
                onNext: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile layout: illustration top, text + controls bottom
// ---------------------------------------------------------------------------

class _MobilePage extends StatelessWidget {
  final _PageData data;
  final AnimationController floatController;

  const _MobilePage({required this.data, required this.floatController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          flex: 10,
          child: _IllustrationWidget(
            data: data,
            floatController: floatController,
            availableSize: Size(size.width, size.height * 0.52),
          ),
        ),
        Expanded(
          flex: 7,
          child: _TextContent(data: data, isTablet: false),
        ),
        // space for bottom controls overlay
        const SizedBox(height: 110),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet layout: illustration left, text right
// ---------------------------------------------------------------------------

class _TabletPage extends StatelessWidget {
  final _PageData data;
  final AnimationController floatController;

  const _TabletPage({required this.data, required this.floatController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Expanded(
          child: _IllustrationWidget(
            data: data,
            floatController: floatController,
            availableSize: Size(size.width * 0.5, size.height),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TextContent(data: data, isTablet: true),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Illustration
// ---------------------------------------------------------------------------

class _IllustrationWidget extends StatelessWidget {
  final _PageData data;
  final AnimationController floatController;
  final Size availableSize;

  const _IllustrationWidget({
    required this.data,
    required this.floatController,
    required this.availableSize,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = availableSize.shortestSide * 0.68;

    return AnimatedBuilder(
      animation: floatController,
      builder: (context, _) {
        final t = floatController.value;
        final float = math.sin(t * math.pi) * 10.0;

        return SizedBox(
          width: availableSize.width,
          height: availableSize.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outermost faint glow ring
              Transform.translate(
                offset: Offset(0, float * 0.4),
                child: Container(
                  width: circleSize * 1.35,
                  height: circleSize * 1.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        data.gradientColors.first.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Decorative floating blobs
              _FloatingBlob(
                size: circleSize * 0.22,
                color: data.gradientColors.last.withValues(alpha: 0.18),
                offset: Offset(
                  circleSize * 0.52 * math.cos(t * math.pi * 2),
                  circleSize * 0.38 * math.sin(t * math.pi * 2 + 1),
                ),
              ),
              _FloatingBlob(
                size: circleSize * 0.14,
                color: data.gradientColors.first.withValues(alpha: 0.22),
                offset: Offset(
                  -circleSize * 0.45 * math.cos(t * math.pi * 2 + 0.7),
                  circleSize * 0.40 * math.sin(t * math.pi * 2 + 2),
                ),
              ),
              _FloatingBlob(
                size: circleSize * 0.10,
                color: data.gradientColors.last.withValues(alpha: 0.28),
                offset: Offset(
                  circleSize * 0.30 * math.cos(t * math.pi * 2 + 2.2),
                  -circleSize * 0.50 * math.sin(t * math.pi * 2 + 0.5),
                ),
              ),

              // Main gradient circle
              Transform.translate(
                offset: Offset(0, float),
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        data.gradientColors.first.withValues(alpha: 0.22),
                        data.gradientColors.last.withValues(alpha: 0.14),
                      ],
                    ),
                    border: Border.all(
                      color: data.gradientColors.first.withValues(alpha: 0.30),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            data.gradientColors.first.withValues(alpha: 0.12),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              // Inner accent ring
              Transform.translate(
                offset: Offset(0, float * 0.8),
                child: Container(
                  width: circleSize * 0.68,
                  height: circleSize * 0.68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: data.gradientColors.last.withValues(alpha: 0.20),
                      width: 1.0,
                    ),
                  ),
                ),
              ),

              // Icon
              Transform.translate(
                offset: Offset(0, float),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: data.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Icon(
                    data.icon,
                    size: circleSize * 0.38,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingBlob extends StatelessWidget {
  final double size;
  final Color color;
  final Offset offset;

  const _FloatingBlob({
    required this.size,
    required this.color,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Text content
// ---------------------------------------------------------------------------

class _TextContent extends StatelessWidget {
  final _PageData data;
  final bool isTablet;

  const _TextContent({required this.data, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            isTablet ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            data.title,
            textAlign: isTablet ? TextAlign.left : TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isTablet ? 34 : 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: isTablet ? TextAlign.left : TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isTablet ? 17 : 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom controls
// ---------------------------------------------------------------------------

class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int total;
  final Color accentColor;
  final bool isLast;
  final List<Color> gradientColors;
  final VoidCallback onNext;

  const _BottomControls({
    required this.currentPage,
    required this.total,
    required this.accentColor,
    required this.isLast,
    required this.gradientColors,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0.0),
            AppColors.background.withValues(alpha: 0.96),
            AppColors.background,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dot indicators
          Row(
            children: List.generate(total, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? accentColor
                      : AppColors.border,
                ),
              );
            }),
          ),

          // Next / Get Started button
          GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 52,
              padding: EdgeInsets.symmetric(
                horizontal: isLast ? 28 : 0,
              ),
              width: isLast ? null : 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isLast ? 14 : 26),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: isLast
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Get Started',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    )
                  : const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
