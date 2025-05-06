class Vendor {
  final int id;
  final String name;
  final String description;
  final int? categoryId;
  final String? categoryName;
  final String? phoneNumber;
  final bool isVerified;

  Vendor({
    required this.id,
    required this.name,
    required this.description,
    this.categoryId,
    this.categoryName,
    this.phoneNumber,
    required this.isVerified,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      categoryId: json['category'],
      categoryName: json['category_name'],
      phoneNumber: json['phone_number'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': categoryId,
      'phone_number': phoneNumber,
    };
  }
}
