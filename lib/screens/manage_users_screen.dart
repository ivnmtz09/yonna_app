import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/empty_state.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _users = [];
  bool _isLoading = false;
  String _filter = 'all'; // all, admin, moderator, user
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _apiService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  List<dynamic> get _filteredUsers {
    List<dynamic> filtered = _users;

    // Aplicar filtro de rol
    if (_filter != 'all') {
      filtered = filtered.where((u) => u['role'] == _filter).toList();
    }

    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final fullName =
            '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
                .toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return fullName.contains(query) || email.contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _changeUserRole(int userId, String currentRole) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => _RoleSelectionDialog(currentRole: currentRole),
    );

    if (newRole == null || newRole == currentRole) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.updateUserRole(userId, newRole);
      await _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rol actualizado exitosamente'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar rol: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _deleteUser(int userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text(
            '¿Estás seguro de que quieres eliminar a $userName? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.deleteUser(userId);
      await _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario eliminado exitosamente'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar usuario: $e'),
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
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Recargar usuarios',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundWhite,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: AppStyles.standardBorderRadius,
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.backgroundGray,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Filtros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.backgroundWhite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', 'all', _users.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Administradores',
                    'admin',
                    _users.where((u) => u['role'] == 'admin').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Moderadores',
                    'moderator',
                    _users.where((u) => u['role'] == 'moderator').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Usuarios',
                    'user',
                    _users.where((u) => u['role'] == 'user').length,
                  ),
                ],
              ),
            ),
          ),

          // Contador de resultados
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.backgroundWhite,
            child: Row(
              children: [
                Text(
                  '${_filteredUsers.length} usuario${_filteredUsers.length != 1 ? 's' : ''} encontrado${_filteredUsers.length != 1 ? 's' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuarios
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  )
                : _filteredUsers.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        title: _searchQuery.isNotEmpty || _filter != 'all'
                            ? 'No hay usuarios que coincidan'
                            : 'No hay usuarios',
                        message: _searchQuery.isNotEmpty || _filter != 'all'
                            ? 'Prueba con otros términos de búsqueda o filtros'
                            : 'No se han encontrado usuarios en el sistema',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        color: AppColors.primaryOrange,
                        child: ListView.builder(
                          padding: AppStyles.screenPadding,
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _filter = value);
      },
      backgroundColor: AppColors.backgroundWhite,
      selectedColor: AppColors.primaryOrange.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryOrange : AppColors.darkText,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
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
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role'] ?? 'user';
    final fullName =
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final email = user['email'] ?? '';
    final level = user['level'] ?? 1;
    final xp = user['xp'] ?? 0;
    final userId = user['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.standardBorderRadius,
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _getRoleColor(role).withOpacity(0.2),
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                    style: AppTextStyles.h4.copyWith(
                      color: _getRoleColor(role),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Usuario sin nombre' : fullName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.lightText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withOpacity(0.1),
                    borderRadius: AppStyles.smallBorderRadius,
                  ),
                  child: Text(
                    _getRoleDisplayName(role),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getRoleColor(role),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (role == 'user') ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem(Icons.emoji_events_outlined, 'Nivel $level'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.star_border, '$xp XP'),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Cambiar rol'),
                    onPressed: () => _changeUserRole(userId, role),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                      side: const BorderSide(color: AppColors.primaryOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppStyles.smallBorderRadius,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (user['id'] !=
                    _apiService
                        .userData['id']) // No permitir eliminarse a sí mismo
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _deleteUser(
                        userId, fullName.isEmpty ? email : fullName),
                    color: AppColors.errorRed,
                    tooltip: 'Eliminar usuario',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryOrange),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.errorRed;
      case 'moderator':
        return AppColors.primaryOrange;
      case 'user':
        return AppColors.primaryBlue;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'moderator':
        return 'Moderador';
      case 'user':
        return 'Usuario';
      default:
        return 'Usuario';
    }
  }
}

class _RoleSelectionDialog extends StatelessWidget {
  final String currentRole;

  const _RoleSelectionDialog({required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar rol de usuario'),
      insetPadding: const EdgeInsets.all(20),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.standardBorderRadius,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRoleOption(
              context, 'admin', 'Administrador', AppColors.errorRed),
          const SizedBox(height: 8),
          _buildRoleOption(
              context, 'moderator', 'Moderador', AppColors.primaryOrange),
          const SizedBox(height: 8),
          _buildRoleOption(context, 'user', 'Usuario', AppColors.primaryBlue),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    String role,
    String label,
    Color color,
  ) {
    final isCurrentRole = role == currentRole;
    return InkWell(
      onTap: isCurrentRole ? null : () => Navigator.pop(context, role),
      borderRadius: AppStyles.smallBorderRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrentRole ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: AppStyles.smallBorderRadius,
          border: Border.all(
            color: isCurrentRole ? color : AppColors.lightText.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCurrentRole ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCurrentRole ? color : AppColors.lightText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isCurrentRole ? color : AppColors.darkText,
                  fontWeight:
                      isCurrentRole ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isCurrentRole)
              Text(
                '(Actual)',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
