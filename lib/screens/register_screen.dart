import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_button.dart';
import '../widgets/glass/glass_card.dart';
import '../widgets/glass/glass_connection_sheet.dart';
import '../widgets/glass/glass_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final success = await provider.register(
      email: _emailCtrl.text.trim(),
      password1: _passwordCtrl.text,
      password2: _confirmPasswordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Ya puedes iniciar sesión'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final errorMsg = provider.error ?? 'Error al registrarse';
      final isConnectionIssue = errorMsg.contains('servidor') ||
          errorMsg.contains('conectar') ||
          errorMsg.contains('red') ||
          errorMsg.contains('Django');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 4),
          action: isConnectionIssue
              ? SnackBarAction(
                  label: 'Configurar',
                  textColor: Colors.white,
                  onPressed: () => GlassConnectionSheet.show(context),
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushReplacementNamed(context, '/welcome');
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            GlassConnectionSheet.show(context);
                          },
                          borderRadius: BorderRadius.circular(21),
                          child: GlassContainer(
                            width: 42,
                            height: 42,
                            borderRadius: BorderRadius.circular(21),
                            padding: EdgeInsets.zero,
                            child: Icon(
                              Icons.dns_rounded,
                              size: 19,
                              color: isDark ? Colors.white : AppColors.darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            themeProvider.cycleThemeMode();
                          },
                          borderRadius: BorderRadius.circular(21),
                          child: GlassContainer(
                            width: 42,
                            height: 42,
                            borderRadius: BorderRadius.circular(21),
                            padding: EdgeInsets.zero,
                            child: Icon(
                              themeProvider.themeIcon,
                              size: 19,
                              color: isDark ? Colors.white : AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Únete a la comunidad de aprendizaje Wayuunaiki',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? Colors.white60 : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Formulario en GlassCard
                        GlassCard(
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _firstNameCtrl,
                                      label: 'Nombre',
                                      icon: Icons.badge_outlined,
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _lastNameCtrl,
                                      label: 'Apellido',
                                      icon: Icons.badge_outlined,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              _buildTextField(
                                controller: _emailCtrl,
                                label: 'Correo Electrónico',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                isDark: isDark,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Campo requerido';
                                  if (!v.contains('@')) return 'Correo no válido';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              _buildTextField(
                                controller: _passwordCtrl,
                                label: 'Contraseña',
                                icon: Icons.lock_outline_rounded,
                                isDark: isDark,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: isDark ? Colors.white54 : AppColors.lightText,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              _buildTextField(
                                controller: _confirmPasswordCtrl,
                                label: 'Confirmar Contraseña',
                                icon: Icons.lock_outline_rounded,
                                isDark: isDark,
                                obscureText: _obscureConfirm,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: isDark ? Colors.white54 : AppColors.lightText,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                                validator: (v) {
                                  if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),

                              Consumer<AppProvider>(
                                builder: (context, provider, child) {
                                  return GlassButton(
                                    text: 'REGISTRARME',
                                    icon: Icons.person_add_rounded,
                                    isPrimary: true,
                                    isLoading: provider.isLoading,
                                    height: 50,
                                    width: double.infinity,
                                    onPressed: _register,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes una cuenta? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : AppColors.lightText,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                              child: const Text(
                                'Inicia sesión',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
        suffixIcon: suffixIcon,
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
      validator: validator,
    );
  }
}
