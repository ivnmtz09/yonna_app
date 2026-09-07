import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/audio/audio_service.dart';
import '../../widgets/app_styles.dart';
import '../glass/glass_container.dart';

class NativeAudioButton extends StatelessWidget {
  final String? audioUrl;
  final double size;
  final Color? activeColor;
  final String? tooltip;

  const NativeAudioButton({
    super.key,
    required this.audioUrl,
    this.size = 46.0,
    this.activeColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (audioUrl == null || audioUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audioService = AudioService();
    final primaryAccent = activeColor ?? AppColors.primaryBlue;

    return StreamBuilder<PlayerState>(
      stream: audioService.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isCurrent = audioService.currentUrl == audioUrl;
        final isPlaying = isCurrent && (state?.playing ?? false);
        final isBuffering = isCurrent &&
            (state?.processingState == ProcessingState.buffering ||
                state?.processingState == ProcessingState.loading);

        return Tooltip(
          message: tooltip ?? 'Escuchar pronunciación nativa',
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              audioService.playUrl(audioUrl!);
            },
            borderRadius: BorderRadius.circular(size / 2),
            child: GlassContainer(
              width: size,
              height: size,
              borderRadius: BorderRadius.circular(size / 2),
              backgroundColor: isPlaying
                  ? primaryAccent.withOpacity(isDark ? 0.35 : 0.25)
                  : (isDark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.white.withOpacity(0.85)),
              borderGradient: isPlaying
                  ? LinearGradient(
                      colors: [primaryAccent, primaryAccent.withOpacity(0.3)],
                    )
                  : null,
              padding: EdgeInsets.zero,
              child: Center(
                child: isBuffering
                    ? SizedBox(
                        width: size * 0.45,
                        height: size * 0.45,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryAccent,
                        ),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        size: size * 0.52,
                        color: isPlaying
                            ? primaryAccent
                            : (isDark ? Colors.white : AppColors.darkText),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
