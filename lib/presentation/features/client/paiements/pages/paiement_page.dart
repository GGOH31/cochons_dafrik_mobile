import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/appHeaderBanner_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/cart_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/client_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/profil_client/pages/client_adress_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/paiements/pages/cinetpay_webview_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/paiements/pages/location_picker_page.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';

class PaiementPage extends StatefulWidget {
  const PaiementPage({super.key});

  @override
  State<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  final ClientService _clientService = ClientService();
  final double _deliveryFee = 0.0;
  static const double cinetPayFeeRate = 0.03;
  List<dynamic> _addresses = [];
  Map<String, dynamic>? _selectedAddress;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  final TextEditingController _phoneController = TextEditingController();
  LatLng? _deliveryPosition;
  bool _isLocatingDelivery = false;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
    _loadStoredPhone();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadStoredPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        final Map<String, dynamic> user = jsonDecode(userString);
        final phone = user['phone']?.toString();
        if (phone != null && phone.isNotEmpty) {
          setState(() {
            _phoneController.text = phone;
          });
        }
      }
    } catch (_) {
      // Ignoré : le client peut de toute façon saisir son numéro manuellement.
    }
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final addresses = await _clientService.getAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;

        if (addresses.isNotEmpty) {
          _setSelectedAddress(
            addresses.firstWhere(
              (addr) => addr['is_default'] == true || addr['is_default'] == 1,
              orElse: () => addresses.first,
            ),
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

  void _setSelectedAddress(Map<String, dynamic> address) {
    _selectedAddress = address;
    final lat = (address['latitude'] as num?)?.toDouble();
    final lng = (address['longitude'] as num?)?.toDouble();
    _deliveryPosition = (lat != null && lng != null) ? LatLng(lat, lng) : null;
  }

  Future<void> _shareCurrentLocation() async {
    setState(() {
      _isLocatingDelivery = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Le service de localisation est désactivé.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Permission de localisation refusée.");
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          "Permission de localisation refusée définitivement. Autorisez-la dans les réglages.",
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _deliveryPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocatingDelivery = false;
        });
      }
    }
  }

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) =>
            LocationPickerPage(initialPosition: _deliveryPosition),
      ),
    );
    if (result != null) {
      setState(() {
        _deliveryPosition = result;
      });
    }
  }

  Widget _buildDeliveryPositionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Position de livraison",
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CdaColors.vertForet,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Cette position sera partagée avec le restaurant pour la livraison.",
          style: GoogleFonts.nunito(fontSize: 12, color: CdaColors.gris),
        ),
        const SizedBox(height: 12),
        if (_deliveryPosition != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CdaColors.vertForet, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.checkCircle2,
                  color: CdaColors.vertForet,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Position partagée : "
                    "${_deliveryPosition!.latitude.toStringAsFixed(5)}, "
                    "${_deliveryPosition!.longitude.toStringAsFixed(5)}",
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
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLocatingDelivery ? null : _shareCurrentLocation,
                icon: _isLocatingDelivery
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.locate, size: 16),
                label: Text(
                  "Ma position actuelle",
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CdaColors.vertForet,
                  side: const BorderSide(color: CdaColors.vertForet),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickLocationOnMap,
                icon: const Icon(LucideIcons.map, size: 16),
                label: Text(
                  "Choisir sur la carte",
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CdaColors.vertForet,
                  side: const BorderSide(color: CdaColors.vertForet),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// La sélection d'adresse textuelle a été retirée de cet écran : la position GPS
  /// (voir [_buildDeliveryPositionSection]) est désormais la source de vérité pour la
  /// livraison. On garde uniquement une invite si le client n'a encore aucune adresse
  /// enregistrée, car la commande a toujours besoin d'un `address_id`.
  Widget _buildAddressesSection() {
    if (_selectedAddress != null) {
      return const SizedBox.shrink();
    }

    return Container(
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
            "Aucune adresse enregistrée. Ajoutez-en une pour continuer.",
            textAlign: TextAlign.center,
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
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.nunito(
                        color: CdaColors.rouge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildAddressesSection(),
                  const SizedBox(height: 24),

                  _buildDeliveryPositionSection(),
                  const SizedBox(height: 24),

                  // Fee notice
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFE5D5C5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.info,
                          size: 16,
                          color: CdaColors.vertForet,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Des frais de transaction de ${(cinetPayFeeRate * 100).toStringAsFixed(0)}% s'appliquent, prélevés par CinetPay selon l'opérateur choisi (Orange Money, MTN, Wave, Moov, carte bancaire).",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: CdaColors.gris,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Numéro Mobile Money pour le paiement",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.vertForet,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Ex: 0102030405",
                      hintStyle: GoogleFonts.nunito(
                        color: CdaColors.gris.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFFE5D5C5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFFE5D5C5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ce numéro peut être différent de celui de votre compte : c'est celui qui sera débité.",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: CdaColors.gris,
                    ),
                  ),
                  const SizedBox(height: 16),

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

                final payerPhone = _phoneController.text.trim();
                if (payerPhone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Veuillez saisir le numéro Mobile Money à utiliser pour le paiement.",
                      ),
                      backgroundColor: CdaColors.rouge,
                    ),
                  );
                  return;
                }

                if (_deliveryPosition == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Veuillez partager votre position de livraison (position actuelle ou carte).",
                      ),
                      backgroundColor: CdaColors.rouge,
                    ),
                  );
                  return;
                }

                setState(() {
                  _isSubmitting = true;
                });

                try {
                  // 0. Persist the shared delivery position on the selected address
                  // so the restaurant can see it for this order.
                  final address = _selectedAddress!;
                  final addressLat = (address['latitude'] as num?)?.toDouble();
                  final addressLng = (address['longitude'] as num?)?.toDouble();
                  if (addressLat != _deliveryPosition!.latitude ||
                      addressLng != _deliveryPosition!.longitude) {
                    await _clientService
                        .updateAddress(address['id'].toString(), {
                          'label': address['label'] ?? 'Adresse',
                          'commune': address['commune'],
                          'details': address['details'] ?? '',
                          'is_default': address['is_default'] == true,
                          'latitude': _deliveryPosition!.latitude,
                          'longitude': _deliveryPosition!.longitude,
                        });
                  }

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

                  // 3. Initialize the real CinetPay payment and get the payment_url
                  final initResult = await _clientService
                      .initiateCinetPayPayment(orderId, phone: payerPhone);
                  final String? paymentUrl =
                      initResult['payment_url'] as String?;

                  if (paymentUrl == null || paymentUrl.isEmpty) {
                    throw Exception(
                      "Impossible d'obtenir l'URL de paiement CinetPay.",
                    );
                  }

                  setState(() {
                    _isSubmitting = false;
                  });

                  if (!mounted) return;

                  // 4. Open CinetPay's hosted payment page in an in-app WebView.
                  final CinetPayResult? webviewResult =
                      await Navigator.of(context).push<CinetPayResult>(
                        MaterialPageRoute(
                          builder: (context) =>
                              CinetPayWebviewPage(paymentUrl: paymentUrl),
                        ),
                      );

                  if (!mounted) return;

                  setState(() {
                    _isSubmitting = true;
                  });

                  // 5. Re-verify the payment status with the backend (source of truth),
                  // regardless of what the WebView redirect said.
                  bool isPaid = false;
                  try {
                    final verifiedOrder = await _clientService
                        .verifyCinetPayPayment(orderId);
                    isPaid = verifiedOrder['status'] == 'paid';
                  } catch (_) {
                    // Le paiement peut encore être en cours de traitement côté CinetPay.
                  }

                  setState(() {
                    _isSubmitting = false;
                  });

                  if (!mounted) return;

                  if (isPaid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Paiement effectué avec succès ! Votre commande est en cours de préparation.",
                        ),
                        backgroundColor: CdaColors.vertForet,
                      ),
                    );
                    cartService.clearCart();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (webviewResult == CinetPayResult.cancelled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Paiement annulé. Votre commande reste en attente de paiement, vous pouvez réessayer.",
                        ),
                        backgroundColor: CdaColors.rouge,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Paiement non confirmé pour le moment. Vérifiez le statut de votre commande dans quelques instants.",
                        ),
                        backgroundColor: CdaColors.rouge,
                      ),
                    );
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
