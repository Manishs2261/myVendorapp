import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class StorefrontEditorScreen extends StatelessWidget {
  const StorefrontEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Storefront Editor'),
      ),
      body: const Center(child: Text('Storefront Editor — coming soon')),
    );
  }
}
