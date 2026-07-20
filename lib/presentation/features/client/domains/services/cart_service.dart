import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String id; // unique cart item id (e.g. productId + selectedSide)
  final String productId;
  final String shopId;
  final String productName;
  final double productPrice;
  final String? productPhotoUrl;
  final String productEmoji;
  final String shopName;
  int quantity;
  final String selectedSide;
  final double selectedSidePrice;

  CartItem({
    required this.id,
    required this.productId,
    required this.shopId,
    required this.productName,
    required this.productPrice,
    this.productPhotoUrl,
    required this.productEmoji,
    required this.shopName,
    required this.quantity,
    required this.selectedSide,
    required this.selectedSidePrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'shopId': shopId,
      'productName': productName,
      'productPrice': productPrice,
      'productPhotoUrl': productPhotoUrl,
      'productEmoji': productEmoji,
      'shopName': shopName,
      'quantity': quantity,
      'selectedSide': selectedSide,
      'selectedSidePrice': selectedSidePrice,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      shopId: json['shopId'] ?? '',
      productName: json['productName'],
      productPrice: (json['productPrice'] as num).toDouble(),
      productPhotoUrl: json['productPhotoUrl'],
      productEmoji: json['productEmoji'] ?? '🍖',
      shopName: json['shopName'] ?? '',
      quantity: json['quantity'] as int,
      selectedSide: json['selectedSide'] ?? '',
      selectedSidePrice: (json['selectedSidePrice'] as num).toDouble(),
    );
  }
}

class CartService {
  static final CartService _instance = CartService._internal();
  static CartService get instance => _instance;

  CartService._internal() {
    loadCart();
  }

  final ValueNotifier<List<CartItem>> cartNotifier =
      ValueNotifier<List<CartItem>>([]);

  List<CartItem> get items => cartNotifier.value;

  Future<String> _getCartKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null && userString.isNotEmpty) {
        final Map<String, dynamic> user = jsonDecode(userString);
        final userId = user['id'] ?? user['phone'] ?? user['email'];
        if (userId != null && userId.toString().isNotEmpty) {
          return 'client_cart_$userId';
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération de la clé de panier: $e");
    }
    return 'client_cart_guest';
  }

  /// Charge le panier de l'utilisateur actuellement connecté
  Future<void> loadCart() async {
    try {
      final key = await _getCartKey();
      final prefs = await SharedPreferences.getInstance();
      final cartStr = prefs.getString(key);
      if (cartStr != null && cartStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cartStr);
        cartNotifier.value = decoded
            .map((item) => CartItem.fromJson(item))
            .toList();
      } else {
        cartNotifier.value = [];
      }
    } catch (e) {
      debugPrint("Erreur de chargement du panier: $e");
      cartNotifier.value = [];
    }
  }

  Future<void> _saveCart() async {
    try {
      final key = await _getCartKey();
      final prefs = await SharedPreferences.getInstance();
      final cartStr = jsonEncode(
        cartNotifier.value.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(key, cartStr);
    } catch (e) {
      debugPrint("Erreur de sauvegarde du panier: $e");
    }
  }

  void addToCart({
    required String productId,
    required String shopId,
    required String productName,
    required double productPrice,
    String? productPhotoUrl,
    required String productEmoji,
    required String shopName,
    required int quantity,
    required String selectedSide,
    required double selectedSidePrice,
  }) {
    final id = "${productId}_$selectedSide";
    final existingIndex = cartNotifier.value.indexWhere(
      (item) => item.id == id,
    );

    final currentItems = List<CartItem>.from(cartNotifier.value);

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity += quantity;
    } else {
      currentItems.add(
        CartItem(
          id: id,
          productId: productId,
          shopId: shopId,
          productName: productName,
          productPrice: productPrice,
          productPhotoUrl: productPhotoUrl,
          productEmoji: productEmoji,
          shopName: shopName,
          quantity: quantity,
          selectedSide: selectedSide,
          selectedSidePrice: selectedSidePrice,
        ),
      );
    }

    cartNotifier.value = currentItems;
    _saveCart();
  }

  void updateQuantity(String id, int quantity) {
    final currentItems = List<CartItem>.from(cartNotifier.value);
    final index = currentItems.indexWhere((item) => item.id == id);

    if (index >= 0) {
      if (quantity <= 0) {
        currentItems.removeAt(index);
      } else {
        currentItems[index].quantity = quantity;
      }
      cartNotifier.value = currentItems;
      _saveCart();
    }
  }

  void removeFromCart(String id) {
    final currentItems = List<CartItem>.from(cartNotifier.value);
    currentItems.removeWhere((item) => item.id == id);
    cartNotifier.value = currentItems;
    _saveCart();
  }

  void clearCart() {
    cartNotifier.value = [];
    _saveCart();
  }

  double get totalAmount {
    double total = 0.0;
    for (var item in cartNotifier.value) {
      total += (item.productPrice + item.selectedSidePrice) * item.quantity;
    }
    return total;
  }
}
