import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/settings_remote_source.dart';

final settingsRemoteSourceProvider = Provider<SettingsRemoteSource>(
  (ref) => SettingsRemoteSource(ref.read(dioProvider)),
);
