class Boutique {
  final String id;
  final String name;
  final double rating;
  final String emoji;
  final String location;
  final String speciality;
  final List<Produit> products;
  final String? logoUrl;

  const Boutique({
    required this.id,
    required this.name,
    required this.rating,
    required this.emoji,
    required this.location,
    required this.speciality,
    required this.products,
    this.logoUrl,
  });

  factory Boutique.fromJson(Map<String, dynamic> json) {
    return Boutique(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      rating: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      emoji: '🍖',
      location: json['commune'] ?? 'Cocody',
      speciality: json['description'] ?? 'Vendeur de porc braisé',
      products: [],
      logoUrl: json['logo_url'],
    );
  }
}

class Produit {
  final String id;
  final String shopId;
  final String name;
  final double price;
  final String emoji;
  final String shopName;
  final String shopLocation;
  final double rating;
  final int ratingCount;
  final String? description;
  final int? prepMinutes;
  final String? photoUrl;
  final List<dynamic> accompaniments;

  const Produit({
    required this.id,
    required this.shopId,
    required this.name,
    required this.price,
    required this.emoji,
    required this.shopName,
    required this.shopLocation,
    required this.rating,
    required this.ratingCount,
    this.description,
    this.prepMinutes,
    this.photoUrl,
    this.accompaniments = const [],
  });

  factory Produit.fromJson(Map<String, dynamic> json, String shopName, {String shopLocation = 'Cocody'}) {
    return Produit(
      id: json['id']?.toString() ?? '',
      shopId: json['shop_id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price_fcfa'] as num?)?.toDouble() ?? 0.0,
      emoji: '🍖',
      shopName: shopName,
      shopLocation: json['shop']?['commune'] ?? shopLocation,
      rating: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] as int? ?? 0,
      description: json['description'],
      prepMinutes: json['prep_minutes'] as int?,
      photoUrl: json['photo_url'],
      accompaniments: json['accompaniments'] as List<dynamic>? ?? [],
    );
  }
}
