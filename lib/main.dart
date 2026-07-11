import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/login/pages/login_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/register/pages/register_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/home_client/pages/home_client_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/product_client/pages/product_client_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/shops/pages/shops_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/product_detail_client/pages/product_detail_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/home_vendeur/pages/home_vendeur_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/passwords/forgetPassword/pages/forget_password_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/passwords/resetPassword/pages/reset_password_page.dart';
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
        AppRoutes.homeClient: (context) => const HomeClientPage(),
        AppRoutes.productClient: (context) => const ProductClientPage(),
        AppRoutes.shops: (context) => const ShopsPage(),
        AppRoutes.productDetail: (context) => const ProductDetailPage(),
        AppRoutes.homeVendeur: (context) => const HomeVendeurPage(),
        AppRoutes.forgetPassword: (context) => const ForgetPasswordPage(),
        AppRoutes.resetPassword: (context) => const ResetPasswordPage(),
      },
    );
  }
}
