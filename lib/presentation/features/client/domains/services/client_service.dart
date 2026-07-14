import 'package:cochons_dafrik_mobile/core/constants/api_endpoints.dart';
import 'package:cochons_dafrik_mobile/domains/services/base_service.dart';

class ClientService extends BaseService {
  /// Récupérer la liste des boutiques
  Future<List<dynamic>> getShops({Map<String, dynamic>? queryParameters}) async {
    try {
      final res = await getAll(ClientEndPoints.shops, queryParameters: queryParameters);
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement des boutiques');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les produits d'une boutique spécifique
  Future<List<dynamic>> getShopProducts(String shopId, {Map<String, dynamic>? queryParameters}) async {
    try {
      final res = await getAll('${ClientEndPoints.shops}/$shopId/products', queryParameters: queryParameters);
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors du chargement des produits de la boutique');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Rechercher des produits par leur nom (quel que soit la boutique)
  Future<List<dynamic>> searchProducts(String name) async {
    try {
      final res = await getAll(ClientEndPoints.searchProducts, queryParameters: {'name': name});
      if (res['success'] == true) {
        return res['data'] as List<dynamic>;
      } else {
        throw Exception(res['message'] ?? 'Erreur lors de la recherche des produits');
      }
    } catch (e) {
      rethrow;
    }
  }
}
