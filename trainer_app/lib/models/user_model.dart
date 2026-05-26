class UserModel {
  final String id;
  final String role; // 'trainer' or 'member'
  final String name;
  final String email;
  final String? avatarUrl;
  final String? assignedTrainerId;

  UserModel({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.assignedTrainerId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      assignedTrainerId: json['assignedTrainerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'name': name,
      'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (assignedTrainerId != null) 'assignedTrainerId': assignedTrainerId,
    };
  }

  UserModel copyWith({
    String? id,
    String? role,
    String? name,
    String? email,
    String? avatarUrl,
    String? assignedTrainerId,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
    );
  }
}
