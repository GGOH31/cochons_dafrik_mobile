import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/client_service.dart';
import 'forms/adress_form_page.dart';

class ClientAdressPage extends StatefulWidget {
  const ClientAdressPage({super.key});

  @override
  State<ClientAdressPage> createState() => _ClientAdressPageState();
}

class _ClientAdressPageState extends State<ClientAdressPage> {
  final ClientService _clientService = ClientService();
  List<dynamic> _addresses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await _clientService.getAddresses();
      setState(() {
        _addresses = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          "Mes Adresses",
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
      body: _buildBody(),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CdaColors.vertForet),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                color: CdaColors.rouge,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                "Erreur de chargement",
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CdaColors.encre,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 15, color: CdaColors.gris),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadAddresses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CdaColors.vertForet,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(
                  LucideIcons.refreshCw,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  "Réessayer",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CdaColors.rose.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.mapPin,
                  size: 60,
                  color: CdaColors.rouge,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Aucune adresse de livraison",
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CdaColors.encre,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Veuillez ajouter une adresse pour faciliter vos commandes et livraisons.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 15, color: CdaColors.gris),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24.0),
      itemCount: _addresses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final address = _addresses[index];
        final String label = address['label'] ?? 'Adresse';
        final String commune = address['commune'] ?? 'Non spécifiée';
        final String details = address['details'] ?? '';
        final bool isDefault =
            address['is_default'] == true || address['is_default'] == 1;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDefault
                    ? CdaColors.vertForet.withOpacity(0.08)
                    : CdaColors.gris.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.mapPin,
                color: isDefault ? CdaColors.vertForet : CdaColors.gris,
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                ),
                if (isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: CdaColors.vertForet.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Par défaut",
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: CdaColors.vertForet,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commune,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: CdaColors.gris,
                    ),
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                LucideIcons.edit3,
                color: CdaColors.vertForet,
                size: 20,
              ),
              onPressed: () => _navigateToForm(address),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToForm(null),
          style: ElevatedButton.styleFrom(
            backgroundColor: CdaColors.vertForet,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          icon: const Icon(LucideIcons.plus, color: Colors.white),
          label: Text(
            "Ajouter une adresse",
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToForm(Map<String, dynamic>? address) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdressFormPage(address: address)),
    ).then((value) {
      if (value == true) {
        _loadAddresses();
      }
    });
  }
}
