class Boutique {
  final String id;
  final String name;
  final double rating;
  final String emoji;
  final String location;
  final String speciality;
  final List<Produit> products;

  const Boutique({
    required this.id,
    required this.name,
    required this.rating,
    required this.emoji,
    required this.location,
    required this.speciality,
    required this.products,
  });
}

class Produit {
  final String id;
  final String name;
  final double price;
  final String emoji;
  final String shopName;
  final double rating;

  const Produit({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.shopName,
    required this.rating,
  });
}

const List<Boutique> mockBoutiques = [
  Boutique(
    id: '1',
    name: 'Chez Tantie Porc',
    rating: 4.8,
    emoji: '🍖',
    location: 'Cocody',
    speciality: 'Porc braisé de qualité',
    products: [
      Produit(
        id: '1_1',
        name: 'Porc braisé (portion)',
        price: 3500,
        emoji: '🍖',
        shopName: 'Chez Tantie Porc',
        rating: 4.8,
      ),
      Produit(
        id: '1_2',
        name: 'Côtelettes grillées',
        price: 4000,
        emoji: '🥩',
        shopName: 'Chez Tantie Porc',
        rating: 4.8,
      ),
      Produit(
        id: '1_3',
        name: 'Saucisse de porc maison',
        price: 2500,
        emoji: '🌭',
        shopName: 'Chez Tantie Porc',
        rating: 4.8,
      ),
    ],
  ),
  Boutique(
    id: '2',
    name: "Le Fumoir d'Ali",
    rating: 4.6,
    emoji: '🐷',
    location: 'Marcory',
    speciality: 'Porc au four & fumé',
    products: [
      Produit(
        id: '2_1',
        name: 'Porc au four ½ kg',
        price: 5000,
        emoji: '🐷',
        shopName: "Le Fumoir d'Ali",
        rating: 4.6,
      ),
      Produit(
        id: '2_2',
        name: 'Poitrine fumée',
        price: 6000,
        emoji: '🥓',
        shopName: "Le Fumoir d'Ali",
        rating: 4.6,
      ),
      Produit(
        id: '2_3',
        name: 'Jambonneau laqué',
        price: 8500,
        emoji: '🍖',
        shopName: "Le Fumoir d'Ali",
        rating: 4.6,
      ),
    ],
  ),
  Boutique(
    id: '3',
    name: 'Maquis Bello',
    rating: 4.7,
    emoji: '🥗',
    location: 'Yopougon',
    speciality: 'Accompagnements & Grillades',
    products: [
      Produit(
        id: '3_1',
        name: 'Menu braisé + attiéké',
        price: 3000,
        emoji: '🥗',
        shopName: 'Maquis Bello',
        rating: 4.7,
      ),
      Produit(
        id: '3_2',
        name: 'Alloco portion',
        price: 1000,
        emoji: '🍌',
        shopName: 'Maquis Bello',
        rating: 4.7,
      ),
      Produit(
        id: '3_3',
        name: 'Chou braisé',
        price: 1500,
        emoji: '🥬',
        shopName: 'Maquis Bello',
        rating: 4.7,
      ),
    ],
  ),
  Boutique(
    id: '4',
    name: 'Kôrô Grill',
    rating: 4.9,
    emoji: '🔥',
    location: 'Riviera 3',
    speciality: 'Spécialités de porc piquant',
    products: [
      Produit(
        id: '4_1',
        name: 'Porc fou épicé',
        price: 4000,
        emoji: '🔥',
        shopName: 'Kôrô Grill',
        rating: 4.9,
      ),
      Produit(
        id: '4_2',
        name: 'Brochettes de porc (3 pcs)',
        price: 3000,
        emoji: '🍢',
        shopName: 'Kôrô Grill',
        rating: 4.9,
      ),
      Produit(
        id: '4_3',
        name: 'Ribs caramélisés',
        price: 5500,
        emoji: '🍖',
        shopName: 'Kôrô Grill',
        rating: 4.9,
      ),
    ],
  ),
];
