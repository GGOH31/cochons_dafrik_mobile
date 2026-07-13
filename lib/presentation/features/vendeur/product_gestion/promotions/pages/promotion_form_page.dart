import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';

class PromotionFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialPromo;

  const PromotionFormPage({super.key, this.initialPromo});

  @override
  State<PromotionFormPage> createState() => _PromotionFormPageState();
}

class _PromotionFormPageState extends State<PromotionFormPage> {
  final VendeurService _vendeurService = VendeurService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _valueController;
  String? _selectedProductId;
  DateTimeRange? _selectedDateRange;
  bool _isActive = true;

  List<dynamic> _products = [];
  bool _isLoading = false;
  bool _isProductsLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialPromo?["title"] ?? "",
    );
    _valueController = TextEditingController(
      text: widget.initialPromo?["value"]?.toString() ?? "",
    );
    _selectedProductId = widget.initialPromo?["product_id"]?.toString();
    _isActive = widget.initialPromo?["is_active"] ?? true;

    final startsAtStr = widget.initialPromo?['starts_at'];
    final endsAtStr = widget.initialPromo?['ends_at'];
    if (startsAtStr != null && endsAtStr != null) {
      try {
        _selectedDateRange = DateTimeRange(
          start: DateTime.parse(startsAtStr).toLocal(),
          end: DateTime.parse(endsAtStr).toLocal(),
        );
      } catch (_) {}
    }

    _loadProducts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final prods = await _vendeurService.getProducts();
      setState(() {
        _products = prods;
        _isProductsLoading = false;

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
            content: Text("Erreur lors du chargement des produits : $e"),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CdaColors.vertForet,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: CdaColors.encre,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner un produit pour cette promotion."),
          backgroundColor: CdaColors.rouge,
        ),
      );
      return;
    }

    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner une période de validité."),
          backgroundColor: CdaColors.rouge,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> data = {
      'product_id': _selectedProductId,
      'title': _titleController.text.trim(),
      'promo_type': 'percentage',
      'value': int.tryParse(_valueController.text.trim()) ?? 0,
      'starts_at': _selectedDateRange!.start.toUtc().toIso8601String(),
      'ends_at': _selectedDateRange!.end.toUtc().toIso8601String(),
      'is_active': _isActive ? 1 : 0,
    };

    try {
      if (widget.initialPromo != null) {
        await _vendeurService.updatePromotion(
          widget.initialPromo!['id'].toString(),
          data,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Promotion modifiée avec succès !"),
              backgroundColor: CdaColors.vertForet,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        await _vendeurService.createPromotion(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Promotion créée avec succès !"),
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
        content: const Text("Voulez-vous vraiment supprimer cette promotion ?"),
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
      await _vendeurService.deletePromotion(
        widget.initialPromo!['id'].toString(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Promotion supprimée."),
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
    final isEditing = widget.initialPromo != null;

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          isEditing ? "Modifier la Promotion" : "Créer une Promotion",
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
                          "Vous devez d'abord créer au moins un produit pour pouvoir créer des promotions.",
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
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFCEBEB),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.tag,
                                  color: Color(0xFFE05234),
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Product Dropdown
                            Text(
                              "Associer au produit *",
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
                              hint: const Text("Sélectionnez un produit"),
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
                              "Nom de la promotion *",
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: "Ex: Week-end braisé",
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

                            // Percentage
                            Text(
                              "Pourcentage de réduction (%) *",
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _valueController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Ex: 20",
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
                                final intVal = int.tryParse(value);
                                if (intVal == null || intVal <= 0 || intVal > 100) {
                                  return "Veuillez entrer un pourcentage entre 1 et 100";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Validity Period
                            Text(
                              "Période de validité *",
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickDateRange,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDateRange == null
                                          ? "Sélectionner les dates"
                                          : "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} au ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}",
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        color: _selectedDateRange == null
                                            ? CdaColors.gris
                                            : CdaColors.encre,
                                        fontWeight: _selectedDateRange == null
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                      ),
                                    ),
                                    const Icon(
                                      LucideIcons.calendar,
                                      color: CdaColors.gris,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Status Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Statut active",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CdaColors.encre,
                                  ),
                                ),
                                Switch(
                                  value: _isActive,
                                  activeColor: CdaColors.vertForet,
                                  onChanged: (value) {
                                    setState(() {
                                      _isActive = value;
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
                                onPressed: _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE05234),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  isEditing
                                      ? "Enregistrer les modifications"
                                      : "Créer la promotion",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            // Delete Button
                            if (isEditing) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: _delete,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: CdaColors.rouge),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    "Supprimer la promotion",
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                      color: CdaColors.rouge,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
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
