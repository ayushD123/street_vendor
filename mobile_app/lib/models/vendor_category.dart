class VendorCategory {
  final int id;
  final String name;
  final String description;

  VendorCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory VendorCategory.fromJson(Map<String, dynamic> json) {
    return VendorCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}