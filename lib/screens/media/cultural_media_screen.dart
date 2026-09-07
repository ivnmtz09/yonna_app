import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/media_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_styles.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/common/native_audio_button.dart';
import '../../widgets/gamification/glass_hud_bar.dart';

class CulturalMediaScreen extends StatefulWidget {
  const CulturalMediaScreen({super.key});

  @override
  State<CulturalMediaScreen> createState() => _CulturalMediaScreenState();
}

class _CulturalMediaScreenState extends State<CulturalMediaScreen> {
  String _selectedFilter = 'all'; // all, audio, video

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadMediaContent();
      provider.loadMediaCollections();
    });
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
                    final items = provider.mediaItems;

                    final filtered = items.where((item) {
                      if (_selectedFilter == 'audio') return item.mediaType == 'audio';
                      if (_selectedFilter == 'video') return item.mediaType == 'video';
                      return true;
                    }).toList();

                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([
                          provider.loadMediaContent(),
                          provider.loadMediaCollections(),
                        ]);
                      },
                      color: AppColors.primaryOrange,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                        children: [
                          // Header explicativo
                          Text(
                            'Biblioteca Cultural Wayuu',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Relatos orales, música tradicional y registros culturales.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 18),

                          if (filtered.isEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No hay contenido multimedia disponible por el momento.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : AppColors.lightText,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            ...filtered.map((item) => _buildMediaCard(item, isDark)),
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

  Widget _buildMediaCard(MediaItemModel item, bool isDark) {
    final isAudio = item.mediaType == 'audio';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isAudio
                    ? AppColors.primaryBlue.withOpacity(0.2)
                    : AppColors.primaryOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isAudio ? Icons.headphones_rounded : Icons.play_circle_fill_rounded,
                color: isAudio ? AppColors.primaryBlue : AppColors.primaryOrange,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description.isNotEmpty
                        ? item.description
                        : (isAudio ? 'Relato oral en Wayuunaiki' : 'Video educativo'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white60 : AppColors.lightText,
                    ),
                  ),
                  if (item.duration > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      '⏱️ ${item.durationFormatted}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isAudio && item.fileUrl.isNotEmpty)
              NativeAudioButton(
                audioUrl: item.fileUrl,
                size: 44,
                activeColor: AppColors.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }
}
