import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Marketplace'),
      ),
      body: const Center(child: Text('Marketplace — coming soon')),
    );
  }
}
