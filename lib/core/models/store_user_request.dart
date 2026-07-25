import 'store_shop_request.dart';

class StoreUserRequest {
  final String role;
  final String fullName;
  final String phone;
  final String? email;
  final String password;
  final StoreShopRequest? restaurant;

  StoreUserRequest({
    required this.role,
    required this.fullName,
    required this.phone,
    this.email,
    required this.password,
    this.restaurant,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      if (restaurant != null) 'restaurant': restaurant!.toJson(),
    };
  }
}
