import 'package:cochons_dafrik_mobile/core/constants/api_endpoints.dart';
import 'package:cochons_dafrik_mobile/domains/services/base_service.dart';
import 'package:dio/dio.dart';

class VendeurService extends BaseService {
  /// Récupérer toutes les catégories
  Future<List<dynamic>> getCategories() async {
    try {
      final res = await getAll(VendeurEndPoints.categories);
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement des catégories');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Créer une catégorie
  Future<Map<String, dynamic>> createCategory(String name, String emoji) async {
    try {
      final res = await create(VendeurEndPoints.categories, {
        'name': name,
        'emojis': emoji,
        'is_b2b': false,
      });
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la création de la catégorie');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour une catégorie
  Future<Map<String, dynamic>> updateCategory(int id, String name, String emoji) async {
    try {
      final res = await updateWithFormData(
        VendeurEndPoints.categories,
        {
          'name': name,
          'emojis': emoji,
          'is_b2b': false,
        },
        id: id.toString(),
      );
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la mise à jour de la catégorie');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer une catégorie
  Future<void> deleteCategory(int id) async {
    try {
      final res = await delete(VendeurEndPoints.categories, id: id.toString());
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Erreur lors de la suppression de la catégorie');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les produits du vendeur connecté
  Future<List<dynamic>> getProducts() async {
    try {
      final res = await getAll('${ApiBase.baseUrlV1}vendeur/products');
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement des produits');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Créer un produit
  Future<Map<String, dynamic>> createProduct(dynamic data) async {
    try {
      final res = await createWithFormData(VendeurEndPoints.products, data);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la création du produit');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour un produit
  Future<Map<String, dynamic>> updateProduct(String id, dynamic data) async {
    try {
      final res = await createWithFormData(VendeurEndPoints.products, data, id: id);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la mise à jour du produit');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer un produit
  Future<void> deleteProduct(String id) async {
    try {
      final res = await delete(VendeurEndPoints.products, id: id);
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Erreur lors de la suppression du produit');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les accompagnements
  Future<List<dynamic>> getAccompaniments() async {
    try {
      final res = await getAll(VendeurEndPoints.accompaniments);
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement des accompagnements');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Créer un accompagnement
  Future<Map<String, dynamic>> createAccompaniment(dynamic data) async {
    try {
      final res = await createWithFormData(VendeurEndPoints.accompaniments, data);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? "Erreur lors de la création de l'accompagnement");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour un accompagnement
  Future<Map<String, dynamic>> updateAccompaniment(String id, dynamic data) async {
    try {
      final res = await createWithFormData(VendeurEndPoints.accompaniments, data, id: id);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? "Erreur lors de la mise à jour de l'accompagnement");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer un accompagnement
  Future<void> deleteAccompaniment(String id) async {
    try {
      final res = await delete(VendeurEndPoints.accompaniments, id: id);
      if (res['success'] != true) {
        throw Exception(res['message'] ?? "Erreur lors de la suppression de l'accompagnement");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les promotions
  Future<List<dynamic>> getPromotions() async {
    try {
      final res = await getAll(VendeurEndPoints.promotions);
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement des promotions');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Créer une promotion
  Future<Map<String, dynamic>> createPromotion(Map<String, dynamic> data) async {
    try {
      final res = await create(VendeurEndPoints.promotions, data);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la création de la promotion');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour une promotion
  Future<Map<String, dynamic>> updatePromotion(String id, Map<String, dynamic> data) async {
    try {
      final res = await updateWithFormData(VendeurEndPoints.promotions, data, id: id);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la mise à jour de la promotion');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer une promotion
  Future<void> deletePromotion(String id) async {
    try {
      final res = await delete(VendeurEndPoints.promotions, id: id);
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Erreur lors de la suppression de la promotion');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les informations personnelles du vendeur
  Future<Map<String, dynamic>> getPersonalInfo() async {
    try {
      final res = await getOne(VendeurEndPoints.personalInfo);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement des informations personnelles');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les informations de la boutique du vendeur
  Future<Map<String, dynamic>> getShopInfo() async {
    try {
      final res = await getOne(VendeurEndPoints.shopInfo);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement de la boutique');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour les informations de la boutique
  Future<Map<String, dynamic>> updateShopInfo(Map<String, dynamic> data, {String? logoPath}) async {
    try {
      final Map<String, dynamic> formFields = Map<String, dynamic>.from(data);
      if (logoPath != null && logoPath.isNotEmpty) {
        final logoFileName = logoPath.split('/').last;
        formFields['logo_url'] = await MultipartFile.fromFile(
          logoPath,
          filename: logoFileName,
        );
      }

      final formData = FormData.fromMap(formFields);

      final res = await createWithFormData(VendeurEndPoints.updateShopInfo, formData);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la mise à jour de la boutique');
      }
    } catch (e) {
      rethrow;
    }
  }
}
