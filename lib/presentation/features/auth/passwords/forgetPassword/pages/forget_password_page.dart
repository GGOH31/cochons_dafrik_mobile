import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/presentation/common/textFormField_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/domains/services/auth_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/showSnackBar_common.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final phone = _phoneController.text.trim();

      try {
        await _authService.forgotPassword(phone);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          showCdaSnackBar(context, "Code OTP de réinitialisation envoyé !");

          // Naviguer vers la page de réinitialisation en passant le numéro de téléphone en argument
          Navigator.pushNamed(
            context,
            AppRoutes.resetPassword,
            arguments: phone,
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
                  const SizedBox(height: 20),

                  // Titre
                  Text(
                    "Mot de passe oublié",
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Entrez votre numéro de téléphone pour recevoir le code OTP de réinitialisation de votre mot de passe.",
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: CdaColors.gris,
                      height: 1.5,
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

                  const SizedBox(height: 40),

                  // Bouton Envoyer
                  CdaElevatedButton(
                    text: "Envoyer le code",
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
