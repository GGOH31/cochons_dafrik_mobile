class Restaurant {
  final String id;
  final String name;
  final double rating;
  final String emoji;
  final String location;
  final String speciality;
  final List<Dish> dishes;
  final String? logoUrl;

  const Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.emoji,
    required this.location,
    required this.speciality,
    required this.dishes,
    this.logoUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      rating: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      emoji: '🍖',
      location: json['commune'] ?? 'Cocody',
      speciality: json['description'] ?? 'Vendeur de porc braisé',
      dishes: [],
      logoUrl: json['logo_url'],
    );
  }
}

class Dish {
  final String id;
  final String restaurantId;
  final String name;
  final double price;
  final String emoji;
  final String restaurantName;
  final String restaurantLocation;
  final double rating;
  final int ratingCount;
  final String? description;
  final int? prepMinutes;
  final String? photoUrl;
  final List<dynamic> accompaniments;
  final int? deliveryFeeFcfa;
  final String? deliveryZone;

  const Dish({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.emoji,
    required this.restaurantName,
    required this.restaurantLocation,
    required this.rating,
    required this.ratingCount,
    this.description,
    this.prepMinutes,
    this.photoUrl,
    this.accompaniments = const [],
    this.deliveryFeeFcfa,
    this.deliveryZone,
  });

  factory Dish.fromJson(Map<String, dynamic> json, String restaurantName, {String restaurantLocation = 'Cocody'}) {
    return Dish(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurant_id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price_fcfa'] as num?)?.toDouble() ?? 0.0,
      emoji: '🍖',
      restaurantName: restaurantName,
      restaurantLocation: json['restaurant']?['commune'] ?? restaurantLocation,
      rating: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] as int? ?? 0,
      description: json['description'],
      prepMinutes: json['prep_minutes'] as int?,
      photoUrl: json['photo_url'],
      accompaniments: json['accompaniments'] as List<dynamic>? ?? [],
      deliveryFeeFcfa: json['restaurant']?['delivery_fee_fcfa'] as int?,
      deliveryZone: json['restaurant']?['delivery_zone'] as String?,
    );
  }
}
