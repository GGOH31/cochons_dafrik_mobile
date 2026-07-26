class ApiEndpoints {
  //static const String baseUrl = 'http://10.118.138.131:8000';
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
  static const String dishes = '${ApiBase.baseUrlV1}vendeur/dishes';
  static const String accompaniments = '${ApiBase.baseUrlV1}vendeur/accompaniments';
  static const String promotions = '${ApiBase.baseUrlV1}vendeur/promotions';
  static const String personalInfo = '${ApiBase.baseUrlV1}vendeur/profile/personal';
  static const String restaurantInfo = '${ApiBase.baseUrlV1}vendeur/profile/restaurant';
  static const String updateRestaurantInfo = '${ApiBase.baseUrlV1}vendeur/profile/restaurant';
  static const String orders = '${ApiBase.baseUrlV1}vendeur/orders';
  static const String dashboard = '${ApiBase.baseUrlV1}vendeur/dashboard';
}

class ClientEndPoints {
  static const String restaurants = '${ApiBase.baseUrlV1}client/restaurants';
  static const String searchDishes = '${ApiBase.baseUrlV1}client/dishes/search';
  static const String personalInfo = '${ApiBase.baseUrlV1}client/profile/personal';
  static const String getAddresses = '${ApiBase.baseUrlV1}client/addresses';
  static const String addAddress = '${ApiBase.baseUrlV1}client/addresses';
  static const String updateAddress = '${ApiBase.baseUrlV1}client/addresses';
  static const String paymentMethods = '${ApiBase.baseUrlV1}client/payment-methods';
  static const String orders = '${ApiBase.baseUrlV1}client/orders';
}

