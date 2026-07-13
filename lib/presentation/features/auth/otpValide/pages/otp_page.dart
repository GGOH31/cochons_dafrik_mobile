// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/pinPut_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/domains/services/auth_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/showSnackBar_common.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  // ... (omitting intermediate state lines for target content stability)

  bool _isLoading = false;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 300;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final msg = await _authService.sendOtp(widget.phoneNumber);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        showCdaSnackBar(context, msg);
        _startTimer();
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

  void _verifyOtp(String otp) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final payload = await _authService.verifyOtp(widget.phoneNumber, otp);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          showCdaSnackBar(context, "Code vérifié avec succès !");

          final user = payload['user'];
          final role = user != null ? user['role'] : 'client';

          Navigator.pushReplacementNamed(context, AppRoutes.login);

          // if (role == 'vendeur') {
          //   Navigator.pushNamedAndRemoveUntil(
          //     context,
          //     AppRoutes.homeVendeur,
          //     (route) => false,
          //   );
          // } else {
          //   Navigator.pushNamedAndRemoveUntil(
          //     context,
          //     AppRoutes.homeClient,
          //     (route) => false,
          //   );
          // }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          _pinController.clear();
          _focusNode.requestFocus();

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Illustration / Logo
                  ClipOval(
                    child: Container(
                      width: 100,
                      height: 100,
                      color: CdaColors.vertForet.withOpacity(0.1),
                      child: Center(
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Titre
                  Text(
                    "Vérification du code",
                    style: GoogleFonts.fredoka(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: CdaColors.gris,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                "Veuillez entrer le code de validation à 6 chiffres envoyé au ",
                          ),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: CdaColors.encre,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Pinput
                  CdaPinPut(
                    controller: _pinController,
                    focusNode: _focusNode,
                    length: 6,
                    onCompleted: _verifyOtp,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "Veuillez saisir le code complet à 6 chiffres";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Resend Timer / Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Vous n'avez rien reçu ? ",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: CdaColors.gris,
                        ),
                      ),
                      _canResend
                          ? GestureDetector(
                              onTap: _resendCode,
                              child: Text(
                                "Renvoyer le code",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: CdaColors.vertForet,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              "Renvoyer dans ${_secondsRemaining}s",
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: CdaColors.encre,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Verify Button
                  CdaElevatedButton(
                    text: "Vérifier",
                    isLoading: _isLoading,
                    onPressed: () => _verifyOtp(_pinController.text),
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
