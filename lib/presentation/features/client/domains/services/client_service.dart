import 'package:cochons_dafrik_mobile/core/constants/api_endpoints.dart';
import 'package:cochons_dafrik_mobile/domains/services/base_service.dart';

class ClientService extends BaseService {
  /// Récupérer la liste des restaurants
  Future<List<dynamic>> getRestaurants({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await getAll(
        ClientEndPoints.restaurants,
        queryParameters: queryParameters,
      );
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(
          res['message'] ?? 'Erreur lors du chargement des restaurants',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les dishes d'une restaurant spécifique
  Future<List<dynamic>> getRestaurantDishes(
    String restaurantId, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await getAll(
        '${ClientEndPoints.restaurants}/$restaurantId/dishes',
        queryParameters: queryParameters,
      );
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(
          res['message'] ??
              'Erreur lors du chargement des dishes de la restaurant',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Rechercher des dishes par leur nom (quel que soit la restaurant)
  Future<List<dynamic>> searchDishes(String name) async {
    try {
      final res = await getAll(
        ClientEndPoints.searchDishes,
        queryParameters: {'name': name},
      );
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(
          res['message'] ?? 'Erreur lors de la recherche des dishes',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les informations personnelles du client
  Future<Map<String, dynamic>> getPersonalInfo() async {
    try {
      final res = await getOne(ClientEndPoints.personalInfo);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ??
              'Erreur lors du chargement des informations personnelles',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les adresses de livraison du client
  Future<List<dynamic>> getAddresses() async {
    try {
      final res = await getAll(ClientEndPoints.getAddresses);
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(
          res['message'] ??
              'Erreur lors du chargement des adresses de livraison',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Ajouter une adresse de livraison
  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> data) async {
    try {
      final res = await create(ClientEndPoints.addAddress, data);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ?? "Erreur lors de l'ajout de l'adresse",
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Modifier une adresse de livraison existante
  Future<Map<String, dynamic>> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await updateWithFormData(
        ClientEndPoints.updateAddress,
        data,
        id: id,
      );
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ?? "Erreur lors de la modification de l'adresse",
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les moyens de paiement actifs
  Future<List<dynamic>> getPaymentMethods() async {
    try {
      final res = await getAll(ClientEndPoints.paymentMethods);
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(
          res['message'] ?? 'Erreur lors du chargement des moyens de paiement',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Passer une commande
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    try {
      final res = await create(ClientEndPoints.orders, data);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ?? 'Erreur lors de la création de la commande',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Payer une commande (simulation)
  Future<Map<String, dynamic>> payOrder(
    String orderId,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await create('${ClientEndPoints.orders}/$orderId/pay', data);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ?? 'Erreur lors du paiement de la commande',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Initialiser un paiement CinetPay pour une commande.
  /// [phone] est le numéro Mobile Money à utiliser pour ce paiement (saisi par le client,
  /// peut différer de son numéro de compte).
  /// Retourne { payment_url, order } : payment_url doit être ouverte dans une WebView.
  Future<Map<String, dynamic>> initiateCinetPayPayment(
    String orderId, {
    String? phone,
  }) async {
    try {
      final res = await create(
        '${ClientEndPoints.orders}/$orderId/pay/cinetpay',
        {if (phone != null && phone.isNotEmpty) 'phone': phone},
      );
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ??
              "Erreur lors de l'initialisation du paiement CinetPay",
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Re-vérifier le statut d'un paiement CinetPay auprès du serveur (après retour de la WebView).
  Future<Map<String, dynamic>> verifyCinetPayPayment(String orderId) async {
    try {
      final res = await create(
        '${ClientEndPoints.orders}/$orderId/pay/cinetpay/verify',
        {},
      );
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ?? 'Erreur lors de la vérification du paiement',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer la liste des commandes du client (optionnellement filtrées par statut)
  Future<List<dynamic>> getOrders({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      final res = await getAll(
        ClientEndPoints.orders,
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
        throw Exception(
          res['message'] ?? 'Erreur lors du chargement des commandes',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les détails d'une commande
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final res = await getOne(ClientEndPoints.orders, id: orderId);
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ?? 'Erreur lors de la récupération de la commande',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Confirmer la réception d'une commande
  Future<Map<String, dynamic>> confirmReception(String orderId) async {
    try {
      final res = await create(
        '${ClientEndPoints.orders}/$orderId/confirm',
        {},
      );
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ?? 'Erreur lors de la confirmation de réception',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Soumettre un avis sur une commande
  Future<Map<String, dynamic>> submitReview(
    String orderId,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await create(
        '${ClientEndPoints.orders}/$orderId/review',
        data,
      );
      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          res['message'] ?? 'Erreur lors de la soumission de l\'avis',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
