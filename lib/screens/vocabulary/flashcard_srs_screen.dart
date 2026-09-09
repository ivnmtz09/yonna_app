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

class FlashcardSrsScreen extends StatefulWidget {
  final List<VocabularyEntryModel> entries;

  const FlashcardSrsScreen({super.key, required this.entries});

  @override
  State<FlashcardSrsScreen> createState() => _FlashcardSrsScreenState();
}

class _FlashcardSrsScreenState extends State<FlashcardSrsScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showBack = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
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

  Future<void> _setMasteryAndNext(int masteryLevel) async {
    HapticFeedback.mediumImpact();
    final entry = widget.entries[_currentIndex];
    final provider = context.read<AppProvider>();

    await provider.updateWordMastery(entry.id, masteryLevel);

    if (_currentIndex < widget.entries.length - 1) {
      if (_showBack) {
        _flipController.reverse();
        _showBack = false;
      }
      setState(() {
        _currentIndex++;
      });
    } else {
      _showCompletionSheet();
    }
  }

  void _showCompletionSheet() {
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
            size: 64,
            iconSize: 32,
            borderRadius: 32,
          ),
          const SizedBox(height: 16),
          Text(
            '¡Repaso SRS Completado!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Has practicado ${widget.entries.length} palabras en Wayuunaiki. El algoritmo espaciado programará tu próxima sesión.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 24),
          GlassButton(
            text: 'Volver al Diccionario',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () {
              Navigator.pop(sheetCtx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return GlassBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Repaso Espaciado')),
          body: const Center(
            child: Text('No hay tarjetas pendientes para repasar hoy.'),
          ),
        ),
      );
    }

    final entry = widget.entries[_currentIndex];
    final progress = (_currentIndex + 1) / widget.entries.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Repaso Espaciado (SRS)'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
              minHeight: 4,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'Tarjeta ${_currentIndex + 1} de ${widget.entries.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : AppColors.lightText,
                ),
              ),

              // Tarjeta 3D Flip
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
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
                              ..setEntry(3, 2, 0.001) // perspectiva 3D
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
              ),

              // Controles de Maestría (SRS)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    Text(
                      _showBack
                          ? '¿Qué tan bien dominas esta palabra?'
                          : 'Toca la tarjeta para ver la traducción',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMasteryBtn(1, 'Difícil', const Color(0xFFEF4444)),
                        const SizedBox(width: 8),
                        _buildMasteryBtn(2, 'Bien', AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        _buildMasteryBtn(3, 'Fácil', AppColors.successGreen),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(VocabularyEntryModel entry, bool isDark) {
    return GlassCard(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      height: 380,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'WAYUUNAIKI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            entry.wayuunaikiTranslation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkText,
            ),
          ),
          if (entry.phoneticTranscription != null) ...[
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
          const SizedBox(height: 28),
          if (entry.audioPronunciation != null)
            NativeAudioButton(
              audioUrl: entry.audioPronunciation,
              size: 58,
              activeColor: AppColors.primaryOrange,
            ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(width: 6),
              Text(
                'Toca para voltear',
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
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      height: 380,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'ESPAÑOL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            entry.spanishTerm,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          if (entry.examples.isNotEmpty) ...[
            Text(
              'Ejemplo:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '"${entry.examples.first}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : AppColors.darkText,
              ),
            ),
          ],
          if (entry.audioPronunciation != null) ...[
            const SizedBox(height: 16),
            NativeAudioButton(
              audioUrl: entry.audioPronunciation,
              size: 52,
              activeColor: AppColors.primaryBlue,
            ),
          ],
          const Spacer(),
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
                'Toca para volver al frente',
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

  Widget _buildMasteryBtn(int level, String label, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () => _setMasteryAndNext(level),
        borderRadius: BorderRadius.circular(14),
        child: GlassContainer(
          height: 48,
          borderRadius: BorderRadius.circular(14),
          backgroundColor: color.withOpacity(0.18),
          borderGradient: LinearGradient(
            colors: [color.withOpacity(0.6), color.withOpacity(0.1)],
          ),
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
