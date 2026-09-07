import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_button.dart';
import '../widgets/glass/glass_card.dart';
import '../widgets/glass/glass_container.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telefonoCtrl = TextEditingController();
  final _localidadCtrl = TextEditingController();
  final List<String> _selectedGustos = [];

  bool _isLoading = false;

  final List<String> _availableGustos = [
    'Música Wayuu',
    'Artesanías y Kanasü',
    'Relatos y Tradición Oral',
    'Danza Yonna',
    'Gastronomía Guajira',
    'Historia y Territorio',
    'Lengua y Fonética',
    'Sabiduría Ancestral',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().user;
    if (user != null) {
      _telefonoCtrl.text = user.telefono ?? '';
      _localidadCtrl.text = user.localidad ?? '';
      if (user.gustos != null) {
        _selectedGustos.addAll(user.gustos!);
      }
    }
  }

  @override
  void dispose() {
    _telefonoCtrl.dispose();
    _localidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<AppProvider>();
    final success = await provider.updateProfile(
      telefono: _telefonoCtrl.text.trim(),
      localidad: _localidadCtrl.text.trim(),
      gustos: _selectedGustos,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al actualizar perfil'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior minimalista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(21),
                      child: GlassContainer(
                        width: 42,
                        height: 42,
                        borderRadius: BorderRadius.circular(21),
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Editar Perfil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          borderRadius: BorderRadius.circular(22),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INFORMACIÓN DE CONTACTO',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: isDark ? Colors.white60 : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 14),

                              _buildTextField(
                                controller: _telefonoCtrl,
                                label: 'Teléfono',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 14),

                              _buildTextField(
                                controller: _localidadCtrl,
                                label: 'Localidad / Municipio (ej: Uribia, Riohacha)',
                                icon: Icons.location_on_outlined,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        GlassCard(
                          borderRadius: BorderRadius.circular(22),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INTERESES Y TEMAS CULTURALES',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: isDark ? Colors.white60 : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Selecciona los temas de tu preferencia para adaptar recomendaciones:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white60 : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 14),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableGustos.map((gusto) {
                                  final isSelected = _selectedGustos.contains(gusto);
                                  return FilterChip(
                                    label: Text(gusto),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        if (selected) {
                                          _selectedGustos.add(gusto);
                                        } else {
                                          _selectedGustos.remove(gusto);
                                        }
                                      });
                                    },
                                    selectedColor: AppColors.primaryOrange.withValues(alpha: 0.25),
                                    checkmarkColor: AppColors.primaryOrange,
                                    labelStyle: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primaryOrange
                                          : (isDark ? Colors.white70 : AppColors.darkText),
                                    ),
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.black.withValues(alpha: 0.04),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.primaryOrange
                                            : (isDark ? Colors.white12 : Colors.black12),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        GlassButton(
                          text: 'GUARDAR CAMBIOS',
                          icon: Icons.check_rounded,
                          isPrimary: true,
                          isLoading: _isLoading,
                          height: 50,
                          width: double.infinity,
                          onPressed: _saveProfile,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.darkText,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : AppColors.lightText,
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryOrange, size: 20),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryOrange,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
