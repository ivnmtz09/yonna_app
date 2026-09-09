import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/network/network_config.dart';
import '../../widgets/app_styles.dart';
import '../common/glass_icon_badge.dart';
import 'glass_button.dart';
import 'glass_sheet.dart';

class GlassConnectionSheet extends StatefulWidget {
  final VoidCallback? onConnected;

  const GlassConnectionSheet({super.key, this.onConnected});

  static Future<void> show(BuildContext context, {VoidCallback? onConnected}) {
    return GlassSheet.show(
      context: context,
      builder: (ctx) => GlassConnectionSheet(onConnected: onConnected),
    );
  }

  @override
  State<GlassConnectionSheet> createState() => _GlassConnectionSheetState();
}

class _GlassConnectionSheetState extends State<GlassConnectionSheet> {
  final _networkConfig = NetworkConfig();
  late TextEditingController _hostController;
  late TextEditingController _portController;
  bool _isTesting = false;
  NetworkHealthResult? _healthResult;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: _networkConfig.host);
    _portController = TextEditingController(text: _networkConfig.port.toString());
    _testCurrentConnection();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _testCurrentConnection() async {
    setState(() => _isTesting = true);
    final result = await _networkConfig.checkHealth();
    if (mounted) {
      setState(() {
        _healthResult = result;
        _isTesting = false;
      });
      if (result.isReachable) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    }
  }

  Future<void> _applyAndSave() async {
    final newHost = _hostController.text.trim();
    final newPort = int.tryParse(_portController.text.trim()) ?? 8000;
    if (newHost.isEmpty) return;

    await _networkConfig.setHost(newHost, newPort);
    await _testCurrentConnection();

    if (_healthResult?.isReachable == true) {
      if (widget.onConnected != null) {
        widget.onConnected!();
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conexión establecida con éxito.'),
            backgroundColor: AppColors.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _selectPreset(String host) {
    HapticFeedback.selectionClick();
    setState(() {
      _hostController.text = host;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReachable = _healthResult?.isReachable ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Row(
          children: [
            GlassIconBadge(
              icon: isReachable ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: isReachable ? AppColors.successGreen : AppColors.primaryOrange,
              size: 44,
              iconSize: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servidor Backend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  Text(
                    _networkConfig.serverUrl,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (isReachable ? AppColors.successGreen : AppColors.errorRed)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isReachable ? AppColors.successGreen : AppColors.errorRed)
                      .withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Text(
                isReachable ? 'ACTIVO' : 'OFFLINE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isReachable ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Diagnóstico / Mensaje del servidor
        if (_healthResult != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isReachable ? AppColors.successGreen : AppColors.primaryOrange)
                  .withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isReachable ? AppColors.successGreen : AppColors.primaryOrange)
                    .withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isReachable ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  size: 18,
                  color: isReachable ? AppColors.successGreen : AppColors.primaryOrange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _healthResult!.message,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 18),

        // Presets Rápidos
        Text(
          'Configuración Rápida de Host:',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPresetChip(
              label: '127.0.0.1 (USB/ADB)',
              host: NetworkConfig.presetUsbAdb,
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildPresetChip(
              label: '10.0.2.2 (Emulador)',
              host: NetworkConfig.presetEmulator,
              isDark: isDark,
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Inputs de Host y Puerto
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _hostController,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.darkText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'Host / Dirección IP',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white60 : AppColors.lightText,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.darkText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'Puerto',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white60 : AppColors.lightText,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Botones de acción
        Row(
          children: [
            Expanded(
              child: GlassButton(
                text: 'Probar Conexión',
                variant: GlassButtonVariant.glass,
                isLoading: _isTesting,
                icon: Icons.refresh_rounded,
                onPressed: _testCurrentConnection,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassButton(
                text: 'Guardar y Usar',
                variant: GlassButtonVariant.primary,
                isLoading: _isTesting,
                icon: Icons.save_rounded,
                onPressed: _applyAndSave,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip({
    required String label,
    required String host,
    required bool isDark,
  }) {
    final isSelected = _hostController.text.trim() == host;
    return InkWell(
      onTap: () => _selectPreset(host),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withValues(alpha: 0.2)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : (isDark ? Colors.white12 : Colors.black12),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AppColors.primaryOrange
                : (isDark ? Colors.white70 : AppColors.darkText),
          ),
        ),
      ),
    );
  }
}
