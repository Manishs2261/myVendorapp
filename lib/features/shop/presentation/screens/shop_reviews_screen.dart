import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class ShopReviewsScreen extends StatelessWidget {
  const ShopReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Shop Reviews'),
      ),
      body: const Center(child: Text('Shop Reviews — coming soon')),
    );
  }
}
