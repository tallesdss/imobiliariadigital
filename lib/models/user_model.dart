enum UserType { buyer, realtor, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photo;
  final UserType type;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photo,
    required this.type,
    required this.createdAt,
    this.isActive = true,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photo,
    UserType? type,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Mapear os campos do banco para os campos do modelo
    String name = json['nome'] ?? json['name'] ?? '';
    String? phone = json['telefone'] ?? json['phone'];
    String? photo = json['foto'] ?? json['photo'];
    String typeString = json['tipo_usuario'] ?? json['type'] ?? 'comprador';
    
    // Converter tipo_usuario do banco para UserType
    UserType type;
    switch (typeString) {
      case 'comprador':
        type = UserType.buyer;
        break;
      case 'corretor':
        type = UserType.realtor;
        break;
      case 'administrador':
        type = UserType.admin;
        break;
      default:
        type = UserType.buyer;
    }
    
    return User(
      id: json['id'],
      name: name,
      email: json['email'],
      phone: phone,
      photo: photo,
      type: type,
      createdAt: DateTime.parse(json['data_criacao'] ?? json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['ativo'] ?? json['isActive'] ?? json['is_active'] ?? true,
    );
  }
}
