import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/appHeaderBanner_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/cart_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/client_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/profil_client/pages/client_adress_page.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';

class PaiementPage extends StatefulWidget {
  const PaiementPage({super.key});

  @override
  State<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  final ClientService _clientService = ClientService();
  String _selectedMethod = 'wave'; // orange, mtn, wave, card
  final double _deliveryFee = 1000.0;
  List<dynamic> _paymentMethods = [];
  List<dynamic> _addresses = [];
  Map<String, dynamic>? _selectedAddress;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _clientService.getPaymentMethods(),
        _clientService.getAddresses(),
      ]);
      final List<dynamic> methods = results[0] as List<dynamic>;
      final List<dynamic> addresses = results[1] as List<dynamic>;
      setState(() {
        _paymentMethods = methods;
        _addresses = addresses;
        _isLoading = false;

        if (methods.isNotEmpty) {
          final waveExists = methods.any((m) => m['code'] == 'wave');
          if (waveExists) {
            _selectedMethod = 'wave';
          } else {
            _selectedMethod = methods.first['code'] ?? '';
          }
        }

        if (addresses.isNotEmpty) {
          _selectedAddress = addresses.firstWhere(
            (addr) => addr['is_default'] == true || addr['is_default'] == 1,
            orElse: () => addresses.first,
          );
        } else {
          _selectedAddress = null;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Widget _buildAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Adresse de livraison",
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CdaColors.vertForet,
              ),
            ),
            IconButton(
              icon: const Icon(
                LucideIcons.plusCircle,
                color: CdaColors.vertForet,
                size: 20,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClientAdressPage(),
                  ),
                ).then((_) {
                  _loadCheckoutData();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_addresses.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  "Aucune adresse enregistrée.",
                  style: GoogleFonts.nunito(color: CdaColors.gris),
                ),
                const SizedBox(height: 12),
                CdaElevatedButton(
                  text: "Ajouter une adresse",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientAdressPage(),
                      ),
                    ).then((_) {
                      _loadCheckoutData();
                    });
                  },
                  backgroundColor: CdaColors.vertForet,
                  foregroundColor: Colors.white,
                  height: 40,
                ),
              ],
            ),
          ),
        ] else ...[
          ..._addresses.map<Widget>((address) {
            final isSelected =
                _selectedAddress != null &&
                _selectedAddress!['id'] == address['id'];
            final String label = address['label'] ?? 'Adresse';
            final String commune = address['commune'] ?? 'Non spécifiée';
            final String details = address['details'] ?? '';
            final bool isDefault =
                address['is_default'] == true || address['is_default'] == 1;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAddress = address;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected
                        ? CdaColors.vertForet
                        : const Color(0xFFE5D5C5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? CdaColors.vertForet
                              : CdaColors.gris,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CdaColors.vertForet,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                label,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: CdaColors.encre,
                                ),
                              ),
                              if (isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CdaColors.vertForet.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Défaut",
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
                          const SizedBox(height: 2),
                          Text(
                            "$commune, $details",
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: CdaColors.gris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildIconForMethod(String code) {
    String? assetPath;
    Color bgColor = Colors.white;
    bool isAsset = true;

    switch (code) {
      case 'wave':
        assetPath = 'assets/pictures/wave.png';
        bgColor = const Color(0xFF1D9BF0);
        break;
      case 'orange_money':
        assetPath = 'assets/pictures/orange.jpg';
        bgColor = const Color(0xFFFF6600);
        break;
      case 'mtn_momo':
        assetPath = 'assets/pictures/mtn.jpg';
        bgColor = const Color(0xFFFFCC00);
        break;
      case 'moov_money':
        assetPath = 'assets/pictures/moov.png';
        bgColor = const Color(0xFF005A9C);
        break;
      case 'cash':
        assetPath = 'assets/pictures/cash.jpg';
        bgColor = const Color(0xFF4CAF50);
        break;
      default:
        isAsset = false;
        bgColor = CdaColors.vertForet.withOpacity(0.1);
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: isAsset && assetPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  assetPath,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                code == 'card' ? LucideIcons.creditCard : LucideIcons.wallet,
                color: CdaColors.vertForet,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CdaColors.vertForet),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "Erreur lors du chargement des moyens de paiement.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: CdaColors.rouge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadCheckoutData,
            icon: const Icon(LucideIcons.refreshCw, size: 14),
            label: Text("Réessayer", style: GoogleFonts.nunito()),
          ),
        ],
      );
    }

    if (_paymentMethods.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Text(
          "Aucun moyen de paiement disponible.",
          style: GoogleFonts.nunito(color: CdaColors.gris),
        ),
      );
    }

    return Column(
      children: _paymentMethods.map<Widget>((method) {
        final code = method['code'] ?? '';
        final name = method['name'] ?? '';
        return _buildPaymentOption(
          methodId: code,
          iconWidget: _buildIconForMethod(code),
          title: name,
          subTitle: code == 'wave' ? 'Recommandé' : null,
        );
      }).toList(),
    );
  }

  Widget _buildPaymentOption({
    required String methodId,
    required Widget iconWidget,
    required String title,
    String? subTitle,
  }) {
    final isSelected = _selectedMethod == methodId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = methodId;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? CdaColors.vertForet : const Color(0xFFE5D5C5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Custom Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? CdaColors.vertForet : CdaColors.gris,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: CdaColors.vertForet,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Brand Icon Container
            iconWidget,
            const SizedBox(width: 16),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  if (subTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subTitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: CdaColors.gris,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartService = CartService.instance;
    final totalProducts = cartService.totalAmount;
    final totalToPay = totalProducts + _deliveryFee;
    final cartItems = cartService.items;

    return Scaffold(
      backgroundColor: CdaColors.creme,
      body: Column(
        children: [
          // Header using AppHeaderBanner
          AppHeaderBanner(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  "Paiement sécurisé",
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Secured payment notification banner overlaid at the bottom of the header
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.lock,
                    size: 16,
                    color: CdaColors.encre,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Payé avant cuisson . protégé Cochons d'Afrik",
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CdaColors.encre,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main body content (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE5D5C5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Cart items list in summary
                        ...cartItems.map((item) {
                          final itemTotal =
                              (item.productPrice + item.selectedSidePrice) *
                              item.quantity;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${item.quantity} × ${item.productName}",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: CdaColors.gris,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "${itemTotal.toInt()} F",
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: CdaColors.encre,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // Delivery fee
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedAddress != null
                                    ? "Livraison . ${_selectedAddress!['commune'] ?? ''}"
                                    : "Livraison . Choisir une adresse",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: CdaColors.gris,
                                ),
                              ),
                              Text(
                                "${_deliveryFee.toInt()} F",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: CdaColors.encre,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFE5D5C5), thickness: 1),
                        const SizedBox(height: 4),
                        // Total to pay
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total à payer",
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            Text(
                              "${totalToPay.toInt()} F",
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.vertForet,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAddressesSection(),
                  const SizedBox(height: 24),

                  // Middle Section Title
                  Text(
                    "Moyen de paiement",
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.vertForet,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildPaymentMethodsList(),

                  // Escrow notification banner (orange border/bg)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFFFB300),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("🛡️ ", style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            "Paiement séquestre : le vendeur lance la cuisson dès votre paiement, mais n'est payé qu'après votre confirmation de réception.",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5D4037),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: CdaElevatedButton(
              backgroundColor: const Color(
                0xFFFFA000,
              ), // Nice brand orange yellow
              foregroundColor: CdaColors.encre,
              height: 52,
              isLoading: _isSubmitting,
              onPressed: () async {
                if (_selectedAddress == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Veuillez sélectionner une adresse de livraison avant de procéder au paiement.",
                      ),
                      backgroundColor: CdaColors.rouge,
                    ),
                  );
                  return;
                }

                if (cartItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Votre panier est vide."),
                      backgroundColor: CdaColors.rouge,
                    ),
                  );
                  return;
                }

                setState(() {
                  _isSubmitting = true;
                });

                try {
                  // 1. Create order payload
                  final firstItem = cartItems.first;
                  final restaurantId = firstItem.restaurantId;

                  final Map<String, dynamic> orderData = {
                    'restaurant_id': restaurantId,
                    'order_type': 'b2c',
                    'delivery_mode': 'delivery',
                    'address_id': _selectedAddress!['id'],
                    'items': cartItems.map((item) {
                      return {
                        'dish_id': item.dishId,
                        'quantity': item.quantity,
                        'options':
                            item.selectedSide != 'Sans accompagnement' &&
                                item.selectedSide.isNotEmpty
                            ? {'accompagnement': item.selectedSide}
                            : null,
                      };
                    }).toList(),
                  };

                  // 2. Call API to create order (validates cart and registers order)
                  final orderResult = await _clientService.createOrder(
                    orderData,
                  );
                  final String orderId = orderResult['id'].toString();

                  // 3. Prepare payment info (simulated Wave callback or method ID)
                  final selectedMethodObject = _paymentMethods.firstWhere(
                    (m) => m['code'] == _selectedMethod,
                    orElse: () => null,
                  );
                  final paymentMethodId = selectedMethodObject?['id'];

                  final Map<String, dynamic> payData = {
                    'payment_method_id': paymentMethodId,
                    'provider_ref':
                        'WAVE-SIM-${DateTime.now().millisecondsSinceEpoch}',
                  };

                  if (paymentMethodId == null) {
                    payData['provider'] = _selectedMethod;
                  }

                  // 4. Simulate payment callback
                  await _clientService.payOrder(orderId, payData);

                  setState(() {
                    _isSubmitting = false;
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Commande et paiement enregistrés avec succès !",
                        ),
                        backgroundColor: CdaColors.vertForet,
                      ),
                    );
                    cartService.clearCart();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } catch (e) {
                  setState(() {
                    _isSubmitting = false;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Erreur lors du traitement : ${e.toString().replaceAll('Exception: ', '')}",
                        ),
                        backgroundColor: CdaColors.rouge,
                      ),
                    );
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payer maintenant",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  Text(
                    "${totalToPay.toInt()} F",
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
