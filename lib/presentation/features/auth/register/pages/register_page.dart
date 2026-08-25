import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/otpValide/pages/otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/textFormField_common.dart';
import 'package:cochons_dafrik_mobile/core/models/store_user_request.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/domains/services/auth_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/showSnackBar_common.dart';

/// Inscription client uniquement : les comptes vendeurs sont créés par
/// l'administration (avec leur boutique), pas par inscription directe.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
        final userRequest = StoreUserRequest(
          role: "client",
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          password: _passwordController.text,
        );

        final response = await _authService.registerClient(userRequest);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          final message = response['message'] ?? "Inscription réussie !";
          showCdaSnackBar(context, message);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OtpPage(phoneNumber: _phoneController.text.trim()),
            ),
          );
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
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Créer un compte",
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rejoignez la première plateforme de viande porcine.",
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: CdaColors.gris,
                    ),
                  ),

                  const SizedBox(height: 28),

                  CdaTextFormField(
                    controller: _nameController,
                    labelText: "Nom complet",
                    hintText: "Ex: Jean Koffi",
                    prefixIcon: const Icon(
                      Icons.person_outlined,
                      color: CdaColors.gris,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Le nom complet est obligatoire";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  CdaTextFormField(
                    controller: _emailController,
                    labelText: "Adresse e-mail",
                    hintText: "Ex: contact@email.com",
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: CdaColors.gris,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Veuillez entrer votre adresse e-mail";
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return "Adresse e-mail invalide";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

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
                        return "Numéro de téléphone invalide";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

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
                        return "Veuillez entrer un mot de passe";
                      }
                      if (value.length < 6) {
                        return "Le mot de passe doit faire au moins 6 caractères";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 36),

                  CdaElevatedButton(
                    text: "S'inscrire",
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Déjà inscrit ? ",
                        style: GoogleFonts.nunito(
                          color: CdaColors.gris,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: Text(
                          "Se connecter",
                          style: GoogleFonts.nunito(
                            color: CdaColors.vertForet,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
