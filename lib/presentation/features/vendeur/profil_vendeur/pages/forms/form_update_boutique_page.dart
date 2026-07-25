import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/file_picker_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';

class FormUpdateBoutiquePage extends StatefulWidget {
  final Map<String, dynamic>? restaurant;

  const FormUpdateBoutiquePage({super.key, this.restaurant});

  @override
  State<FormUpdateBoutiquePage> createState() => _FormUpdateBoutiquePageState();
}

class _FormUpdateBoutiquePageState extends State<FormUpdateBoutiquePage> {
  final _formKey = GlobalKey<FormState>();
  final VendeurService _vendeurService = VendeurService();

  late TextEditingController _descController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lonController;
  late TextEditingController _deliveryFeeController;
  late TextEditingController _minOrderController;
  late TextEditingController _deliveryZoneController;

  bool _isOpen = false;
  bool _isLoading = false;
  PlatformFile? _pickedLogo;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(
      text: widget.restaurant?['description'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.restaurant?['address'] ?? '',
    );
    _latController = TextEditingController(
      text: widget.restaurant?['latitude']?.toString() ?? '',
    );
    _lonController = TextEditingController(
      text: widget.restaurant?['longitude']?.toString() ?? '',
    );
    _deliveryFeeController = TextEditingController(
      text: widget.restaurant?['delivery_fee_fcfa']?.toString() ?? '',
    );
    _minOrderController = TextEditingController(
      text: widget.restaurant?['min_order_fcfa']?.toString() ?? '',
    );
    _deliveryZoneController = TextEditingController(
      text: widget.restaurant?['delivery_zone'] ?? '',
    );
    _isOpen = widget.restaurant?['is_open'] ?? false;
  }

  @override
  void dispose() {
    _descController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _deliveryFeeController.dispose();
    _minOrderController.dispose();
    _deliveryZoneController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> data = {
      'description': _descController.text.trim(),
      'address': _addressController.text.trim(),
      'delivery_zone': _deliveryZoneController.text.trim(),
      'is_open': _isOpen ? 1 : 0,
    };

    final latText = _latController.text.trim();
    if (latText.isNotEmpty) {
      data['latitude'] = double.tryParse(latText);
    }

    final lonText = _lonController.text.trim();
    if (lonText.isNotEmpty) {
      data['longitude'] = double.tryParse(lonText);
    }

    final feeText = _deliveryFeeController.text.trim();
    if (feeText.isNotEmpty) {
      data['delivery_fee_fcfa'] = int.tryParse(feeText) ?? 0;
    }

    final minOrderText = _minOrderController.text.trim();
    if (minOrderText.isNotEmpty) {
      data['min_order_fcfa'] = int.tryParse(minOrderText) ?? 0;
    }

    try {
      await _vendeurService.updateShopInfo(data, logoPath: _pickedLogo?.path);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Restaurant mise à jour avec succès !"),
            backgroundColor: CdaColors.vertForet,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : $e"),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentLogoUrl = widget.restaurant?['logo_url'] ?? '';

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          "Modifier la Restaurant",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CdaColors.encre),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo view / Picker
              Center(
                child: Column(
                  children: [
                    if (currentLogoUrl.isNotEmpty && _pickedLogo == null) ...[
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CdaColors.ligne,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            currentLogoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    CdaFilePicker(
                      title: "Nouveau Logo",
                      subtitle:
                          "Remplace le logo actuel par une nouvelle image.",
                      fileType: FileType.image,
                      onFileSelected: (file) {
                        setState(() {
                          _pickedLogo = file;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Description
              _buildLabel("Description de la restaurant"),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _buildInputDecoration("Entrez la description..."),
                validator: (val) {
                  if (val != null && val.length > 500) {
                    return "La description ne doit pas dépasser 500 caractères.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              _buildLabel("Adresse physique"),
              TextFormField(
                controller: _addressController,
                decoration: _buildInputDecoration(
                  "Ex: Face à la pharmacie Bel Horizon",
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Zone
              _buildLabel("Zone de livraison"),
              TextFormField(
                controller: _deliveryZoneController,
                decoration: _buildInputDecoration(
                  "Ex: Yopougon, Cocody, Plateau",
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Fee and Minimum Order Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Frais de Livr. (FCFA)"),
                        TextFormField(
                          controller: _deliveryFeeController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration("Ex: 1000"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Min. Commande (FCFA)"),
                        TextFormField(
                          controller: _minOrderController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration("Ex: 3000"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // GPS Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Latitude"),
                        TextFormField(
                          controller: _latController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _buildInputDecoration("Ex: 5.3484"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Longitude"),
                        TextFormField(
                          controller: _lonController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _buildInputDecoration("Ex: -4.0305"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Restaurant ouverte",
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CdaColors.encre,
                            ),
                          ),
                          Text(
                            "Rendre la restaurant visible et prête à recevoir des commandes",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: CdaColors.gris,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOpen,
                      activeColor: CdaColors.vertForet,
                      onChanged: (val) {
                        setState(() {
                          _isOpen = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CdaColors.vertForet,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Text(
                          "Enregistrer les modifications",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        labelText,
        style: GoogleFonts.fredoka(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: CdaColors.encre,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: CdaColors.gris.withOpacity(0.6)),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
