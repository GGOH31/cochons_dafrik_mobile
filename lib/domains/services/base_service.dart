import 'package:cochons_dafrik_mobile/core/networks/dio_client.dart';
import 'package:dio/dio.dart';


class BaseService {
  final Dio dio;

  BaseService() : dio = DioClient.instance.dio;

  // getOne
  Future<dynamic> getOne(String endPoint, {String? id}) async {
    final url = id != null ? '$endPoint/$id' : endPoint;

    try {
      final response = await dio.get(url);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

// getAll avec query params optionnels
  Future<Map<String, dynamic>> getAll(
      String endPoint, {
        dynamic id,
        Map<String, dynamic>? queryParameters,
      }) async {
    // Construire l'URL
    final url = id != null ? '$endPoint/$id' : endPoint;

    // On crée une copie pour ne pas modifier l'original
    final params = queryParameters != null ? Map<String, dynamic>.from(queryParameters) : <String, dynamic>{};

    try {
      final response = await dio.get(
        url,
        queryParameters: params, // 👈 gère per_page, items_per_page, categories_per_page, page, category_id, search...
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }



  Future<dynamic> create(String endPoint, Map<String, dynamic> data, {String? id}) async {
    final url = id != null ? '$endPoint/$id' : endPoint;

    try {
      final response = await dio.post(url, data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Retourner quand même les données du serveur même pour 400/401
        return e.response?.data;
      }
      // Sinon, erreur réseau
      rethrow;
    }
  }



  Future<dynamic> createListMap(String endPoint, List<Map<String, dynamic>> data, {String? id}) async {
    final url = id != null ? '$endPoint/$id' : endPoint;

    try {
      final response = await dio.post(url, data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Retourner quand même les données du serveur même pour 400/401
        return e.response?.data;
      }
      // Sinon, erreur réseau
      rethrow;
    }
  }


  // create with formData
  Future<dynamic> createWithFormData(String endPoint, dynamic data,
      {String? id}) async {
    final url = id != null ? '$endPoint/$id' : endPoint;

    try {
      final response = await dio.post(url, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // update
  Future<dynamic> update(String endPoint, Map<dynamic, String> data,
      {String? id}) async {
    final url = id != null ? '$endPoint/$id' : endPoint;

    try {
      final response = await dio.put(url, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // update with formData
  Future<dynamic> updateWithFormData(String endPoint, dynamic data,
      {String? id}) async {
    final url = id != null ? '$endPoint/$id' : endPoint;

    try {
      final response =
          await dio.put(url, data: data); // data peut être Map ou FormData
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // delete
  Future<dynamic> delete(String endPoint, {String? id}) async {
    final url = id != null ? '$endPoint/$id' : endPoint;

    try {
      final response = await dio.delete(url);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Gestion d'erreurs
  String _handleError(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return 'Bad Request';
        case 401:
          return 'Unauthorized';
        case 403:
          return 'Forbidden';
        case 404:
          return 'Not Found';
        case 500:
          return 'Internal Server Error';
        default:
          return 'Unknown Error: ${e.response!.statusCode}';
      }
    } else {
      return 'Network Error: ${e.message}';
    }
  }
}
