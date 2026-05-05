import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mq_navigation/app/l10n/generated/app_localizations.dart';
import 'package:mq_navigation/app/router/route_names.dart';
import 'package:mq_navigation/app/theme/mq_colors.dart';
import 'package:mq_navigation/app/theme/mq_spacing.dart';
import 'package:mq_navigation/shared/widgets/mq_tactile_button.dart';
import 'package:mq_navigation/features/settings/presentation/controllers/settings_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onNext() {
    if (_currentIndex == 2) {
      ref.read(settingsControllerProvider.notifier).completeOnboarding();
      context.goNamed(RouteNames.home);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onSkip() {
    ref.read(settingsControllerProvider.notifier).completeOnboarding();
    context.goNamed(RouteNames.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    final List<Map<String, dynamic>> slides = [
      {
        'icon': Icons.map_rounded,
        'title': l10n.onboardingMapTitle,
        'body': l10n.onboardingMapBody,
      },
      {
        'icon': Icons.train_rounded,
        'title': l10n.onboardingTransitTitle,
        'body': l10n.onboardingTransitBody,
      },
      {
        'icon': Icons.security_rounded,
        'title': l10n.onboardingPrivacyTitle,
        'body': l10n.onboardingPrivacyBody,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? MqColors.charcoal850 : MqColors.alabaster,
      body: Stack(
        children: [
          if (isDark)
            PositionedDirectional(
              top: -150,
              start: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      MqColors.vividRed.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: MqSpacing.space4,
                    end: MqSpacing.space4,
                    top: MqSpacing.space2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Semantics(
                        label: 'Skip onboarding',
                        button: true,
                        child: TextButton(
                          onPressed: _onSkip,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: isDark
                                  ? MqColors.alabaster.withValues(alpha: 0.7)
                                  : MqColors.charcoal700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlideContent(slides[index], isDark, index);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: MqSpacing.space6,
                    end: MqSpacing.space6,
                    bottom: bottomPadding > 0
                        ? bottomPadding
                        : MqSpacing.space6,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Semantics(
                            label:
                                'Page ${_currentIndex + 1} of ${slides.length}',
                            child: Row(
                              children: List.generate(slides.length, (index) {
                                return Semantics(
                                  label: 'Go to slide ${index + 1}',
                                  button: true,
                                  child: GestureDetector(
                                    onTap: () => _goToPage(index),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsetsDirectional.only(
                                        end: MqSpacing.space2,
                                      ),
                                      height: 8,
                                      width: _currentIndex == index ? 24 : 8,
                                      decoration: BoxDecoration(
                                        color: _currentIndex == index
                                            ? (isDark
                                                  ? MqColors.vividRed
                                                  : MqColors.red)
                                            : Colors.grey.withValues(
                                                alpha: 0.3,
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          Semantics(
                            label: _currentIndex == slides.length - 1
                                ? 'Start using the app'
                                : 'Go to next slide',
                            button: true,
                            child: MqTactileButton(
                              onTap: _onNext,
                              child: Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: MqSpacing.space8,
                                  vertical: MqSpacing.space4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? MqColors.vividRed
                                      : MqColors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _currentIndex == slides.length - 1
                                      ? l10n.onboardingStart
                                      : l10n.onboardingNext,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideContent(
    Map<String, dynamic> slide,
    bool isDark,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(MqSpacing.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: '${slide['title']} icon',
            child: Container(
              padding: const EdgeInsetsDirectional.all(MqSpacing.space8),
              decoration: BoxDecoration(
                color: isDark ? MqColors.charcoal950 : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Icon(
                slide['icon'],
                size: 80,
                color: isDark ? MqColors.vividRed : MqColors.red,
              ),
            ),
          ),
          const SizedBox(height: 48),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: slide['title'],
                  header: true,
                  child: Text(
                    slide['title'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: slide['body'],
                  child: Text(
                    slide['body'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
