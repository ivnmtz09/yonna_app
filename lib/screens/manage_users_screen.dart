import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_icons.dart';
import '../services/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_card.dart';
import '../widgets/glass/glass_container.dart';
import '../widgets/common/glass_icon_badge.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _users = [];
  bool _isLoading = false;
  String _filter = 'all';
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

    if (_filter != 'all') {
      filtered = filtered.where((u) => u['role'] == _filter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final fullName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.toLowerCase();
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
        content: Text('¿Estás seguro de que deseas eliminar a $userName? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.errorRed)),
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
                      'Gestión de Usuarios',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _loadUsers,
                      borderRadius: BorderRadius.circular(21),
                      child: GlassContainer(
                        width: 42,
                        height: 42,
                        borderRadius: BorderRadius.circular(21),
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 20,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Buscador de usuarios en GlassCard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  style: TextStyle(color: isDark ? Colors.white : AppColors.darkText),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o correo...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : AppColors.lightText),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryOrange),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Filtros horizontales
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos', 'all', _users.length, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Admins', 'admin', _users.where((u) => u['role'] == 'admin').length, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Moderadores', 'moderator', _users.where((u) => u['role'] == 'moderator').length, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Estudiantes', 'user', _users.where((u) => u['role'] == 'user').length, isDark),
                    ],
                  ),
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
                        ? Center(
                            child: Text(
                              'No se encontraron usuarios',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : AppColors.lightText,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            color: AppColors.primaryOrange,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return _buildUserTile(user, isDark);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count, bool isDark) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.selectionClick();
        setState(() => _filter = value);
      },
      selectedColor: AppColors.primaryOrange.withValues(alpha: 0.25),
      checkmarkColor: AppColors.primaryOrange,
      labelStyle: TextStyle(
        fontSize: 12,
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
  }

  Widget _buildUserTile(dynamic user, bool isDark) {
    final role = user['role'] ?? 'user';
    final firstName = user['first_name'] ?? '';
    final lastName = user['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim().isEmpty ? 'Usuario sin nombre' : '$firstName $lastName'.trim();
    final email = user['email'] ?? '';
    final level = user['level'] ?? 1;
    final xp = user['xp'] ?? 0;
    final userId = user['id'];

    Color roleColor;
    String roleLabel;
    switch (role) {
      case 'admin':
        roleColor = AppColors.primaryOrange;
        roleLabel = 'Admin';
        break;
      case 'moderator':
        roleColor = AppColors.primaryBlue;
        roleLabel = 'Moderador';
        break;
      default:
        roleColor = AppIcons.successColor;
        roleLabel = 'Estudiante';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            GlassIconBadge(
              icon: role == 'admin'
                  ? Icons.admin_panel_settings_rounded
                  : (role == 'moderator' ? Icons.shield_rounded : Icons.person_rounded),
              color: roleColor,
              size: 42,
              iconSize: 22,
              borderRadius: 21,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          roleLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Nivel $level',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $xp XP',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: isDark ? Colors.white54 : Colors.black45,
                size: 20,
              ),
              onSelected: (action) {
                if (action == 'role') {
                  _changeUserRole(userId, role);
                } else if (action == 'delete') {
                  _deleteUser(userId, fullName);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Cambiar rol'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.errorRed),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: AppColors.errorRed)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleSelectionDialog extends StatelessWidget {
  final String currentRole;

  const _RoleSelectionDialog({required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Rol'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Administrador'),
            leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryOrange),
            trailing: currentRole == 'admin' ? const Icon(Icons.check, color: AppColors.primaryOrange) : null,
            onTap: () => Navigator.pop(context, 'admin'),
          ),
          ListTile(
            title: const Text('Moderador'),
            leading: const Icon(Icons.shield_rounded, color: AppColors.primaryBlue),
            trailing: currentRole == 'moderator' ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
            onTap: () => Navigator.pop(context, 'moderator'),
          ),
          ListTile(
            title: const Text('Estudiante (Usuario)'),
            leading: const Icon(Icons.person_rounded, color: AppIcons.successColor),
            trailing: currentRole == 'user' ? const Icon(Icons.check, color: AppIcons.successColor) : null,
            onTap: () => Navigator.pop(context, 'user'),
          ),
        ],
      ),
    );
  }
}
