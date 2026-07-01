// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_image_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiImageRemoteSourceHash() =>
    r'dcf9bda91708f7aa26fabb53cc3cb78146a01b91';

/// See also [aiImageRemoteSource].
@ProviderFor(aiImageRemoteSource)
final aiImageRemoteSourceProvider =
    AutoDisposeProvider<AiImageRemoteSource>.internal(
      aiImageRemoteSource,
      name: r'aiImageRemoteSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiImageRemoteSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiImageRemoteSourceRef = AutoDisposeProviderRef<AiImageRemoteSource>;
String _$aiImageServiceHash() => r'c72ee1fbacc85d7d6cd6fada4a80a2be15d3f184';

/// See also [aiImageService].
@ProviderFor(aiImageService)
final aiImageServiceProvider = AutoDisposeProvider<AiImageService>.internal(
  aiImageService,
  name: r'aiImageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiImageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiImageServiceRef = AutoDisposeProviderRef<AiImageService>;
String _$aiImageNotifierHash() => r'bfd0a5b2e5fd54ec0999b4551dc7c2c5f83a6ccd';

/// See also [AiImageNotifier].
@ProviderFor(AiImageNotifier)
final aiImageNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AiImageNotifier, AiImageResult?>.internal(
      AiImageNotifier.new,
      name: r'aiImageNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiImageNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AiImageNotifier = AutoDisposeAsyncNotifier<AiImageResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
