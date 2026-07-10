import 'package:dio/dio.dart';
import 'package:cochons_dafrik_mobile/core/constants/api_endpoints.dart';
import 'package:cochons_dafrik_mobile/core/networks/dio_client.dart';
import 'package:cochons_dafrik_mobile/core/models/login_request.dart';
import 'package:cochons_dafrik_mobile/core/models/store_user_request.dart';
import 'package:cochons_dafrik_mobile/domains/services/base_service.dart';

/// Service gérant toutes les opérations d'authentification de Cochons d'Afrik.
/// Il communique avec les endpoints d'authentification du backend.
class AuthService extends BaseService {
  
  /// Connecte un utilisateur via son numéro de téléphone et son mot de passe.
  /// Stocke automatiquement le jeton d'authentification dans [DioClient].
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final response = await dio.post(
        AuthEndPoints.login,
        data: request.toJson(),
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        final payload = data['data'];
        final String? token = payload['token'];
        if (token != null) {
          DioClient.instance.setAuthToken(token);
        }
        return payload;
      } else {
        throw Exception(data != null ? data['message'] : 'Erreur de connexion');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData != null && responseData['message'] != null) {
        throw Exception(responseData['message']);
      }
      throw Exception('Erreur réseau : ${e.message}');
    }
  }

  /// Inscrit un nouveau client (B2C ou B2B).
  /// Déclenche l'envoi d'un code OTP par SMS.
  Future<Map<String, dynamic>> registerClient(StoreUserRequest request) async {
    try {
      final response = await dio.post(
        AuthEndPoints.register,
        data: request.toJson(),
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        return data;
      } else {
        throw Exception(data != null ? data['message'] : "Erreur d'inscription");
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData != null && responseData['message'] != null) {
        throw Exception(responseData['message']);
      }
      throw Exception('Erreur réseau : ${e.message}');
    }
  }

  /// Inscrit un nouveau vendeur (avec les détails de sa boutique et justificatifs d'activité).
  /// Déclenche l'envoi d'un code OTP par SMS.
  Future<Map<String, dynamic>> registerVendeur(StoreUserRequest request) async {
    try {
      final Map<String, dynamic> formFields = request.toJson();

      // Si des détails de boutique sont fournis, nous convertissons le JSON
      // à plat au format multi-part attendu par Laravel (e.g. shop[name])
      final shopData = request.shop;
      if (shopData != null) {
        // Retirer la clé de structure imbriquée 'shop' pour la reconstruire
        formFields.remove('shop');

        formFields['shop[name]'] = shopData.name;
        formFields['shop[commune]'] = shopData.commune;

        if (shopData.description != null && shopData.description!.trim().isNotEmpty) {
          formFields['shop[description]'] = shopData.description;
        }
        if (shopData.address != null && shopData.address!.trim().isNotEmpty) {
          formFields['shop[address]'] = shopData.address;
        }

        // Ajout du fichier de logo si présent
        if (shopData.logoFilePath != null && shopData.logoFilePath!.isNotEmpty) {
          final logoFileName = shopData.logoFilePath!.split('/').last;
          formFields['shop[logo_file]'] = await MultipartFile.fromFile(
            shopData.logoFilePath!,
            filename: logoFileName,
          );
        }

        // Ajout obligatoire du fichier justificatif d'activité
        final docsFileName = shopData.supportingDocsFilePath.split('/').last;
        formFields['shop[supporting_docs_file]'] = await MultipartFile.fromFile(
          shopData.supportingDocsFilePath,
          filename: docsFileName,
        );
      }

      final formData = FormData.fromMap(formFields);

      final response = await dio.post(
        AuthEndPoints.register,
        data: formData,
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        return data;
      } else {
        throw Exception(data != null ? data['message'] : "Erreur d'inscription");
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData != null && responseData['message'] != null) {
        throw Exception(responseData['message']);
      }
      throw Exception('Erreur réseau : ${e.message}');
    }
  }

  /// Demande le renvoi d'un code de validation OTP pour un numéro de téléphone donné.
  Future<String> sendOtp(String phone) async {
    try {
      final response = await dio.post(
        AuthEndPoints.sendOtp,
        data: {'phone': phone},
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        return data['message'] ?? 'Code renvoyé';
      } else {
        throw Exception(data != null ? data['message'] : 'Erreur lors du renvoi du code');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData != null && responseData['message'] != null) {
        throw Exception(responseData['message']);
      }
      throw Exception('Erreur réseau : ${e.message}');
    }
  }

  /// Valide le code OTP saisi par l'utilisateur.
  /// Stocke le jeton d'authentification retourné.
  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    try {
      final response = await dio.post(
        AuthEndPoints.verifyOtp,
        data: {
          'phone': phone,
          'code': code,
        },
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        final payload = data['data'];
        final String? token = payload['token'];
        if (token != null) {
          DioClient.instance.setAuthToken(token);
        }
        return payload;
      } else {
        throw Exception(data != null ? data['message'] : 'Code OTP invalide');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData != null && responseData['message'] != null) {
        throw Exception(responseData['message']);
      }
      throw Exception('Erreur réseau : ${e.message}');
    }
  }

  /// Déconnecte l'utilisateur en supprimant son token d'authentification.
  void logout() {
    DioClient.instance.removeAuthToken();
  }
}
