import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icons.dart';
import '../../models/vocabulary_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_styles.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/common/glass_icon_badge.dart';
import '../../widgets/common/native_audio_button.dart';
import '../../widgets/gamification/glass_hud_bar.dart';
import 'flashcard_srs_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadVocabularyCategories();
      provider.loadVocabularyEntries();
      provider.loadWordOfTheDay();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String? categorySlug) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategory = _selectedCategory == categorySlug ? null : categorySlug;
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
              // Barra HUD Superior
              const GlassHudBar(),

              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                        children: [
                          // 1. Hero: Palabra del Día
                          if (wordOfTheDay != null) ...[
                            _buildWordOfTheDayCard(wordOfTheDay, isDark),
                            const SizedBox(height: 16),
                          ],

                          // 2. Banner de Repaso Espaciado (SRS Flashcards)
                          _buildSrsBanner(entries, isDark),
                          const SizedBox(height: 18),

                          // 3. Buscador en Cristal
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

                          // 4. Filtros de Categorías horizontales
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
                                  return _buildCategoryChip(cat.name, cat.slug, isSelected, isDark);
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 5. Lista de Palabras
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
                  },
                ),
              ),
            ],
          ),
        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.sparkle, size: 13, color: AppColors.primaryOrange),
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

  Widget _buildSrsBanner(List<VocabularyEntryModel> entries, bool isDark) {
    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      backgroundColor: AppColors.primaryBlue.withOpacity(isDark ? 0.20 : 0.12),
      borderGradient: LinearGradient(
        colors: [
          AppColors.primaryBlue.withOpacity(0.6),
          AppColors.primaryBlue.withOpacity(0.1),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      onTap: () {
        if (entries.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FlashcardSrsScreen(entries: entries),
            ),
          );
        }
      },
      child: Row(
        children: [
          const GlassIconBadge(
            icon: AppIcons.vocabulary,
            color: AppIcons.vocabColor,
            size: 44,
            iconSize: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sesión de Repaso Espaciado',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Text(
                  'Practica tus tarjetas con audio nativo y algoritmo SRS',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? slug, bool isSelected, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _onCategorySelected(slug),
        borderRadius: BorderRadius.circular(19),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(19),
          backgroundColor: isSelected
              ? AppColors.primaryOrange.withOpacity(isDark ? 0.35 : 0.22)
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.8)),
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
        masteryColor = const Color(0xFFF59E0B);
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  if (entry.phoneticTranscription != null) ...[
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
