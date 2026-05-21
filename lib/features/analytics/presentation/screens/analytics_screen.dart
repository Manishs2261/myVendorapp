import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Analytics'),
      ),
      body: const Center(child: Text('Analytics — coming soon')),
    );
  }
}
