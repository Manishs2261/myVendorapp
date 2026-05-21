import 'package:flutter/material.dart';
import '../../../../core/widgets/main_shell.dart';

class HelpFeedbackScreen extends StatelessWidget {
  const HelpFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Help & Feedback'),
      ),
      body: const Center(child: Text('Help & Feedback — coming soon')),
    );
  }
}
