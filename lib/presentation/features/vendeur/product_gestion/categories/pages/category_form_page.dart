import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

class CategoryFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialCategory;

  const CategoryFormPage({super.key, this.initialCategory});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _nameController = TextEditingController();
  String _selectedEmoji = "🥗";
  final List<String> _emojiOptions = ["🥗", "🍖", "🥤", "🍱", "🌶️", "🌾", "🍛"];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _nameController.text = widget.initialCategory!["name"] ?? "";
      _selectedEmoji = widget.initialCategory!["emoji"] ?? "🥗";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un nom.")),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Catégorie enregistrée !"),
        backgroundColor: CdaColors.vertForet,
      ),
    );
    Navigator.pop(context, {
      "name": _nameController.text.trim(),
      "emoji": _selectedEmoji,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialCategory != null;

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          isEditing ? "Modifier la Catégorie" : "Ajouter une Catégorie",
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
            Text(
              "Nom de la catégorie",
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Ex: Accompagnements",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Choisir un Emoji",
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: CdaColors.encre),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _emojiOptions.map((emoji) {
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEmoji = emoji;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? CdaColors.vertForet.withOpacity(0.15) : Colors.white,
                      border: Border.all(
                        color: isSelected ? CdaColors.vertForet : CdaColors.ligne,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),

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
