import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Settings'),
      ),
      body: const Center(child: Text('Settings — coming soon')),
    );
  }
}
