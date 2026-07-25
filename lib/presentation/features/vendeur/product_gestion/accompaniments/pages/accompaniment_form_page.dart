import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/file_picker_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';

class AccompanimentFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialAccompaniment;

  const AccompanimentFormPage({super.key, this.initialAccompaniment});

  @override
  State<AccompanimentFormPage> createState() => _AccompanimentFormPageState();
}

class _AccompanimentFormPageState extends State<AccompanimentFormPage> {
  final VendeurService _vendeurService = VendeurService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  String? _selectedProductId;
  PlatformFile? _pickedFile;

  List<dynamic> _products = [];
  bool _isLoading = false;
  bool _isProductsLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialAccompaniment?["name"] ?? "",
    );
    _priceController = TextEditingController(
      text: widget.initialAccompaniment?["prix_unit"]?.toString() ?? "",
    );
    _selectedProductId = widget.initialAccompaniment?["dish_id"]?.toString();
    _loadProducts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final prods = await _vendeurService.getProducts();
      setState(() {
        _products = prods;
        _isProductsLoading = false;

        // If editing and selected dish is not empty, ensure it's still in the dish list, or fallback
        if (_selectedProductId != null) {
          final exists = prods.any((p) => p['id'].toString() == _selectedProductId);
          if (!exists) {
            _selectedProductId = null;
          }
        }
      });
    } catch (e) {
      setState(() {
        _isProductsLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors du chargement des dishes : $e"),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez associer cet accompagnement à un dish."),
          backgroundColor: CdaColors.rouge,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> fields = {
      'dish_id': _selectedProductId,
      'name': _nameController.text.trim(),
      'prix_unit': int.tryParse(_priceController.text.trim()) ?? 0,
    };

    if (widget.initialAccompaniment != null) {
      fields['_method'] = 'PUT';
    }

    if (_pickedFile != null && _pickedFile!.path != null) {
      final fileName = _pickedFile!.name;
      final fileKey = (widget.initialAccompaniment != null) ? 'photo_url' : 'photo_file';
      fields[fileKey] = await dio_pkg.MultipartFile.fromFile(
        _pickedFile!.path!,
        filename: fileName,
      );
    }

    final formData = dio_pkg.FormData.fromMap(fields);

    try {
      if (widget.initialAccompaniment != null) {
        await _vendeurService.updateAccompaniment(
          widget.initialAccompaniment!['id'].toString(),
          formData,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Accompagnement modifié avec succès !"),
              backgroundColor: CdaColors.vertForet,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        await _vendeurService.createAccompaniment(formData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Accompagnement créé avec succès !"),
              backgroundColor: CdaColors.vertForet,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la sauvegarde : $e"),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirmation",
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: const Text("Voulez-vous vraiment supprimer cet accompagnement ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Annuler",
              style: GoogleFonts.nunito(color: CdaColors.gris),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Supprimer",
              style: GoogleFonts.nunito(
                color: CdaColors.rouge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _vendeurService.deleteAccompaniment(
        widget.initialAccompaniment!['id'].toString(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Accompagnement supprimé."),
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
            content: Text("Erreur lors de la suppression : $e"),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialAccompaniment != null;

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          isEdit ? "Modifier l'accompagnement" : "Ajouter un accompagnement",
          style: GoogleFonts.fredoka(
            color: CdaColors.encre,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: CdaColors.encre),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isProductsLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CdaColors.vertForet),
              ),
            )
          : _products.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "⚠️",
                          style: TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Vous devez d'abord créer au moins un dish pour pouvoir lui ajouter des accompagnements.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: CdaColors.encre,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CdaColors.vertForet,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Retour",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Photo picker
                              Center(
                                child: Column(
                                  children: [
                                    if (isEdit &&
                                        widget.initialAccompaniment!['photo_url'] != null &&
                                        _pickedFile == null)
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: CdaColors.ligne),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.network(
                                            widget.initialAccompaniment!['photo_url'],
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  width: 120,
                                                  height: 120,
                                                  color: CdaColors.vertForet.withOpacity(0.08),
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 40,
                                                    color: CdaColors.gris,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    CdaFilePicker(
                                      title: "Photo de l'accompagnement",
                                      subtitle: "Format JPG, PNG (Max 5Mo)",
                                      fileType: FileType.image,
                                      allowedExtensions: const ['jpg', 'jpeg', 'png'],
                                      onFileSelected: (file) {
                                        setState(() {
                                          _pickedFile = file;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Dish Association Dropdown
                              Text(
                                "Associer au dish *",
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CdaColors.encre,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedProductId,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: GoogleFonts.nunito(
                                  color: CdaColors.encre,
                                  fontSize: 15,
                                ),
                                hint: const Text("Sélectionnez un dish"),
                                items: _products.map((prod) {
                                  return DropdownMenuItem<String>(
                                    value: prod['id'].toString(),
                                    child: Text(prod['name'] ?? ''),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProductId = value;
                                  });
                                },
                                validator: (value) =>
                                    value == null ? "Ce champ est requis" : null,
                              ),
                              const SizedBox(height: 20),

                              // Name
                              Text(
                                "Nom de l'accompagnement *",
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CdaColors.encre,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: "Ex: Frites de plantain",
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: GoogleFonts.nunito(
                                  color: CdaColors.encre,
                                  fontSize: 15,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Ce champ est requis";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Unit Price
                              Text(
                                "Prix unitaire (FCFA) *",
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CdaColors.encre,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Ex: 500",
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: GoogleFonts.nunito(
                                  color: CdaColors.encre,
                                  fontSize: 15,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Ce champ est requis";
                                  }
                                  if (int.tryParse(value) == null) {
                                    return "Veuillez entrer un nombre valide";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),

                              // Save Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CdaColors.vertForet,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    isEdit ? "Enregistrer les modifications" : "Créer l'accompagnement",
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                              // Delete Button if Editing
                              if (isEdit) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: _delete,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: CdaColors.rouge),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "Supprimer l'accompagnement",
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.bold,
                                        color: CdaColors.rouge,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CdaColors.vertForet),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
