import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';

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
    'Música',
    'Deportes',
    'Lectura',
    'Arte',
    'Cocina',
    'Tecnología',
    'Naturaleza',
    'Viajes',
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

  Future<void> _saveChanges() async {
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
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Editar Perfil'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppStyles.screenPadding,
          children: [
            // Información básica (no editable)
            Container(
              padding: AppStyles.cardPadding,
              decoration: AppStyles.cardDecoration,
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final user = provider.user;
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            AppColors.primaryOrange.withOpacity(0.1),
                        child: Text(
                          user?.firstName.substring(0, 1).toUpperCase() ?? 'Y',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppStyles.spacingM),
                      Text(
                        user?.fullName ?? '',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.lightText,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppStyles.spacingL),

            Text('Información de contacto', style: AppTextStyles.h4),
            const SizedBox(height: AppStyles.spacingM),

            // Teléfono
            TextFormField(
              controller: _telefonoCtrl,
              decoration: AppStyles.inputDecoration(
                labelText: 'Teléfono',
                icon: Icons.phone_outlined,
                hintText: 'Ingresa tu número de teléfono',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppStyles.spacingM),

            // Localidad
            TextFormField(
              controller: _localidadCtrl,
              decoration: AppStyles.inputDecoration(
                labelText: 'Localidad',
                icon: Icons.location_on_outlined,
                hintText: 'Ingresa tu localidad',
              ),
            ),
            const SizedBox(height: AppStyles.spacingL),

            Text('Intereses', style: AppTextStyles.h4),
            const SizedBox(height: AppStyles.spacingM),

            // Gustos/Intereses
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableGustos.map((gusto) {
                final isSelected = _selectedGustos.contains(gusto);
                return FilterChip(
                  label: Text(gusto),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGustos.add(gusto);
                      } else {
                        _selectedGustos.remove(gusto);
                      }
                    });
                  },
                  backgroundColor: AppColors.backgroundWhite,
                  selectedColor: AppColors.primaryOrange.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryOrange,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.darkText,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.smallBorderRadius,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.lightText.withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppStyles.spacingXL),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: AppStyles.primaryButton,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.whiteText,
                          ),
                        ),
                      )
                    : const Text('Guardar cambios'),
              ),
            ),
            const SizedBox(height: AppStyles.spacingM),

            // Botón cancelar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: AppStyles.outlinedButton,
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
