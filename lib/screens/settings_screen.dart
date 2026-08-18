import 'package:flutter/material.dart';

import '../models/nutrition_models.dart';
import 'profiles_screen.dart';
import 'user_registration_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool darkMode;
  final Function(bool) toggleTheme;
  final ChildUser? user;
  final VoidCallback? onUserChanged;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.toggleTheme,
    this.user,
    this.onUserChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('Perfiles'),
            subtitle: const Text('Crear, cambiar o editar perfiles'),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilesScreen()),
              );
              onUserChanged?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Editar perfil activo'),
            subtitle: Text(user == null ? 'Sin perfil activo' : user!.name),
            onTap: user == null
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserRegistrationScreen(initialUser: user),
                      ),
                    );
                    if (result != null) onUserChanged?.call();
                  },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Modo oscuro'),
            value: darkMode,
            onChanged: (value) => toggleTheme(value),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sobre MyDiet Kids'),
            subtitle: Text(
              'Aplicacion educativa para registrar alimentos, agua y retos diarios.',
            ),
          ),
        ],
      ),
    );
  }
}
