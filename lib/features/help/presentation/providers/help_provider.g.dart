// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$helpRemoteSourceHash() => r'23bf1ce6f7fd414a8ec23fc6d7824db29f3bc171';

/// See also [helpRemoteSource].
@ProviderFor(helpRemoteSource)
final helpRemoteSourceProvider = AutoDisposeProvider<HelpRemoteSource>.internal(
  helpRemoteSource,
  name: r'helpRemoteSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$helpRemoteSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HelpRemoteSourceRef = AutoDisposeProviderRef<HelpRemoteSource>;
String _$helpRepositoryHash() => r'531fe75380430e61836e37bb47bd06847d90b59a';

/// See also [helpRepository].
@ProviderFor(helpRepository)
final helpRepositoryProvider = AutoDisposeProvider<HelpRepository>.internal(
  helpRepository,
  name: r'helpRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$helpRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HelpRepositoryRef = AutoDisposeProviderRef<HelpRepository>;
String _$helpFeedbackListHash() => r'6d70080d84ee31da21446273a7ecb85d4743a441';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [helpFeedbackList].
@ProviderFor(helpFeedbackList)
const helpFeedbackListProvider = HelpFeedbackListFamily();

/// See also [helpFeedbackList].
class HelpFeedbackListFamily
    extends Family<AsyncValue<PaginatedResponse<FeedbackItem>>> {
  /// See also [helpFeedbackList].
  const HelpFeedbackListFamily();

  /// See also [helpFeedbackList].
  HelpFeedbackListProvider call({String? type, String? status, int page = 1}) {
    return HelpFeedbackListProvider(type: type, status: status, page: page);
  }

  @override
  HelpFeedbackListProvider getProviderOverride(
    covariant HelpFeedbackListProvider provider,
  ) {
    return call(
      type: provider.type,
      status: provider.status,
      page: provider.page,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'helpFeedbackListProvider';
}

/// See also [helpFeedbackList].
class HelpFeedbackListProvider
    extends AutoDisposeFutureProvider<PaginatedResponse<FeedbackItem>> {
  /// See also [helpFeedbackList].
  HelpFeedbackListProvider({String? type, String? status, int page = 1})
    : this._internal(
        (ref) => helpFeedbackList(
          ref as HelpFeedbackListRef,
          type: type,
          status: status,
          page: page,
        ),
        from: helpFeedbackListProvider,
        name: r'helpFeedbackListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$helpFeedbackListHash,
        dependencies: HelpFeedbackListFamily._dependencies,
        allTransitiveDependencies:
            HelpFeedbackListFamily._allTransitiveDependencies,
        type: type,
        status: status,
        page: page,
      );

  HelpFeedbackListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
    required this.status,
    required this.page,
  }) : super.internal();

  final String? type;
  final String? status;
  final int page;

  @override
  Override overrideWith(
    FutureOr<PaginatedResponse<FeedbackItem>> Function(
      HelpFeedbackListRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HelpFeedbackListProvider._internal(
        (ref) => create(ref as HelpFeedbackListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
        status: status,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PaginatedResponse<FeedbackItem>>
  createElement() {
    return _HelpFeedbackListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HelpFeedbackListProvider &&
        other.type == type &&
        other.status == status &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HelpFeedbackListRef
    on AutoDisposeFutureProviderRef<PaginatedResponse<FeedbackItem>> {
  /// The parameter `type` of this provider.
  String? get type;

  /// The parameter `status` of this provider.
  String? get status;

  /// The parameter `page` of this provider.
  int get page;
}

class _HelpFeedbackListProviderElement
    extends AutoDisposeFutureProviderElement<PaginatedResponse<FeedbackItem>>
    with HelpFeedbackListRef {
  _HelpFeedbackListProviderElement(super.provider);

  @override
  String? get type => (origin as HelpFeedbackListProvider).type;
  @override
  String? get status => (origin as HelpFeedbackListProvider).status;
  @override
  int get page => (origin as HelpFeedbackListProvider).page;
}

String _$submitFeedbackNotifierHash() =>
    r'b95f9adfe2b7717df2c2d8f4bbfdc8809746305a';

/// See also [SubmitFeedbackNotifier].
@ProviderFor(SubmitFeedbackNotifier)
final submitFeedbackNotifierProvider =
    AutoDisposeNotifierProvider<
      SubmitFeedbackNotifier,
      AsyncValue<FeedbackItem?>
    >.internal(
      SubmitFeedbackNotifier.new,
      name: r'submitFeedbackNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$submitFeedbackNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubmitFeedbackNotifier =
    AutoDisposeNotifier<AsyncValue<FeedbackItem?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
