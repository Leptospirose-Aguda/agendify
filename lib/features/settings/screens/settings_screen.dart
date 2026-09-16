import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Aparência',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: (value) => onThemeChanged(value!),
            title: const Text('Seguir sistema'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (value) => onThemeChanged(value!),
            title: const Text('Modo claro'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: (value) => onThemeChanged(value!),
            title: const Text('Modo escuro'),
          ),
          const Divider(height: 36),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notificações'),
            subtitle: const Text('Configurar lembretes e alertas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sincronização'),
            subtitle: const Text('Google Calendar e Apple Calendar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Categorias e cores'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
