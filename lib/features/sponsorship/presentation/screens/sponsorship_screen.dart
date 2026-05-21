import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class SponsorshipScreen extends StatelessWidget {
  const SponsorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Sponsorship'),
      ),
      body: const Center(child: Text('Sponsorship — coming soon')),
    );
  }
}
