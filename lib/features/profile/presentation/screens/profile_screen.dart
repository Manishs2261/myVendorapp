import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: profile.logoUrl != null
                  ? NetworkImage(profile.logoUrl!)
                  : null,
              child: profile.logoUrl == null
                  ? Text(
                      profile.businessName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 28),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(profile.businessName,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(profile.email),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Phone'),
              subtitle: Text(profile.phone),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go(RouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
