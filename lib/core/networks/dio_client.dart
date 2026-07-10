// ignore_for_file: avoid_print, deprecated_member_use
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';

class DioClient {
  // Singleton
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  final Dio dio;
  static const String _tokenKey = 'token';

  // Constructeur privé
  DioClient._internal() : dio = Dio() {
    dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    );

    // Désactiver SSL pour dev
    if (kDebugMode) {
      disableSSL(); // ou disableSSLForDevHosts(['localhost', '127.0.0.1'])
    }

    // Charger le token si existant
    _loadStoredToken();

    // Intercepteurs
    _setupInterceptors();
  }

  // ====================
  // === SSL METHODS ====
  // ====================

  /// Désactive la vérification SSL pour TOUS les hôtes (⚠️ dev uniquement)
  void disableSSL() {
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  // =========================
  // === TOKEN MANAGEMENT ====
  // =========================

  Future<void> _loadStoredToken() async {
    try {
      final token = await getStoredToken();
      if (token != null && token.isNotEmpty) {
        setAuthToken(token);
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du token: $e');
    }
  }

  /// Charger le token depuis SharedPreferences
  Future<void> loadToken() async {
    try {
      final token = await getStoredToken();
      if (token != null && token.isNotEmpty) {
        setAuthToken(token);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du token: $e');
      rethrow; // Important pour propager l'erreur
    }
  }

  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    storeToken(token);
  }

  void removeAuthToken() {
    dio.options.headers.remove('Authorization');
    _removeStoredToken();
  }

  bool hasToken() {
    return dio.options.headers.containsKey('Authorization');
  }

  String? getCurrentToken() {
    final authHeader = dio.options.headers['Authorization'];
    if (authHeader is String && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }
    return null;
  }

  // =========================
  // === SHARED PREFERENCES ==
  // =========================

  Future<void> storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('❌ Erreur lors du stockage du token: $e');
    }
  }

  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('❌ Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<void> storeValue(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      print('❌ Erreur lors du stockage de la valeur: $e');
    }
  }

  Future<String?> getStoredValue(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      print('❌ Erreur lors de la récupération de la valeur: $e');
      return null;
    }
  }

  Future<void> _removeStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('❌ Erreur lors de la suppression du token: $e');
    }
  }

  // =========================
  // === INTERCEPTORS =======
  // =========================

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getStoredToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            removeAuthToken();
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          logPrint: (obj) => print('🌐 DIO LOG: $obj'),
        ),
      );
    }
  }
}
