class ApiEndpoints {
  // static const String baseUrl = 'http://10.47.199.131:8000';
  static const String baseUrl = "http://150.107.201.90:8043";
}

class ApiBase {
  static const String baseUrlV1 = "/api/v1/";
}

class AuthEndPoints {
  static const String login = '${ApiBase.baseUrlV1}auth/login';
  static const String register = '${ApiBase.baseUrlV1}auth/register';
  static const String sendOtp = '${ApiBase.baseUrlV1}auth/send-otp';
  static const String verifyOtp = '${ApiBase.baseUrlV1}auth/verify-otp';
  static const String forgotPassword = '${ApiBase.baseUrlV1}auth/forgot-password';
  static const String resetPassword = '${ApiBase.baseUrlV1}auth/reset-password';
}

class VendeurEndPoints {
  static const String categories = '${ApiBase.baseUrlV1}vendeur/categories';
  static const String products = '${ApiBase.baseUrlV1}vendeur/products';
  static const String accompaniments = '${ApiBase.baseUrlV1}vendeur/accompaniments';
  static const String promotions = '${ApiBase.baseUrlV1}vendeur/promotions';
}

class ClientEndPoints {
  static const String shops = '${ApiBase.baseUrlV1}client/shops';
  static const String searchProducts = '${ApiBase.baseUrlV1}client/products/search';
}

