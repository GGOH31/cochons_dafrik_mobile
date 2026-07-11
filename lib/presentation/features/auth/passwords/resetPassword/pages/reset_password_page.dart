import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/presentation/common/textFormField_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/pinPut_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/domains/services/auth_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/showSnackBar_common.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _phone = "";
  final _authService = AuthService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _phone = args;
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_pinController.text.length < 6) {
        showCdaSnackBar(context, "Veuillez saisir le code complet à 6 chiffres.", isError: true);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.resetPassword(
          phone: _phone,
          code: _pinController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          showCdaSnackBar(context, "Votre mot de passe a été réinitialisé !");

          // Redirection vers la page de login
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: CdaColors.encre),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Titre
                  Text(
                    "Nouveau mot de passe",
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Veuillez saisir le code OTP reçu et configurer votre nouveau mot de passe.",
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: CdaColors.gris,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Code OTP (6 chiffres)
                  Text(
                    "Code de validation OTP",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: CdaPinPut(
                      controller: _pinController,
                      focusNode: _focusNode,
                      length: 6,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Veuillez saisir le code complet à 6 chiffres";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Nouveau mot de passe
                  CdaTextFormField(
                    controller: _passwordController,
                    labelText: "Nouveau mot de passe",
                    hintText: "••••••••",
                    isPassword: true,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: CdaColors.gris,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer le mot de passe";
                      }
                      if (value.length < 6) {
                        return "Le mot de passe doit contenir au moins 6 caractères";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Confirmation du nouveau mot de passe
                  CdaTextFormField(
                    controller: _confirmPasswordController,
                    labelText: "Confirmer le mot de passe",
                    hintText: "••••••••",
                    isPassword: true,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: CdaColors.gris,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez confirmer votre mot de passe";
                      }
                      if (value != _passwordController.text) {
                        return "Les mots de passe ne correspondent pas";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Bouton Enregistrer
                  CdaElevatedButton(
                    text: "Enregistrer",
                    isLoading: _isLoading,
                    onPressed: _submit,
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
