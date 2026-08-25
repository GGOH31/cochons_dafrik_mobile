// ignore_for_file: deprecated_member_use
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      title: "Cochons d'Afrik",
      description:
          "La première marketplace porcine de Côte d'Ivoire. Qualité, traçabilité et sécurité garanties de la ferme à votre assiette.",
      icon: Icons.storefront_outlined,
    ),
    const OnboardingSlide(
      title: "Paiement Séquestre",
      description:
          "Commandez et payez en toute sécurité. Vos fonds sont sécurisés et ne sont versés au vendeur qu'après confirmation de votre livraison.",
      icon: Icons.shield_outlined,
    ),
    const OnboardingSlide(
      title: "Marché B2C & B2B",
      description:
          "Que vous soyez un consommateur final ou un restaurant s'approvisionnant chez des grossistes, accédez à des dishes frais en quelques clics.",
      icon: Icons.business_center_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding(String routeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_onboarding', false);
    if (mounted) {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: CdaColors.creme,
        body: SafeArea(
          child: Column(
            children: [
              // Bouton passer
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        _slides.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      "Passer",
                      style: GoogleFonts.nunito(
                        color: CdaColors.vertForet,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Slider
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icône stylisée
                          ClipOval(
                            child: Container(
                              width: 140,
                              height: 140,
                              color: CdaColors.vertForet.withOpacity(0.1),
                              child: Center(
                                child: Image.asset(
                                  "assets/images/logo.png",
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Titre
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: CdaColors.encre,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: CdaColors.gris,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Indicateurs de page (points)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? CdaColors.vertForet
                          : CdaColors.ligne,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Actions (Boutons Connexion / Inscription)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    CdaElevatedButton(
                      text: "S'inscrire",
                      onPressed: () => _completeOnboarding(AppRoutes.register),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => _completeOnboarding(AppRoutes.login),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: CdaColors.vertForet,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "Se connecter",
                          style: GoogleFonts.nunito(
                            color: CdaColors.vertForet,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          _completeOnboarding(AppRoutes.homeClient),
                      child: Text(
                        "Continuer sans compte",
                        style: GoogleFonts.nunito(
                          color: CdaColors.gris,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}
