class AdminModel {
  final String id;
  final String name;
  final String username;

  AdminModel({
    required this.id,
    required this.name,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
    };
  }

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
    );
  }
}
