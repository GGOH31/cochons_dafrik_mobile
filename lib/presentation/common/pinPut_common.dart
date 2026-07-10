// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_color.dart';

/// Un widget de saisie de code PIN / OTP réutilisable et personnalisé pour Cochons d'Afrik.
/// Construit sur la base du package `pinput`.
class CdaPinPut extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool autofocus;

  const CdaPinPut({
    super.key,
    required this.controller,
    this.focusNode,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    // Thème par défaut du champ PIN
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: CdaColors.encre,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CdaColors.ligne, width: 1.5),
      ),
    );

    // Thème lorsque le champ est ciblé (focus)
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: CdaColors.vertForet, width: 2.0),
      ),
    );

    // Thème lorsque la valeur est soumise / remplie
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: CdaColors.vertFonce, width: 1.5),
      ),
    );

    // Thème en cas d'erreur de validation
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: CdaColors.rouge, width: 1.5),
      ),
    );

    return Pinput(
      length: length,
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,
      validator: validator,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      onCompleted: onCompleted,
      onChanged: onChanged,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      showCursor: true,
      cursor: Center(
        child: Container(
          width: 2,
          height: 24,
          color: CdaColors.vertForet,
        ),
      ),
    );
  }
}
