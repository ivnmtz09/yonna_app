import 'package:flutter/material.dart';
import 'package:yonna_app/services/api_service.dart';
import 'package:dio/dio.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final res = await ApiService.get("auth/profile/");
      setState(() {
        _user = res.data;
        _loading = false;
      });
    } on DioException catch (e) {
      print("Error al obtener perfil: ${e.response?.data ?? e.message}");
      setState(() => _loading = false);
    }
  }

  String _traducir(String key, String? value) {
    if (key == "role") {
      switch (value) {
        case "admin":
          return "Administrador";
        case "teacher":
          return "Sabedor / Docente";
        case "student":
          return "Estudiante";
      }
    }
    if (key == "level") {
      switch (value) {
        case "beginner":
          return "Principiante";
        case "intermediate":
          return "Intermedio";
        case "advanced":
          return "Avanzado";
      }
    }
    return value ?? "-";
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF8025);
    final bgColor = const Color(0xFFFFF0E6);
    final textColor = const Color(0xFF333333);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: orange,
        title: const Text(
          "Perfil de usuario",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8025)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: orange.withOpacity(0.2),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 65,
                      color: Color(0xFFFF8025),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${_user?["usuario"]["first_name"] ?? ""} ${_user?["usuario"]["last_name"] ?? ""}"
                            .trim()
                            .isEmpty
                        ? "Usuario sin nombre"
                        : "${_user?["usuario"]["first_name"] ?? ""} ${_user?["usuario"]["last_name"] ?? ""}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _user?["usuario"]["username"] ?? "",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _infoTile(
                          icon: Icons.email_outlined,
                          label: "Correo electrónico",
                          value: _user?["usuario"]["email"] ?? "-",
                        ),
                        _divider(),
                        _infoTile(
                          icon: Icons.badge_outlined,
                          label: "Rol",
                          value: _traducir("role", _user?["usuario"]["role"]),
                        ),
                        _divider(),
                        _infoTile(
                          icon: Icons.star_border_rounded,
                          label: "Nivel",
                          value: _traducir("level", _user?["usuario"]["level"]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(thickness: 1),
                  const SizedBox(height: 12),
                  const Text(
                    "La edición de perfil estará disponible próximamente.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF8025)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF777777),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: Colors.grey.withOpacity(0.3),
      indent: 16,
      endIndent: 16,
    );
  }
}
