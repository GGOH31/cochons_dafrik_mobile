// ignore_for_file: file_names, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_color.dart';

/// Un champ de saisie de texte personnalisé réutilisable pour Cochons d'Afrik.
/// Il prend en charge l'obscurcissement du texte (mot de passe avec bouton œil),
/// les icônes de préfixe/suffixe, la validation et les styles personnalisés cohérents.
class CdaTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;

  const CdaTextFormField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.onChanged,
    this.initialValue,
    this.enabled = true,
    this.minLines,
    this.maxLines,
    this.maxLength,
  });

  @override
  State<CdaTextFormField> createState() => _CdaTextFormFieldState();
}

class _CdaTextFormFieldState extends State<CdaTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      minLines: widget.isPassword ? 1 : widget.minLines,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      style: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: CdaColors.encre,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        labelStyle: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: CdaColors.gris,
        ),
        floatingLabelStyle: GoogleFonts.fredoka(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: CdaColors.vertForet,
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: CdaColors.gris.withOpacity(0.6),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: CdaColors.gris,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CdaColors.ligne, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CdaColors.vertForet, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CdaColors.rouge, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CdaColors.rouge, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: CdaColors.ligne.withOpacity(0.5),
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
