import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/client_service.dart';

class AdressFormPage extends StatefulWidget {
  final Map<String, dynamic>? address;

  const AdressFormPage({super.key, this.address});

  @override
  State<AdressFormPage> createState() => _AdressFormPageState();
}

class _AdressFormPageState extends State<AdressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ClientService _clientService = ClientService();

  late TextEditingController _labelController;
  late TextEditingController _communeController;
  late TextEditingController _detailsController;
  late TextEditingController _latController;
  late TextEditingController _lonController;

  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?['label'] ?? '');
    _communeController = TextEditingController(text: widget.address?['commune'] ?? '');
    _detailsController = TextEditingController(text: widget.address?['details'] ?? '');
    _latController = TextEditingController(text: widget.address?['latitude']?.toString() ?? '');
    _lonController = TextEditingController(text: widget.address?['longitude']?.toString() ?? '');
    _isDefault = widget.address?['is_default'] == true || widget.address?['is_default'] == 1;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _communeController.dispose();
    _detailsController.dispose();
    _latController.dispose();
    _lonController.dispose();
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
      'label': _labelController.text.trim(),
      'commune': _communeController.text.trim(),
      'details': _detailsController.text.trim(),
      'is_default': _isDefault ? 1 : 0,
    };

    final latText = _latController.text.trim();
    if (latText.isNotEmpty) {
      data['latitude'] = double.tryParse(latText);
    }

    final lonText = _lonController.text.trim();
    if (lonText.isNotEmpty) {
      data['longitude'] = double.tryParse(lonText);
    }

    try {
      if (widget.address != null) {
        // Edit mode
        final String id = widget.address!['id'].toString();
        await _clientService.updateAddress(id, data);
      } else {
        // Add mode
        await _clientService.addAddress(data);
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address != null 
                ? "Adresse modifiée avec succès !" 
                : "Adresse ajoutée avec succès !"
            ),
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
    final isEditing = widget.address != null;

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          isEditing ? "Modifier l'Adresse" : "Ajouter une Adresse",
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
              // Label
              _buildLabel("Label de l'adresse"),
              TextFormField(
                controller: _labelController,
                decoration: _buildInputDecoration("Ex: Domicile, Bureau, Maison de maman"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Veuillez donner un nom à cette adresse.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Commune
              _buildLabel("Commune"),
              TextFormField(
                controller: _communeController,
                decoration: _buildInputDecoration("Ex: Cocody, Yopougon, Marcory"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Veuillez préciser la commune.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Details
              _buildLabel("Indications & détails (Requis)"),
              TextFormField(
                controller: _detailsController,
                maxLines: 3,
                decoration: _buildInputDecoration("Ex: Cité des Arts, bâtiment D, porte 12. Face à la boutique de fruits."),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Les indications et détails d'adresse sont obligatoires.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // GPS Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Latitude (Optionnel)"),
                        TextFormField(
                          controller: _latController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        _buildLabel("Longitude (Optionnel)"),
                        TextFormField(
                          controller: _lonController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _buildInputDecoration("Ex: -4.0305"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Default Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            "Définir par défaut",
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CdaColors.encre,
                            ),
                          ),
                          Text(
                            "Cette adresse sera sélectionnée en priorité lors de vos commandes.",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: CdaColors.gris,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isDefault,
                      activeColor: CdaColors.vertForet,
                      onChanged: (val) {
                        setState(() {
                          _isDefault = val;
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          isEditing ? "Enregistrer les modifications" : "Ajouter l'adresse",
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
