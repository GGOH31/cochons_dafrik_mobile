/// Requête d'inscription — client uniquement (les comptes vendeurs sont créés
/// par l'administration, jamais par inscription directe).
class StoreUserRequest {
  final String role;
  final String fullName;
  final String phone;
  final String? email;
  final String password;

  StoreUserRequest({
    required this.role,
    required this.fullName,
    required this.phone,
    this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'password': password,
    };
  }
}
