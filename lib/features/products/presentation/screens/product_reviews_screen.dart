import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Product Reviews'),
      ),
      body: const Center(child: Text('Product Reviews — coming soon')),
    );
  }
}
