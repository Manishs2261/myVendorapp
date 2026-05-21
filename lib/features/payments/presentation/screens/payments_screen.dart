import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Payments'),
      ),
      body: const Center(child: Text('Payments — coming soon')),
    );
  }
}
