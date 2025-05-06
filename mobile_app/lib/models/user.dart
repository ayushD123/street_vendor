class User {
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String userType;
  final String? profilePicture;
  final bool isVerified;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.userType,
    this.profilePicture,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      userType: json['user_type'],
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'user_type': userType,
      'profile_picture': profilePicture,
      'is_verified': isVerified,
    };
  }
}