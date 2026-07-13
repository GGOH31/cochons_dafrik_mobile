class ApiEndpoints {
  static const String baseUrl = 'http://192.168.1.5:8000';
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

