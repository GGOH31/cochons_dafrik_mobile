import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/otpValide/pages/otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/textFormField_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/file_picker_common.dart';
import 'package:cochons_dafrik_mobile/core/models/store_user_request.dart';
import 'package:cochons_dafrik_mobile/core/models/store_shop_request.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/domains/services/auth_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/showSnackBar_common.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs Utilisateur / Propriétaire
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Contrôleurs Restaurant (uniquement pour le rôle vendeur)
  final _shopNameController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  final _shopCommuneController = TextEditingController();
  final _shopAddressController = TextEditingController();

  String _selectedRole = "client"; // client ou vendeur
  PlatformFile? _logoFile;
  PlatformFile? _supportingDocsFile;
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _shopCommuneController.dispose();
    _shopAddressController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        StoreShopRequest? shopRequest;
        if (_selectedRole == "vendeur") {
          shopRequest = StoreShopRequest(
            name: _shopNameController.text.trim(),
            description: _shopDescriptionController.text.trim().isEmpty
                ? null
                : _shopDescriptionController.text.trim(),
            commune: _shopCommuneController.text.trim(),
            address: _shopAddressController.text.trim().isEmpty
                ? null
                : _shopAddressController.text.trim(),
            logoFilePath: _logoFile?.path,
            supportingDocsFilePath: _supportingDocsFile!.path!,
          );
        }

        final userRequest = StoreUserRequest(
          role: _selectedRole,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          password: _passwordController.text,
          restaurant: shopRequest,
        );

        Map<String, dynamic> response;
        if (_selectedRole == "vendeur") {
          response = await _authService.registerVendeur(userRequest);
        } else {
          response = await _authService.registerClient(userRequest);
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          final message = response['message'] ?? "Inscription réussie !";
          showCdaSnackBar(context, message);

          // Redirection vers la validation OTP
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
                  // Titre principal
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

                  // Sélection du Rôle (client / vendeur)
                  Text(
                    "Je souhaite m'inscrire en tant que :",
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Option client
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = "client";
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _selectedRole == "client"
                                  ? CdaColors.vertForet
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedRole == "client"
                                    ? CdaColors.vertForet
                                    : CdaColors.ligne,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: _selectedRole == "client"
                                      ? Colors.white
                                      : CdaColors.gris,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "client",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedRole == "client"
                                        ? Colors.white
                                        : CdaColors.encre,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Option vendeur
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = "vendeur";
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _selectedRole == "vendeur"
                                  ? CdaColors.vertForet
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedRole == "vendeur"
                                    ? CdaColors.vertForet
                                    : CdaColors.ligne,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  color: _selectedRole == "vendeur"
                                      ? Colors.white
                                      : CdaColors.gris,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "vendeur",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedRole == "vendeur"
                                        ? Colors.white
                                        : CdaColors.encre,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // SECTION 1 : INFORMATIONS PROPRIÉTAIRE / UTILISATEUR
                  if (_selectedRole == "vendeur") ...[
                    Text(
                      "Informations du propriétaire",
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CdaColors.vertFonce,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Champ Nom Complet (client ou Propriétaire)
                  CdaTextFormField(
                    controller: _nameController,
                    labelText: _selectedRole == "vendeur"
                        ? "Nom du propriétaire"
                        : "Nom complet",
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

                  // Champ E-mail
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
                        return "Numéro de téléphone invalide";
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
                        return "Veuillez entrer un mot de passe";
                      }
                      if (value.length < 6) {
                        return "Le mot de passe doit faire au moins 6 caractères";
                      }
                      return null;
                    },
                  ),

                  // SECTION 2 : INFORMATIONS BOUTIQUE (vendeur UNIQUEMENT)
                  if (_selectedRole == "vendeur") ...[
                    const SizedBox(height: 32),
                    const Divider(color: CdaColors.ligne, thickness: 1.5),
                    const SizedBox(height: 16),
                    Text(
                      "Informations de la restaurant",
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CdaColors.vertFonce,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Champ Nom de la restaurant (requis)
                    CdaTextFormField(
                      controller: _shopNameController,
                      labelText: "Nom de la restaurant",
                      hintText: "Ex: Boucherie Fine d'Abidjan",
                      prefixIcon: const Icon(
                        Icons.storefront_outlined,
                        color: CdaColors.gris,
                      ),
                      validator: (value) {
                        if (_selectedRole == "vendeur" &&
                            (value == null || value.trim().isEmpty)) {
                          return "Le nom de la restaurant est obligatoire";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Champ Description de la restaurant (facultatif)
                    CdaTextFormField(
                      controller: _shopDescriptionController,
                      labelText: "Description",
                      hintText: "Décrivez vos dishes ou spécialités...",
                      prefixIcon: const Icon(
                        Icons.description_outlined,
                        color: CdaColors.gris,
                      ),
                      minLines: 4,
                      maxLines: 8,
                      maxLength: 500,
                    ),

                    const SizedBox(height: 20),

                    // Champ Commune (requis)
                    CdaTextFormField(
                      controller: _shopCommuneController,
                      labelText: "Commune",
                      hintText: "Ex: Cocody, Marcory, Yopougon...",
                      prefixIcon: const Icon(
                        Icons.location_city_outlined,
                        color: CdaColors.gris,
                      ),
                      validator: (value) {
                        if (_selectedRole == "vendeur" &&
                            (value == null || value.trim().isEmpty)) {
                          return "La commune est obligatoire";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Champ Adresse physique / géographique (facultatif)
                    CdaTextFormField(
                      controller: _shopAddressController,
                      labelText: "Adresse physique",
                      hintText: "Ex: Boulevard Latrille, près du carrefour...",
                      prefixIcon: const Icon(
                        Icons.map_outlined,
                        color: CdaColors.gris,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logo de la restaurant (facultatif)
                    CdaFilePicker(
                      title: "Logo de la restaurant (Optionnel)",
                      subtitle: "Format image (PNG, JPG, JPEG) uniquement.",
                      fileType: FileType.image,
                      onFileSelected: (file) {
                        setState(() {
                          _logoFile = file;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Documents justificatifs (requis)
                    CdaFilePicker(
                      title: "Dossier justificatif d'activité",
                      subtitle:
                          "Registre de commerce, attestation fiscale ou CNI/Passeport. Format PDF ou Image.",
                      fileType: FileType.custom,
                      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
                      onFileSelected: (file) {
                        setState(() {
                          _supportingDocsFile = file;
                        });
                      },
                      validator: (value) {
                        if (_selectedRole == "vendeur" && value == null) {
                          return "Veuillez joindre votre dossier d'activité pour finaliser l'inscription vendeur";
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 36),

                  // Bouton Inscription
                  CdaElevatedButton(
                    text: "S'inscrire",
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 24),

                  // Redirection Connexion
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
