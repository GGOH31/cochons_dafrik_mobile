import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

class ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialProduct;

  const ProductFormPage({super.key, this.initialProduct});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  bool _isOnline = true;
  String _emoji = "🍖";
  String _selectedCategory = "Grillades";
  final List<String> _categories = ["Grillades", "Accompagnements", "Boissons"];

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _nameController = TextEditingController(text: widget.initialProduct!["name"] ?? "");
      _priceController = TextEditingController(text: widget.initialProduct!["price"] ?? "");
      _descController = TextEditingController(text: widget.initialProduct!["description"] ?? "Délicieux produit préparé avec soin.");
      _emoji = widget.initialProduct!["emoji"] ?? "🍖";
      _isOnline = widget.initialProduct!["isOnline"] ?? true;
      _selectedCategory = widget.initialProduct!["category"] ?? "Grillades";
    } else {
      _nameController = TextEditingController();
      _priceController = TextEditingController();
      _descController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir les champs obligatoires (Nom et Prix).")),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Produit enregistré avec succès !"),
        backgroundColor: CdaColors.vertForet,
      ),
    );
    Navigator.pop(context, {
      "name": _nameController.text.trim(),
      "price": _priceController.text.trim(),
      "description": _descController.text.trim(),
      "emoji": _emoji,
      "isOnline": _isOnline,
      "category": _selectedCategory,
    });
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji Display / Picker Placeholder
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: CdaColors.vertForet.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(_emoji, style: const TextStyle(fontSize: 44)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _emoji = _emoji == "🍖" ? "🐷" : _emoji == "🐷" ? "🥩" : "🍖";
                      });
                    },
                    child: Text(
                      "Changer l'icône",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: CdaColors.vertForet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            Text(
              "Nom du produit *",
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Ex: Porc braisé portion",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Catégorie *",
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: GoogleFonts.nunito(fontSize: 16, color: CdaColors.encre)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Prix (FCFA) *",
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Ex: 3500",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Description",
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Décrivez le produit...",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                        style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
                      ),
                      Text(
                        "Rendre le produit disponible pour les clients",
                        style: GoogleFonts.nunito(fontSize: 13, color: CdaColors.gris),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CdaColors.vertForet,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
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
