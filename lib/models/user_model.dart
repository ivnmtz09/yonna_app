class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final int level;
  final int xp;
  final String? avatar;
  final String? telefono;
  final String? localidad;
  final List<String>? gustos;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.level,
    required this.xp,
    this.avatar,
    this.telefono,
    this.localidad,
    this.gustos,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'student',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      avatar: json['avatar'],
      telefono: json['telefono'],
      localidad: json['localidad'],
      gustos: json['gustos'] != null ? List<String>.from(json['gustos']) : null,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  bool get isTeacher => role == 'teacher';

  int get xpForNextLevel =>
      level * 100; // Ejemplo: nivel 1 = 100 XP, nivel 2 = 200 XP
  double get progressToNextLevel => (xp % xpForNextLevel) / xpForNextLevel;
}
