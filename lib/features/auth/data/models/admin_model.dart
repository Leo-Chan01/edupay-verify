class AdminModel {
  final String id;
  final String name;
  final String username;
  final String? email;
  final String? authToken;
  final String? userLevel;

  AdminModel({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.authToken,
    this.userLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'auth_token': authToken,
      'user_level': userLevel,
    };
  }

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username:
          json['username']?.toString() ?? json['email']?.toString() ?? '',
      email: json['email']?.toString(),
      authToken: json['auth_token']?.toString(),
      userLevel: json['user_level']?.toString(),
    );
  }
}
