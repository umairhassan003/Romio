import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildPage(
                imageUrl: 'images/onboarding1.jpg',
                title: 'Reserva',
                subtitle: 'Encuentra las mejores opciones para ti.',
              ),
              _buildPage(
                imageUrl: 'images/onboarding2.jpg',
                title: 'Pagos 100% seguros',
                subtitle: 'Paga con confianza en nuestra plataforma.',
              ),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? AppColors.primaryBurgundy 
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == 0) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBurgundy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      _currentPage == 0 
                          ? l10n?.onboardingNext ?? 'Siguiente' 
                          : l10n?.onboardingStart ?? 'Empezar',
                      style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPage({required String imageUrl, required String title, required String subtitle}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imageUrl,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.3),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.headingXL.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: AppTextStyles.bodyL.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 120), // Space for button and dots
            ],
          ),
        ),
      ],
    );
  }
}
