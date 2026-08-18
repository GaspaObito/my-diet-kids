import 'package:flutter/material.dart';

import '../models/nutrition_models.dart';
import '../services/nutrition_store.dart';
import 'user_registration_screen.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<ChildUser> _users = [];
  ChildUser? _activeUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<ChildUser> users = [];
    ChildUser? active;

    try {
      users = await NutritionStore.loadUsers().timeout(
        const Duration(seconds: 2),
      );
      active = await NutritionStore.loadUser().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      users = [];
      active = null;
    }

    if (!mounted) return;
    setState(() {
      _users = users;
      _activeUser = active;
      _loading = false;
    });
  }

  Future<void> _createProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserRegistrationScreen()),
    );
    await _load();
  }

  Future<void> _editProfile(ChildUser user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserRegistrationScreen(initialUser: user),
      ),
    );
    await _load();
  }

  Future<void> _selectProfile(ChildUser user) async {
    await NutritionStore.setActiveUser(user.id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil activo: ${user.name}')),
    );
  }

  Future<void> _deleteProfile(ChildUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: Text('Quieres eliminar el perfil de ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await NutritionStore.deleteUser(user.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfiles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProfile,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Cambia entre ninos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cada perfil guarda su propia comida, agua, retos e historial.',
                ),
                const SizedBox(height: 16),
                if (_users.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Icon(Icons.person_add, size: 42),
                          const SizedBox(height: 8),
                          const Text('Aun no hay perfiles creados.'),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _createProfile,
                            icon: const Icon(Icons.add),
                            label: const Text('Crear primer perfil'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._users.map((user) {
                    final isActive = user.id == _activeUser?.id;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isActive ? Colors.green : Colors.grey.shade200,
                          child: Icon(
                            isActive ? Icons.check : Icons.face,
                            color: isActive ? Colors.white : Colors.green,
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${user.age} anos | ${user.activityLevel} | '
                          '${user.calorieGoal} kcal | ${user.waterGoalMl} ml',
                        ),
                        onTap: () => _selectProfile(user),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _editProfile(user);
                            if (value == 'delete') _deleteProfile(user);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}
