import 'package:cochons_dafrik_mobile/core/constants/api_endpoints.dart';
import 'package:cochons_dafrik_mobile/domains/services/base_service.dart';
import 'package:dio/dio.dart';

class VendeurService extends BaseService {

  /// Récupérer les dishes du vendeur connecté
  Future<List<dynamic>> getProducts() async {
    try {
      final res = await getAll('${ApiBase.baseUrlV1}vendeur/dishes');
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement des dishes');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Créer un dish
  Future<Map<String, dynamic>> createProduct(dynamic data) async {
    try {
      final res = await createWithFormData(VendeurEndPoints.dishes, data);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la création du dish');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour un dish
  Future<Map<String, dynamic>> updateProduct(String id, dynamic data) async {
    try {
      final res = await createWithFormData(VendeurEndPoints.dishes, data, id: id);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la mise à jour du dish');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer un dish
  Future<void> deleteProduct(String id) async {
    try {
      final res = await delete(VendeurEndPoints.dishes, id: id);
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Erreur lors de la suppression du dish');
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

  /// Récupérer les informations de la restaurant du vendeur
  Future<Map<String, dynamic>> getShopInfo() async {
    try {
      final res = await getOne(VendeurEndPoints.restaurantInfo);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement de la restaurant');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour les informations de la restaurant
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

      final res = await createWithFormData(VendeurEndPoints.updateRestaurantInfo, formData);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la mise à jour de la restaurant');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les commandes reçues par la restaurant (optionnellement filtrées par statut)
  Future<List<dynamic>> getOrders({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      final res = await getAll(
        VendeurEndPoints.orders,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (res['success'] == true) {
        if (res['data'] is List) {
          return res['data'] as List<dynamic>;
        } else if (res['data'] is Map && res['data']['data'] is List) {
          return res['data']['data'] as List<dynamic>;
        }
        return [];
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement des commandes');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Accepter une commande
  Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    try {
      final res = await create('${VendeurEndPoints.orders}/$orderId/accept', {});
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de l\'acceptation de la commande');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Refuser une commande
  Future<Map<String, dynamic>> refuseOrder(String orderId) async {
    try {
      final res = await create('${VendeurEndPoints.orders}/$orderId/refuse', {});
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du refus de la commande');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les détails d'une commande (côté vendeur)
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final res = await getOne(VendeurEndPoints.orders, id: orderId);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la récupération de la commande');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour le statut de préparation/livraison d'une commande
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    try {
      final res = await updateWithFormData(
        '${VendeurEndPoints.orders}/$orderId/status',
        {'status': status},
      );
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du changement de statut');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les données du tableau de bord du vendeur
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final res = await getOne(VendeurEndPoints.dashboard);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement du tableau de bord');
      }
    } catch (e) {
      rethrow;
    }
  }
}
