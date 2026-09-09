import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icons.dart';
import '../../models/vocabulary_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_styles.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_sheet.dart';
import '../../widgets/common/glass_icon_badge.dart';
import '../../widgets/common/native_audio_button.dart';
import '../../widgets/gamification/glass_hud_bar.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  // 0: Modo Tarjetas SRS (Stellar experience), 1: Modo Diccionario
  int _selectedMode = 0;

  // Estado del motor SRS
  int _srsIndex = 0;
  bool _showBack = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Estado del diccionario
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadVocabularyCategories();
      provider.loadVocabularyEntries();
      provider.loadWordOfTheDay();
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.selectionClick();
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  Future<void> _setMasteryAndNext(
      VocabularyEntryModel entry, int masteryLevel, int totalEntries) async {
    HapticFeedback.mediumImpact();
    final provider = context.read<AppProvider>();
    await provider.updateWordMastery(entry.id, masteryLevel);

    if (_srsIndex < totalEntries - 1) {
      if (_showBack) {
        _flipController.reverse();
        _showBack = false;
      }
      setState(() {
        _srsIndex++;
      });
    } else {
      _showSrsCompletedSheet(totalEntries);
    }
  }

  void _showSrsCompletedSheet(int totalCards) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    GlassSheet.show(
      context: context,
      isDismissible: false,
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GlassIconBadge(
            icon: AppIcons.sparkle,
            color: AppIcons.vocabColor,
            size: 68,
            iconSize: 34,
            borderRadius: 34,
          ),
          const SizedBox(height: 16),
          Text(
            '¡Sesión SRS Completada!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Has practicado $totalCards palabras en Wayuunaiki con audio nativo. Tu curva de retención ha sido actualizada con éxito.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  text: 'Repetir',
                  icon: Icons.refresh_rounded,
                  variant: GlassButtonVariant.glass,
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    setState(() {
                      _srsIndex = 0;
                      if (_showBack) {
                        _flipController.reverse();
                        _showBack = false;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  text: 'Ver Diccionario',
                  icon: Icons.menu_book_rounded,
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    setState(() {
                      _selectedMode = 1;
                      _srsIndex = 0;
                      if (_showBack) {
                        _flipController.reverse();
                        _showBack = false;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onCategorySelected(String? categorySlug) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategory =
          _selectedCategory == categorySlug ? null : categorySlug;
    });
    context.read<AppProvider>().loadVocabularyEntries(
          category: _selectedCategory,
          search: _searchController.text.trim(),
        );
  }

  void _onSearchChanged(String query) {
    context.read<AppProvider>().loadVocabularyEntries(
          category: _selectedCategory,
          search: query.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Barra HUD Superior de Gamificación
              const GlassHudBar(),

              // Segmented Control de Modo (Tarjetas SRS vs Diccionario)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _buildModeToggle(isDark),
              ),

              // Cuerpo según el Modo Activo
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    final entries = provider.vocabularyEntries;

                    if (_selectedMode == 0) {
                      return _buildSrsFlashcardView(entries, isDark, provider);
                    } else {
                      return _buildDictionaryView(provider, isDark);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Segmented Mode Toggle
  Widget _buildModeToggle(bool isDark) {
    return GlassContainer(
      height: 48,
      borderRadius: BorderRadius.circular(24),
      backgroundColor: isDark
          ? Colors.white.withOpacity(0.07)
          : Colors.black.withOpacity(0.04),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              label: 'Tarjetas SRS',
              icon: AppIcons.vocabulary,
              isSelected: _selectedMode == 0,
              isDark: isDark,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMode = 0);
              },
            ),
          ),
          Expanded(
            child: _buildToggleItem(
              label: 'Diccionario',
              icon: Icons.menu_book_rounded,
              isSelected: _selectedMode == 1,
              isDark: isDark,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMode = 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? (isDark ? Colors.white.withOpacity(0.18) : Colors.white)
              : Colors.transparent,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected
                    ? AppColors.primaryOrange
                    : (isDark ? Colors.white60 : AppColors.lightText),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.darkText)
                      : (isDark ? Colors.white60 : AppColors.lightText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODO 0: VISTA ESTELAR SRS FLASHCARDS 3D
  // ==========================================
  Widget _buildSrsFlashcardView(
    List<VocabularyEntryModel> entries,
    bool isDark,
    AppProvider provider,
  ) {
    if (provider.isLoading && entries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: GlassCard(
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlassIconBadge(
                  icon: Icons.style_outlined,
                  color: AppColors.primaryOrange,
                  size: 56,
                  iconSize: 28,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay tarjetas pendientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Has repasado todas las tarjetas por ahora o aún no se han cargado palabras.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.white70 : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 20),
                GlassButton(
                  text: 'Explorar Diccionario',
                  icon: Icons.menu_book_rounded,
                  onPressed: () => setState(() => _selectedMode = 1),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Asegurar índice dentro de los límites
    if (_srsIndex >= entries.length) {
      _srsIndex = 0;
    }

    final entry = entries[_srsIndex];
    final progress = (_srsIndex + 1) / entries.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        children: [
          // Barra de progreso SRS compacta
          Row(
            children: [
              Text(
                'Tarjeta ${_srsIndex + 1} de ${entries.length}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.lightText,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 14),

          // Tarjeta Central 3D Flip
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * pi;
                    final isBackVisible = angle >= (pi / 2);

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspectiva 3D realista
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isBackVisible
                          ? Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildBackCard(entry, isDark),
                            )
                          : _buildFrontCard(entry, isDark),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Indicador de toque / instrucción
          Text(
            _showBack
                ? '¿Qué tan bien recuerdas esta palabra?'
                : 'Toca la tarjeta para ver la traducción',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),

          // 3 Botones inferiores ergonómicos para el algoritmo SRS
          Row(
            children: [
              _buildErgonomicSrsButton(
                level: 1,
                label: 'Difícil',
                sublabel: 'Repasar pronto',
                icon: Icons.trending_down_rounded,
                color: const Color(0xFFEF4444),
                entry: entry,
                totalEntries: entries.length,
              ),
              const SizedBox(width: 8),
              _buildErgonomicSrsButton(
                level: 2,
                label: 'Bien',
                sublabel: 'Familiar',
                icon: Icons.remove_circle_outline_rounded,
                color: AppColors.primaryBlue,
                entry: entry,
                totalEntries: entries.length,
              ),
              const SizedBox(width: 8),
              _buildErgonomicSrsButton(
                level: 3,
                label: 'Fácil',
                sublabel: 'Dominada',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.successGreen,
                entry: entry,
                totalEntries: entries.length,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard(VocabularyEntryModel entry, bool isDark) {
    return GlassCard(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      width: double.infinity,
      borderGradient: LinearGradient(
        colors: [
          AppColors.primaryOrange.withOpacity(0.7),
          AppColors.primaryOrange.withOpacity(0.15),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header de la tarjeta frontal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.translate_rounded,
                        size: 13, color: AppColors.primaryOrange),
                    SizedBox(width: 4),
                    Text(
                      'WAYUUNAIKI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.audioPronunciation != null)
                NativeAudioButton(
                  audioUrl: entry.audioPronunciation,
                  size: 42,
                  activeColor: AppColors.primaryOrange,
                ),
            ],
          ),

          // Centro: Palabra en Wayuunaiki y fonética
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.wayuunaikiTranslation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : AppColors.darkText,
                ),
              ),
              if (entry.phoneticTranscription != null &&
                  entry.phoneticTranscription!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '[ ${entry.phoneticTranscription} ]',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white60 : AppColors.lightText,
                  ),
                ),
              ],
            ],
          ),

          // Footer: Indicador de toque para voltear
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(width: 6),
              Text(
                'Toca para ver traducción',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(VocabularyEntryModel entry, bool isDark) {
    return GlassCard(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      width: double.infinity,
      borderGradient: LinearGradient(
        colors: [
          AppColors.primaryBlue.withOpacity(0.7),
          AppColors.primaryBlue.withOpacity(0.15),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header de la tarjeta trasera
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag_outlined,
                        size: 13, color: AppColors.primaryBlue),
                    SizedBox(width: 4),
                    Text(
                      'ESPAÑOL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.audioPronunciation != null)
                NativeAudioButton(
                  audioUrl: entry.audioPronunciation,
                  size: 42,
                  activeColor: AppColors.primaryBlue,
                ),
            ],
          ),

          // Centro: Término en español y ejemplos
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.spanishTerm,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              if (entry.examples.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '"${entry.examples.first}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                      color: isDark ? Colors.white70 : AppColors.darkText,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Footer: Indicador de toque para volver
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.autorenew_rounded,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(width: 6),
              Text(
                'Toca para volver a Wayuunaiki',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErgonomicSrsButton({
    required int level,
    required String label,
    required String sublabel,
    required IconData icon,
    required Color color,
    required VocabularyEntryModel entry,
    required int totalEntries,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => _setMasteryAndNext(entry, level, totalEntries),
        borderRadius: BorderRadius.circular(16),
        child: GlassContainer(
          height: 54,
          borderRadius: BorderRadius.circular(16),
          backgroundColor: color.withOpacity(0.16),
          borderGradient: LinearGradient(
            colors: [color.withOpacity(0.7), color.withOpacity(0.12)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODO 1: VISTA DE DICCIONARIO BUSCABLE
  // ==========================================
  Widget _buildDictionaryView(AppProvider provider, bool isDark) {
    final categories = provider.vocabularyCategories;
    final entries = provider.vocabularyEntries;
    final wordOfTheDay = provider.wordOfTheDay;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          provider.loadVocabularyCategories(),
          provider.loadVocabularyEntries(
            category: _selectedCategory,
            search: _searchController.text.trim(),
          ),
          provider.loadWordOfTheDay(),
        ]);
      },
      color: AppColors.primaryOrange,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
        children: [
          // 1. Hero: Palabra del Día
          if (wordOfTheDay != null) ...[
            _buildWordOfTheDayCard(wordOfTheDay, isDark),
            const SizedBox(height: 16),
          ],

          // 2. Buscador en Cristal
          GlassContainer(
            height: 50,
            borderRadius: BorderRadius.circular(25),
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.85),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: isDark ? Colors.white54 : AppColors.lightText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar en Wayuunaiki o Español...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    child: const Icon(Icons.close_rounded, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Filtros de Categorías horizontales
          if (categories.isNotEmpty) ...[
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isAll = _selectedCategory == null;
                    return _buildCategoryChip('Todos', null, isAll, isDark);
                  }
                  final cat = categories[index - 1];
                  final isSelected = _selectedCategory == cat.slug;
                  return _buildCategoryChip(
                      cat.name, cat.slug, isSelected, isDark);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 4. Lista de Palabras
          if (entries.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No se encontraron palabras para este filtro.',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : AppColors.lightText,
                  ),
                ),
              ),
            ),
          ] else ...[
            ...entries.map((entry) => _buildVocabularyItem(entry, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildWordOfTheDayCard(VocabularyEntryModel word, bool isDark) {
    return GlassCard(
      borderRadius: BorderRadius.circular(24),
      borderGradient: LinearGradient(
        colors: [
          AppColors.primaryOrange.withOpacity(0.8),
          AppColors.primaryBlue.withOpacity(0.3),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.sparkle,
                        size: 13, color: AppColors.primaryOrange),
                    SizedBox(width: 4),
                    Text(
                      'PALABRA DEL DÍA',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              if (word.audioPronunciation != null)
                NativeAudioButton(
                  audioUrl: word.audioPronunciation,
                  size: 42,
                  activeColor: AppColors.primaryOrange,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            word.wayuunaikiTranslation,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkText,
            ),
          ),
          if (word.phoneticTranscription != null) ...[
            const SizedBox(height: 2),
            Text(
              '[ ${word.phoneticTranscription} ]',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white60 : AppColors.lightText,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            word.spanishTerm,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          if (word.examples.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '"${word.examples.first}"',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : AppColors.darkText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
      String label, String? slug, bool isSelected, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _onCategorySelected(slug),
        borderRadius: BorderRadius.circular(19),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(19),
          backgroundColor: isSelected
              ? AppColors.primaryOrange.withOpacity(isDark ? 0.35 : 0.22)
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.8)),
          borderGradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryOrange,
                    AppColors.primaryOrange.withOpacity(0.3),
                  ],
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryOrange
                    : (isDark ? Colors.white70 : AppColors.darkText),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVocabularyItem(VocabularyEntryModel entry, bool isDark) {
    Color masteryColor;
    switch (entry.masteryLevel) {
      case 3:
        masteryColor = AppColors.successGreen;
        break;
      case 2:
        masteryColor = AppColors.primaryBlue;
        break;
      case 1:
        masteryColor = const Color(0xFFEF4444);
        break;
      default:
        masteryColor = const Color(0xFF94A3B8);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.wayuunaikiTranslation,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: masteryColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.masteryLevelName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: masteryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.spanishTerm,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white70 : AppColors.lightText,
                    ),
                  ),
                  if (entry.phoneticTranscription != null &&
                      entry.phoneticTranscription!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '[ ${entry.phoneticTranscription} ]',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (entry.audioPronunciation != null)
              NativeAudioButton(
                audioUrl: entry.audioPronunciation,
                size: 40,
              ),
          ],
        ),
      ),
    );
  }
}

