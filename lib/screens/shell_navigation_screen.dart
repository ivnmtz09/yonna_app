import 'package:flutter/material.dart';
import '../widgets/glass/glass_nav_bar.dart';
import 'learning_path/learning_path_screen.dart';
import 'vocabulary/vocabulary_screen.dart';
import 'leaderboard/glass_leaderboard_screen.dart';
import 'media/cultural_media_screen.dart';
import 'profile/glass_profile_screen.dart';

class ShellNavigationScreen extends StatefulWidget {
  final int initialTab;

  const ShellNavigationScreen({super.key, this.initialTab = 0});

  @override
  State<ShellNavigationScreen> createState() => _ShellNavigationScreenState();
}

class _ShellNavigationScreenState extends State<ShellNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _screens = const [
    LearningPathScreen(),
    VocabularyScreen(),
    GlassLeaderboardScreen(),
    CulturalMediaScreen(),
    GlassProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Permite que el contenido se extienda detrás de la barra flotante de cristal
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          GlassNavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map_rounded,
            label: 'Aprender',
          ),
          GlassNavItem(
            icon: Icons.style_outlined,
            activeIcon: Icons.style_rounded,
            label: 'Vocabulario',
          ),
          GlassNavItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events_rounded,
            label: 'Liga',
          ),
          GlassNavItem(
            icon: Icons.music_note_outlined,
            activeIcon: Icons.music_note_rounded,
            label: 'Cultura',
          ),
          GlassNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
