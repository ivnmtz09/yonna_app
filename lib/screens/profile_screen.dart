import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/xp_progress_bar.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del perfil cuando se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadUserData();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final provider = context.read<AppProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await provider.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final user = provider.user;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            );
          }

          return SingleChildScrollView(
            padding: AppStyles.screenPadding,
            child: Column(
              children: [
                // Tarjeta de información principal
                _buildProfileHeader(user),
                const SizedBox(height: AppStyles.spacingL),

                // Barra de progreso XP (solo para usuarios)
                if (user.isUser) ...[
                  XpProgressBar(
                    currentXp: user.xp,
                    xpForNextLevel: user.xpForNextLevel,
                    currentLevel: user.level,
                  ),
                  const SizedBox(height: AppStyles.spacingL),
                ],

                // Información de contacto - siempre mostrar aunque esté vacía
                _buildContactInfo(user),
                const SizedBox(height: AppStyles.spacingL),

                // Intereses
                if (user.gustos != null && user.gustos!.isNotEmpty) ...[
                  _buildInterests(user),
                  const SizedBox(height: AppStyles.spacingL),
                ],

                // Estadísticas
                _buildStatistics(provider, user),
                const SizedBox(height: AppStyles.spacingL),

                // Información adicional según rol
                if (user.canManage) ...[
                  _buildRoleSpecificInfo(user, provider),
                  const SizedBox(height: AppStyles.spacingL),
                ],

                // Botón de cerrar sesión
                _buildLogoutButton(context),
                const SizedBox(height: AppStyles.spacingL),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.standardBorderRadius,
        boxShadow: AppStyles.largeShadow,
      ),
      child: Column(
        children: [
          // Avatar con nivel
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null || user.avatar!.isEmpty
                      ? Text(
                          user.firstName.isNotEmpty
                              ? user.firstName.substring(0, 1).toUpperCase()
                              : 'U',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primaryBlue,
                            fontSize: 48,
                          ),
                        )
                      : null,
                ),
              ),
              // Badge de nivel
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.backgroundWhite, width: 3),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nivel',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.whiteText,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.level.toString(),
                      style: const TextStyle(
                        color: AppColors.whiteText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingL),
          // Nombre completo
          Text(
            user.fullName,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.darkText,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Badge de rol
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.1),
              borderRadius: AppStyles.standardBorderRadius,
              border: Border.all(
                color: _getRoleColor(user.role),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isAdmin
                      ? Icons.admin_panel_settings
                      : user.isModerator
                          ? Icons.add_moderator
                          : Icons.person,
                  color: _getRoleColor(user.role),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  user.roleDisplayName.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getRoleColor(user.role),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                color: AppColors.lightText,
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  user.email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.lightText,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // XP para usuarios
          if (user.isUser) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: AppStyles.smallBorderRadius,
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${user.xp} XP',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfo(UserModel user) {
    final hasPhone = user.telefono != null && user.telefono!.isNotEmpty;
    final hasLocation = user.localidad != null && user.localidad!.isNotEmpty;
    
    return _buildSectionCard(
      title: 'Información de contacto',
      icon: Icons.contact_page_outlined,
      children: [
        _buildInfoRow(
          icon: Icons.email_outlined,
          label: 'Correo electrónico',
          value: user.email,
        ),
        if (hasPhone || hasLocation) const Divider(height: AppStyles.spacingL),
        if (hasPhone)
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: user.telefono!,
          )
        else
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: 'No especificado',
            isPlaceholder: true,
          ),
        if (hasPhone && hasLocation) const Divider(height: AppStyles.spacingL),
        if (hasLocation)
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Localidad',
            value: user.localidad!,
          )
        else
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Localidad',
            value: 'No especificada',
            isPlaceholder: true,
          ),
      ],
    );
  }

  Widget _buildInterests(UserModel user) {
    return _buildSectionCard(
      title: 'Intereses',
      icon: Icons.interests_outlined,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.gustos!.map((gusto) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: AppStyles.smallBorderRadius,
                border: Border.all(
                  color: AppColors.primaryOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gusto,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatistics(AppProvider provider, UserModel user) {
    final enrolledCourses = provider.courses.where((c) => c.isEnrolled).length;
    final completedQuizzes =
        provider.quizzes.where((q) => q.isCompleted).length;
    final inProgress = provider.progress
        .where(
            (p) => p.percentage > 0 && p.percentage < 100)
        .length;
    final completedCourses = provider.progress
        .where((p) => p.courseCompleted)
        .length;

    return _buildSectionCard(
      title: 'Estadísticas de aprendizaje',
      icon: Icons.analytics_outlined,
      children: [
        // Estadísticas principales en grid
        Row(
          children: [
            Expanded(
              child: _buildEnhancedStatItem(
                icon: Icons.school_outlined,
                value: enrolledCourses.toString(),
                label: 'Cursos Inscritos',
                color: AppColors.primaryOrange,
                subtitle: '$completedCourses completados',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedStatItem(
                icon: Icons.quiz_outlined,
                value: completedQuizzes.toString(),
                label: 'Quizzes Completados',
                color: AppColors.accentGreen,
                subtitle: '${provider.quizzes.length} disponibles',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildEnhancedStatItem(
                icon: Icons.trending_up,
                value: inProgress.toString(),
                label: 'En Progreso',
                color: AppColors.primaryBlue,
                subtitle: 'Cursos activos',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedStatItem(
                icon: Icons.emoji_events_outlined,
                value: user.level.toString(),
                label: 'Nivel Actual',
                color: AppColors.warningYellow,
                subtitle: '${user.xp} XP total',
              ),
            ),
          ],
        ),
        if (user.isUser) ...[
          const Divider(height: AppStyles.spacingL),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: AppStyles.smallBorderRadius,
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Progreso al siguiente nivel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildXpStat(
                      label: 'XP Actual',
                      value: user.xp.toString(),
                      icon: Icons.star,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.lightText.withOpacity(0.2),
                    ),
                    _buildXpStat(
                      label: 'Siguiente Nivel',
                      value: user.xpForNextLevel.toString(),
                      icon: Icons.trending_up,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.lightText.withOpacity(0.2),
                    ),
                    _buildXpStat(
                      label: 'Progreso',
                      value:
                          '${(user.progressToNextLevel * 100).toStringAsFixed(0)}%',
                      icon: Icons.percent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnhancedStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppStyles.smallBorderRadius,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.lightText,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleSpecificInfo(UserModel user, AppProvider provider) {
    final totalCourses = provider.courses.length;
    final totalQuizzes = provider.quizzes.length;

    return _buildSectionCard(
      title: user.isAdmin
          ? 'Información de Administrador'
          : 'Información de Moderador',
      icon: user.isAdmin ? Icons.admin_panel_settings : Icons.add_moderator,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.school_outlined,
                value: totalCourses.toString(),
                label: 'Cursos Creados',
                color: AppColors.successGreen,
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: AppColors.lightText.withOpacity(0.2),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.quiz_outlined,
                value: totalQuizzes.toString(),
                label: 'Quizzes Creados',
                color: AppColors.accentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingM),
        if (user.isAdmin) ...[
          Text(
            'Privilegios de Administrador:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPrivilegeChip('Gestionar usuarios'),
              _buildPrivilegeChip('Ver estadísticas'),
              _buildPrivilegeChip('Crear contenido'),
              _buildPrivilegeChip('Moderar sistema'),
            ],
          ),
        ] else ...[
          Text(
            'Privilegios de Moderador:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPrivilegeChip('Crear cursos'),
              _buildPrivilegeChip('Crear quizzes'),
              _buildPrivilegeChip('Ver estadísticas'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: AppStyles.cardPadding,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isPlaceholder = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isPlaceholder
              ? AppColors.lightText.withOpacity(0.5)
              : AppColors.primaryOrange,
          size: 20,
        ),
        const SizedBox(width: AppStyles.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.lightText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isPlaceholder
                      ? AppColors.lightText.withOpacity(0.6)
                      : AppColors.darkText,
                  fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: AppStyles.spacingS),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildXpStat({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Column(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: AppColors.primaryOrange,
            size: 20,
          ),
          const SizedBox(height: 4),
        ],
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryOrange,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.lightText,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPrivilegeChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.1),
        borderRadius: AppStyles.smallBorderRadius,
        border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle,
              size: 16, color: AppColors.successGreen),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.successGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar Sesión'),
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorRed.withOpacity(0.1),
          foregroundColor: AppColors.errorRed,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppStyles.standardBorderRadius,
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.errorRed;
      case 'moderator':
        return AppColors.warningYellow;
      case 'user':
        return AppColors.successGreen;
      default:
        return AppColors.primaryOrange;
    }
  }
}