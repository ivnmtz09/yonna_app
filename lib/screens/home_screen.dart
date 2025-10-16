import 'package:flutter/material.dart';
import 'package:yonna_app/screens/profile_screen.dart';
import 'package:yonna_app/screens/splash_screen.dart';
import 'package:yonna_app/services/auth_service.dart';
import 'package:yonna_app/services/api_service.dart';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Usuario";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final res = await ApiService.get("auth/profile/");
      final data = res.data;
      final usuario = data["usuario"];
      setState(() {
        userName = usuario["first_name"]?.toString().isNotEmpty == true
            ? usuario["first_name"]
            : usuario["username"] ?? "Usuario";
        _loading = false;
      });
    } on DioException catch (e) {
      print("Error al obtener usuario: ${e.response?.data ?? e.message}");
      setState(() {
        userName = "Usuario";
        _loading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF8025);
    final bgColor = const Color(0xFFFFF4EC);

    final items = [
      {
        "title": "Lecciones",
        "icon": Icons.menu_book_rounded,
        "color": const Color(0xFFFFA35C),
      },
      {
        "title": "Retos",
        "icon": Icons.emoji_events_rounded,
        "color": const Color(0xFF58C9A6),
      },
      {
        "title": "Progreso",
        "icon": Icons.bar_chart_rounded,
        "color": const Color(0xFFFFD480),
      },
      {
        "title": "Cultura",
        "icon": Icons.public_rounded,
        "color": const Color(0xFF9CD9A7),
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: orange,
        elevation: 2,
        title: Text(
          _loading ? "Cargando..." : "Hola, $userName",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Perfil",
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            tooltip: "Cerrar sesión",
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8025)),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Bienvenido a Yonna",
                    style: TextStyle(
                      color: orange,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Próximamente habilitaremos las misiones, niveles y recompensas.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.builder(
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return GestureDetector(
                          onTap: () {
                            // Navegación futura según el index
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: (item["color"] as Color).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item["icon"] as IconData,
                                  size: 40,
                                  color: (item["color"] as Color).withOpacity(
                                    0.9,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item["title"] as String,
                                  style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset('assets/images/mascota.png', height: 130),
                  const SizedBox(height: 8),
                  Text(
                    "Jamaya Pia, $userName",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF58C9A6),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
