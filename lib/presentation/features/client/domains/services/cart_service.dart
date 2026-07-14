import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String id; // unique cart item id (e.g. productId + selectedSide)
  final String productId;
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
    _loadCart();
  }

  final ValueNotifier<List<CartItem>> cartNotifier = ValueNotifier<List<CartItem>>([]);

  List<CartItem> get items => cartNotifier.value;

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartStr = prefs.getString('client_cart');
      if (cartStr != null) {
        final List<dynamic> decoded = jsonDecode(cartStr);
        cartNotifier.value = decoded.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Erreur de chargement du panier: $e");
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartStr = jsonEncode(cartNotifier.value.map((item) => item.toJson()).toList());
      await prefs.setString('client_cart', cartStr);
    } catch (e) {
      debugPrint("Erreur de sauvegarde du panier: $e");
    }
  }

  void addToCart({
    required String productId,
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
    final existingIndex = cartNotifier.value.indexWhere((item) => item.id == id);

    final currentItems = List<CartItem>.from(cartNotifier.value);

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity += quantity;
    } else {
      currentItems.add(CartItem(
        id: id,
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        productPhotoUrl: productPhotoUrl,
        productEmoji: productEmoji,
        shopName: shopName,
        quantity: quantity,
        selectedSide: selectedSide,
        selectedSidePrice: selectedSidePrice,
      ));
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
