import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Catálogo centralizado de iconos vectoriales de alta fidelidad para Yonna App.
/// Reemplaza completamente el uso de emojis por iconos limpios, nítidos y adaptables.
class AppIcons {
  AppIcons._();

  // --- Gamificación & Rachas ---
  static const IconData streak = Icons.local_fire_department_rounded;
  static const IconData freezeToken = Icons.ac_unit_rounded;
  static const IconData xp = Icons.bolt_rounded;
  static const IconData diamond = Icons.diamond_rounded;
  static const IconData level = Icons.trending_up_rounded;

  // --- Podio & Clasificación ---
  static const IconData crown = Icons.workspace_premium_rounded;
  static const IconData trophy = Icons.emoji_events_rounded;
  static const IconData medalGold = Icons.military_tech_rounded;
  static const IconData medalSilver = Icons.military_tech_rounded;
  static const IconData medalBronze = Icons.military_tech_outlined;
  static const IconData leaderboard = Icons.leaderboard_rounded;

  // --- Insignias & Logros ---
  static const IconData badge = Icons.verified_rounded;
  static const IconData shield = Icons.shield_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData sparkle = Icons.auto_awesome_rounded;

  // --- Aprendizaje & Evaluación ---
  static const IconData lesson = Icons.auto_stories_rounded;
  static const IconData quiz = Icons.quiz_rounded;
  static const IconData success = Icons.check_circle_rounded;
  static const IconData error = Icons.cancel_rounded;
  static const IconData tip = Icons.lightbulb_rounded;
  static const IconData celebrate = Icons.celebration_rounded;
  static const IconData speed = Icons.speed_rounded;

  // --- Vocabulario & Diccionario ---
  static const IconData vocabulary = Icons.style_rounded;
  static const IconData flashcard = Icons.flip_to_front_rounded;
  static const IconData srsMastered = Icons.done_all_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData category = Icons.category_rounded;

  // --- Audio & Multimedia Cultural ---
  static const IconData audioSpeaker = Icons.volume_up_rounded;
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData music = Icons.music_note_rounded;
  static const IconData story = Icons.menu_book_rounded;

  // --- Configuración & Perfil ---
  static const IconData profile = Icons.person_rounded;
  static const IconData settings = Icons.tune_rounded;
  static const IconData themeMode = Icons.palette_rounded;
  static const IconData lightMode = Icons.light_mode_rounded;
  static const IconData darkMode = Icons.dark_mode_rounded;
  static const IconData systemMode = Icons.brightness_auto_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData notification = Icons.notifications_rounded;
  static const IconData edit = Icons.edit_rounded;

  // --- Colores Característicos de Iconos ---
  static const Color streakColor = Color(0xFFFF6D00);      // Naranja Fuego
  static const Color freezeColor = Color(0xFF00D2FF);      // Azul Hielo
  static const Color xpColor = Color(0xFFFFB703);          // Ámbar Dorado
  static const Color goldColor = Color(0xFFFFD700);        // Oro
  static const Color silverColor = Color(0xFFB0BEC5);      // Plata
  static const Color bronzeColor = Color(0xFFCD7F32);      // Bronce
  static const Color successColor = Color(0xFF00C853);     // Verde Victoria
  static const Color culturalColor = Color(0xFF00B4D8);    // Turquesa Caribe
  static const Color vocabColor = Color(0xFF9D4EDD);       // Púrpura Sabiduría
}
