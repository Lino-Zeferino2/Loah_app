import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_theme.dart';

/// Admin screen to list all users with creation date and block/unblock
/// functionality.
class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Utilizadores'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar utilizadores...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Users list from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar utilizadores',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;

                // Filter by search query
                final filteredUsers = _searchQuery.isEmpty
                    ? users
                    : users.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] as String? ?? '').toLowerCase();
                        final email = (data['email'] as String? ?? '').toLowerCase();
                        return name.contains(_searchQuery) || email.contains(_searchQuery);
                      }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: context.textSecondary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhum utilizador encontrado'
                              : 'Nenhum resultado para "$_searchQuery"',
                          style: TextStyle(color: context.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final doc = filteredUsers[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _UserListTile(
                      userData: data,
                      onToggleBlock: () => _toggleUserBlock(doc.id, data),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserBlock(String uid, Map<String, dynamic> data) async {
    final isBlocked = data['blocked'] == true;
    final userName = data['name'] ?? 'Utilizador';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBlocked ? 'Desbloquear Utilizador' : 'Bloquear Utilizador'),
        content: Text(
          isBlocked
              ? 'Tem a certeza que deseja desbloquear "$userName"?'
              : 'Tem a certeza que deseja bloquear "$userName"?\n\nO utilizador não conseguirá fazer login na aplicação.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isBlocked ? Colors.green : Colors.red,
            ),
            child: Text(isBlocked ? 'Desbloquear' : 'Bloquear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'blocked': !isBlocked,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBlocked
              ? 'Utilizador desbloqueado com sucesso'
              : 'Utilizador bloqueado com sucesso',
        ),
        backgroundColor: isBlocked ? Colors.green : Colors.red,
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onToggleBlock;

  const _UserListTile({
    required this.userData,
    required this.onToggleBlock,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final name = userData['name'] ?? 'Sem nome';
    final email = userData['email'] ?? '';
    final role = userData['role'] ?? 'user';
    final isBlocked = userData['blocked'] == true;
    final createdAt = userData['createdAt'] as Timestamp?;

    String dateStr = 'Data desconhecida';
    if (createdAt != null) {
      final date = createdAt.toDate();
      dateStr = '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    final statusColor = isBlocked ? Colors.red : Colors.green;
    final statusBgColor = isBlocked
        ? Colors.red.withValues(alpha: 0.08)
        : Colors.green.withValues(alpha: 0.08);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isBlocked
          ? Colors.red.withValues(alpha: 0.04)
          : colors.cardBackgroundAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: isBlocked ? 0.3 : 0.2),
          width: isBlocked ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar inicial with status color
            CircleAvatar(
              radius: 22,
              backgroundColor: isBlocked
                  ? Colors.red.withValues(alpha: 0.15)
                  : Colors.green.withValues(alpha: 0.15),
              child: Text(
                name.isNotEmpty
                    ? name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (role == 'admin')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      // Status chip: "Ativo" (green) or "Bloqueado" (red)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isBlocked ? 'Bloqueado' : 'Ativo',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email as String,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Criado em: $dateStr',
                    style: TextStyle(
                      color: context.textSecondary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Block/Unblock button
            IconButton(
              onPressed: onToggleBlock,
              icon: Icon(
                isBlocked ? Icons.lock_open_rounded : Icons.lock_outline,
                color: isBlocked ? Colors.green : Colors.red.withValues(alpha: 0.7),
                size: 20,
              ),
              tooltip: isBlocked ? 'Desbloquear' : 'Bloquear',
            ),
          ],
        ),
      ),
    );
  }
}

