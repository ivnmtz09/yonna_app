class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final int level;
  final int xp;
  final String? bio;
  final UserProfile? profile;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.level,
    required this.xp,
    this.bio,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Intentar obtener datos del perfil tanto del objeto anidado como del nivel superior
    final profileData = json['profile'];

    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'user',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      bio: json['bio'],
      profile: profileData != null
          ? UserProfile.fromJson(profileData)
          : UserProfile(
              telefono: json['telefono'],
              localidad: json['localidad'],
              gustos: json['gustos'] != null
                  ? List<String>.from(json['gustos'])
                  : null,
              avatar: json['avatar'],
              fechaNacimiento: json['fecha_nacimiento'] != null
                  ? DateTime.parse(json['fecha_nacimiento'])
                  : null,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'level': level,
      'xp': xp,
      'bio': bio,
      'profile': profile?.toJson(),
    };
  }

  // Getters para roles (CORREGIDOS - sin 'teacher')
  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';
  bool get isUser => role == 'user';
  bool get canManage => isAdmin || isModerator;

  // Sistema de XP
  int get xpForNextLevel => level * 100;
  double get progressToNextLevel =>
      isUser ? (xp % xpForNextLevel) / xpForNextLevel : 0;

  String get fullName => '$firstName $lastName'.trim();

  String get roleDisplayName {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'moderator':
        return 'Moderador';
      case 'user':
        return 'Usuario';
      default:
        return 'Usuario';
    }
  }

  // NUEVO: Getters para acceder directamente a propiedades del perfil
  // Esto permite usar user.telefono en lugar de user.profile?.telefono
  String? get telefono => profile?.telefono;
  String? get localidad => profile?.localidad;
  List<String>? get gustos => profile?.gustos;
  String? get avatar => profile?.avatar;
  DateTime? get fechaNacimiento => profile?.fechaNacimiento;
}

class UserProfile {
  final String? avatar;
  final String? telefono;
  final List<String>? gustos;
  final DateTime? fechaNacimiento;
  final String? localidad;

  UserProfile({
    this.avatar,
    this.telefono,
    this.gustos,
    this.fechaNacimiento,
    this.localidad,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      avatar: json['avatar'],
      telefono: json['telefono'],
      gustos: json['gustos'] != null ? List<String>.from(json['gustos']) : null,
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'])
          : null,
      localidad: json['localidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'telefono': telefono,
      'gustos': gustos,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'localidad': localidad,
    };
  }
}
