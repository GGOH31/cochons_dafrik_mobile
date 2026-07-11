import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

class PromotionFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialPromo;

  const PromotionFormPage({super.key, this.initialPromo});

  @override
  State<PromotionFormPage> createState() => _PromotionFormPageState();
}

class _PromotionFormPageState extends State<PromotionFormPage> {
  final _nameController = TextEditingController();
  final _percentController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    if (widget.initialPromo != null) {
      _nameController.text = widget.initialPromo!["name"] ?? "";
      _percentController.text = widget.initialPromo!["percent"] ?? "";
    }
  }

  void _save() {
    if (_nameController.text.trim().isEmpty || _percentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir les champs obligatoires.")),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Promotion créée avec succès !"),
        backgroundColor: CdaColors.vertForet,
      ),
    );
    Navigator.pop(context, {
      "name": _nameController.text.trim(),
      "percent": _percentController.text.trim(),
      "dates": _selectedDateRange == null
          ? "Permanent"
          : "Du ${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} au ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}",
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
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

  @override
  void dispose() {
    _nameController.dispose();
    _percentController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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

            Text(
              "Nom de la promotion *",
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Ex: Week-end braisé",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Pourcentage de réduction (%) *",
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _percentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Ex: 20",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Période de validité",
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          : "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} au ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}",
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: _selectedDateRange == null ? CdaColors.gris : CdaColors.encre,
                        fontWeight: _selectedDateRange == null ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const Icon(LucideIcons.calendar, color: CdaColors.gris, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE05234),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  "Enregistrer la promotion",
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
