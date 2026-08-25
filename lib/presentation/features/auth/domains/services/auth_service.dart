import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:cochons_dafrik_mobile/core/constants/api_endpoints.dart';
import 'package:cochons_dafrik_mobile/core/networks/dio_client.dart';
import 'package:cochons_dafrik_mobile/core/models/login_request.dart';
import 'package:cochons_dafrik_mobile/core/models/store_user_request.dart';
import 'package:cochons_dafrik_mobile/domains/services/base_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/cart_service.dart';

/// Service gérant toutes les opérations d'authentification de Cochons d'Afrik.
/// Il communique avec les endpoints d'authentification du backend.
class AuthService extends BaseService {
  final DioClient _dioClient = DioClient.instance;

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
        final user = payload['user'];
        if (token != null) {
          DioClient.instance.setAuthToken(token);
        }

        if (user != null) {
          await _dioClient.storeValue('user', jsonEncode(user));
          final String? role = user['role'];
          if (role != null) {
            await _dioClient.storeValue('role', role);
          }
          final restaurant = user['restaurant'];
          if (restaurant != null && restaurant['id'] != null) {
            await _dioClient.storeValue(
              'restaurant_id',
              restaurant['id'].toString(),
            );
          }
          await CartService.instance.loadCart();
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
        throw Exception(
          data != null ? data['message'] : "Erreur d'inscription",
        );
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
        throw Exception(
          data != null ? data['message'] : 'Erreur lors du renvoi du code',
        );
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
        data: {'phone': phone, 'code': code},
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

  /// Demande la réinitialisation du mot de passe (forgot-password).
  Future<Map<String, dynamic>> forgotPassword(String phone) async {
    try {
      final response = await dio.post(
        AuthEndPoints.forgotPassword,
        data: {'phone': phone},
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        return data;
      } else {
        throw Exception(
          data != null ? data['message'] : 'Erreur lors de la demande',
        );
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData != null && responseData['message'] != null) {
        throw Exception(responseData['message']);
      }
      throw Exception('Erreur réseau : ${e.message}');
    }
  }

  /// Réinitialise le mot de passe (reset-password).
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        AuthEndPoints.resetPassword,
        data: {
          'phone': phone,
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        return data;
      } else {
        throw Exception(
          data != null ? data['message'] : 'Erreur lors de la réinitialisation',
        );
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
  Future<void> logout() async {
    await DioClient.instance.removeAuthToken();
    await CartService.instance.loadCart();
  }
}
