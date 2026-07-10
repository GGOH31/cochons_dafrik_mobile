class StoreShopRequest {
  final String name;
  final String? description;
  final String? logoFilePath;
  final String commune;
  final String? address;
  final String supportingDocsFilePath;

  StoreShopRequest({
    required this.name,
    this.description,
    this.logoFilePath,
    required this.commune,
    this.address,
    required this.supportingDocsFilePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'commune': commune,
      'address': address,
    };
  }
}
