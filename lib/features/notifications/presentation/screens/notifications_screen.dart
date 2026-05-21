import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Notifications'),
      ),
      body: const Center(child: Text('Notifications — coming soon')),
    );
  }
}
