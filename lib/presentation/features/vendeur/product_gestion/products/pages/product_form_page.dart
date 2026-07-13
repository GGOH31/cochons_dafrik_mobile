import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/file_picker_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';

class ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialProduct;
  final String? shopId;

  const ProductFormPage({super.key, this.initialProduct, this.shopId});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final VendeurService _vendeurService = VendeurService();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _prepMinutesController;
  late TextEditingController _stockController;

  bool _isOnline = true;
  int? _selectedCategoryId;
  String _selectedUnit = "portion";
  final List<String> _units = ["portion", "kg", "canette", "bouteille"];
  List<dynamic> _categories = [];
  bool _isLoading = false;
  PlatformFile? _pickedFile;
  String? _shopId;



  @override
  void initState() {
    super.initState();
    _shopId = widget.shopId;
    _loadCategories();
    _loadShopId();

    if (widget.initialProduct != null) {
      _nameController = TextEditingController(
        text: widget.initialProduct!["name"] ?? "",
      );
      _priceController = TextEditingController(
        text: widget.initialProduct!["price_fcfa"]?.toString() ?? "",
      );
      _descController = TextEditingController(
        text: widget.initialProduct!["description"] ?? "",
      );
      _prepMinutesController = TextEditingController(
        text: widget.initialProduct!["prep_minutes"]?.toString() ?? "15",
      );
      _isOnline = widget.initialProduct!["is_active"] ?? true;
      _selectedCategoryId = widget.initialProduct!["category_id"];
      _selectedUnit = widget.initialProduct!["unit"] ?? "portion";
      _stockController = TextEditingController(
        text: widget.initialProduct!["stock_qty"]?.toString() ?? "",
      );

    } else {
      _nameController = TextEditingController();
      _priceController = TextEditingController();
      _descController = TextEditingController();
      _prepMinutesController = TextEditingController(text: "15");
      _stockController = TextEditingController();
    }
  }

  Future<void> _loadShopId() async {
    if (_shopId != null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedShopId = prefs.getString('shop_id');
      if (savedShopId != null) {
        setState(() {
          _shopId = savedShopId;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _prepMinutesController.dispose();
    _stockController.dispose();

    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cats = await _vendeurService.getCategories();
      setState(() {
        _categories = cats;
        _isLoading = false;

        if (widget.initialProduct != null) {
          _selectedCategoryId = widget.initialProduct!["category_id"];
        }

        if (_selectedCategoryId == null && _categories.isNotEmpty) {
          _selectedCategoryId = _categories.first['id'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _save() async {
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir les champs obligatoires (Nom et Prix).",
          ),
        ),
      );
      return;
    }

    if (_shopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID de boutique introuvable.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> fields = {
      'shop_id': _shopId,
      'category_id': _selectedCategoryId,
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'unit': _selectedUnit,
      'price_fcfa': int.tryParse(_priceController.text.trim()) ?? 0,
      'is_active': _isOnline ? 1 : 0,
      'prep_minutes': int.tryParse(_prepMinutesController.text.trim()) ?? 15,
    };

    final stockText = _stockController.text.trim();
    if (stockText.isNotEmpty) {
      fields['stock_qty'] = int.tryParse(stockText);
    } else {
      fields['stock_qty'] = null;
    }

    if (widget.initialProduct != null) {
      fields['_method'] = 'PUT';
    }

    if (_pickedFile != null && _pickedFile!.path != null) {
      final fileName = _pickedFile!.name;
      final fileKey = (widget.initialProduct != null)
          ? 'photo_url'
          : 'photo_file';
      fields[fileKey] = await dio_pkg.MultipartFile.fromFile(
        _pickedFile!.path!,
        filename: fileName,
      );
    }



    final formData = dio_pkg.FormData.fromMap(fields);

    try {
      if (widget.initialProduct != null) {
        await _vendeurService.updateProduct(
          widget.initialProduct!['id'],
          formData,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Produit modifié avec succès !"),
              backgroundColor: CdaColors.vertForet,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        await _vendeurService.createProduct(formData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Produit créé avec succès !"),
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
            content: Text("Erreur lors de l'enregistrement : $e"),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    }
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le produit"),
        content: const Text("Êtes-vous sûr de vouloir supprimer ce produit ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Supprimer",
              style: TextStyle(color: CdaColors.rouge),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _vendeurService.deleteProduct(widget.initialProduct!['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Produit supprimé avec succès !"),
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
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialProduct != null;

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          isEditing ? "Modifier le Produit" : "Ajouter un Produit",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CdaColors.encre),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: CdaColors.rouge),
              onPressed: _delete,
            ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading && _categories.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CdaColors.vertForet),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Display / Selector
                  Center(
                    child: Column(
                      children: [
                        if (widget.initialProduct != null &&
                            widget.initialProduct!['photo_url'] != null &&
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
                                widget.initialProduct!['photo_url'],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 120,
                                      height: 120,
                                      color: CdaColors.vertForet.withOpacity(
                                        0.08,
                                      ),
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
                          title: "Photo du produit",
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

                  // Form Fields
                  Text(
                    "Nom du produit *",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Ex: Porc braisé portion",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Catégorie *",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedCategoryId,
                        isExpanded: true,
                        hint: Text(
                          "Sélectionnez une catégorie",
                          style: GoogleFonts.nunito(color: CdaColors.gris),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat['id'],
                            child: Text(
                              "${cat['emojis'] ?? ''} ${cat['name'] ?? ''}",
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: CdaColors.encre,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategoryId = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Unité *",
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedUnit,
                                  isExpanded: true,
                                  items: _units.map((unit) {
                                    return DropdownMenuItem<String>(
                                      value: unit,
                                      child: Text(
                                        unit,
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          color: CdaColors.encre,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedUnit = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Préparation (min)",
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _prepMinutesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Ex: 15",
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Prix (FCFA) *",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Ex: 3500",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Description",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Décrivez le produit...",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stock control
                  Text(
                    "Quantité en stock",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Laissez vide si le produit est disponible en quantité illimitée",
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: CdaColors.gris,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Ex: 10 (laisser vide pour illimité)",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),



                  // Online Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Visible en ligne",
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            Text(
                              "Rendre le produit disponible pour les clients",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: CdaColors.gris,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isOnline,
                        activeColor: CdaColors.vertForet,
                        onChanged: (val) {
                          setState(() {
                            _isOnline = val;
                          });
                        },
                      ),
                    ],
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
                              "Enregistrer",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
