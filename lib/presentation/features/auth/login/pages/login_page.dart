// ignore_for_file: deprecated_member_use
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/textFormField_common.dart';
import 'package:cochons_dafrik_mobile/core/models/login_request.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/domains/services/auth_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/showSnackBar_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/register/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = LoginRequest(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
        
        final payload = await _authService.login(request);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          showCdaSnackBar(context, 'Connexion réussie !');

          // Rediriger vers l'écran d'accueil approprié selon le rôle
          final user = payload['user'];
          final role = user != null ? user['role'] : 'client';
          
          if (role == 'vendeur') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.homeVendeur,
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.homeClient,
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          showCdaSnackBar(
            context,
            e.toString().replaceAll('Exception: ', ''),
            isError: true,
          );
        }
      }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
  
                  // En-tête de la marque
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 40,
                          height: 40,
                          color: CdaColors.vertForet.withOpacity(0.1),
                          child: Center(
                            child: Image.asset(
                              "assets/images/logo.png",
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Cochons d'Afrik",
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: CdaColors.vertForet,
                        ),
                      ),
                    ],
                  ),
  
                  const SizedBox(height: 36),
  
                  // Titre
                  Text(
                    "Bon retour !",
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Connectez-vous pour accéder à votre espace sécurisé.",
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: CdaColors.gris,
                    ),
                  ),
  
                  const SizedBox(height: 36),
  
                  // Champ Téléphone
                  CdaTextFormField(
                    controller: _phoneController,
                    labelText: "Numéro de téléphone",
                    hintText: "Ex: 0707070707",
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: CdaColors.gris,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Veuillez entrer votre numéro de téléphone";
                      }
                      if (value.trim().length < 8) {
                        return "Le numéro de téléphone est trop court";
                      }
                      return null;
                    },
                  ),
  
                  const SizedBox(height: 20),
  
                  // Champ Mot de passe
                  CdaTextFormField(
                    controller: _passwordController,
                    labelText: "Mot de passe",
                    hintText: "••••••••",
                    isPassword: true,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: CdaColors.gris,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer votre mot de passe";
                      }
                      if (value.length < 6) {
                        return "Le mot de passe doit contenir au moins 6 caractères";
                      }
                      return null;
                    },
                  ),
  
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.forgetPassword);
                      },
                      child: Text(
                        "Mot de passe oublié ?",
                        style: GoogleFonts.nunito(
                          color: CdaColors.vertForet,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 24),
  
                  // Bouton Connexion
                  CdaElevatedButton(
                    text: "Se connecter",
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
  
                  const SizedBox(height: 24),
  
                  // Redirection Inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Nouveau sur la plateforme ? ",
                        style: GoogleFonts.nunito(
                          color: CdaColors.gris,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          "S'inscrire",
                          style: GoogleFonts.nunito(
                            color: CdaColors.vertForet,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
