import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/login/pages/login_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/register/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/themes/app_theme.dart';
import 'presentation/features/onBoarding/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('show_onboarding') ?? true;
  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cochons d'Afrik",
      debugShowCheckedModeBanner: false,
      theme: cdaTheme(),
      initialRoute: showOnboarding ? AppRoutes.onBoarding : AppRoutes.login,
      routes: {
        AppRoutes.onBoarding: (context) => const OnboardingPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
      },
    );
  }
}
