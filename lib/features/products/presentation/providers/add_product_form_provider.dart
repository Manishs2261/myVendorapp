import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/products_repository.dart';
import '../../domain/product_models.dart';
import '../providers/products_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

part 'add_product_form_provider.g.dart';

class AddProductFormState {
  final List<String> existingImageUrls;
  final List<XFile> selectedImages;
  final Map<String, Uint8List> selectedImageBytes;
  final XFile? selectedVideo;
  final String? existingVideoUrl;
  final bool removeVideo;
  final List<({String hex, String name})> customColors;
  final Map<String, bool> colorSelections;
  final List<String> tags;
  final int? selectedCategoryId;
  final String? selectedUnit;
  final String status;
  final bool loading;
  final bool draftSaving;
  final bool hasUnsavedChanges;
  final int? currentDraftId;

  const AddProductFormState({
    this.existingImageUrls = const [],
    this.selectedImages = const [],
    this.selectedImageBytes = const {},
    this.selectedVideo,
    this.existingVideoUrl,
    this.removeVideo = false,
    this.customColors = const [],
    this.colorSelections = const {},
    this.tags = const [],
    this.selectedCategoryId,
    this.selectedUnit,
    this.status = 'active',
    this.loading = false,
    this.draftSaving = false,
    this.hasUnsavedChanges = false,
    this.currentDraftId,
  });

  AddProductFormState copyWith({
    List<String>? existingImageUrls,
    List<XFile>? selectedImages,
    Map<String, Uint8List>? selectedImageBytes,
    XFile? Function()? selectedVideo,
    String? Function()? existingVideoUrl,
    bool? removeVideo,
    List<({String hex, String name})>? customColors,
    Map<String, bool>? colorSelections,
    List<String>? tags,
    int? Function()? selectedCategoryId,
    String? Function()? selectedUnit,
    String? status,
    bool? loading,
    bool? draftSaving,
    bool? hasUnsavedChanges,
    int? Function()? currentDraftId,
  }) {
    return AddProductFormState(
      existingImageUrls: existingImageUrls ?? this.existingImageUrls,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedImageBytes: selectedImageBytes ?? this.selectedImageBytes,
      selectedVideo: selectedVideo != null ? selectedVideo() : this.selectedVideo,
      existingVideoUrl: existingVideoUrl != null ? existingVideoUrl() : this.existingVideoUrl,
      removeVideo: removeVideo ?? this.removeVideo,
      customColors: customColors ?? this.customColors,
      colorSelections: colorSelections ?? this.colorSelections,
      tags: tags ?? this.tags,
      selectedCategoryId: selectedCategoryId != null ? selectedCategoryId() : this.selectedCategoryId,
      selectedUnit: selectedUnit != null ? selectedUnit() : this.selectedUnit,
      status: status ?? this.status,
      loading: loading ?? this.loading,
      draftSaving: draftSaving ?? this.draftSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      currentDraftId: currentDraftId != null ? currentDraftId() : this.currentDraftId,
    );
  }
}

@riverpod
class AddProductForm extends _$AddProductForm {
  @override
  AddProductFormState build() {
    return const AddProductFormState();
  }

  void prefillFromProduct(Product p) {
    final knownHexes = _colorSwatches.map((s) => s.$1).toSet();
    final Map<String, bool> colorSels = {
      for (final (hex, _) in _colorSwatches) hex: p.colorVariations.contains(hex),
    };
    final List<({String hex, String name})> customCols = [];
    for (final hex in p.colorVariations) {
      if (!knownHexes.contains(hex)) {
        customCols.add((hex: hex, name: hex));
      }
    }

    state = AddProductFormState(
      existingImageUrls: List.from(p.imageUrls),
      existingVideoUrl: p.videoUrl,
      tags: List.from(p.tags),
      colorSelections: colorSels,
      customColors: customCols,
      selectedCategoryId: p.categoryId,
      selectedUnit: p.unit,
      status: (p.status == ProductStatus.outOfStock) ? 'inactive' : p.status.name,
      currentDraftId: p.id,
    );
  }

  void markDirty() {
    if (!state.hasUnsavedChanges) {
      state = state.copyWith(hasUnsavedChanges: true);
    }
  }

  void updateCategory(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: () => categoryId,
      hasUnsavedChanges: true,
    );
  }

  void updateUnit(String? unit) {
    state = state.copyWith(
      selectedUnit: () => unit,
      hasUnsavedChanges: true,
    );
  }

  void updateStatus(String status) {
    state = state.copyWith(
      status: status,
      hasUnsavedChanges: true,
    );
  }

  void addTag(String tag) {
    if (state.tags.contains(tag)) return;
    state = state.copyWith(
      tags: [...state.tags, tag],
      hasUnsavedChanges: true,
    );
  }

  void removeTag(String tag) {
    state = state.copyWith(
      tags: state.tags.where((t) => t != tag).toList(),
      hasUnsavedChanges: true,
    );
  }

  void toggleColorSelection(String hex) {
    final newSelections = Map<String, bool>.from(state.colorSelections);
    newSelections[hex] = !(newSelections[hex] ?? false);
    state = state.copyWith(
      colorSelections: newSelections,
      hasUnsavedChanges: true,
    );
  }

  void addCustomColor(String hex, String name) {
    state = state.copyWith(
      customColors: [...state.customColors, (hex: hex, name: name)],
      hasUnsavedChanges: true,
    );
  }

  void removeCustomColor(({String hex, String name}) color) {
    state = state.copyWith(
      customColors: state.customColors.where((c) => c != color).toList(),
      hasUnsavedChanges: true,
    );
  }

  void addSelectedImages(List<XFile> images, Map<String, Uint8List> bytesMap) {
    state = state.copyWith(
      selectedImages: [...state.selectedImages, ...images],
      selectedImageBytes: {
        ...state.selectedImageBytes,
        ...bytesMap,
      },
      hasUnsavedChanges: true,
    );
  }

  void removeSelectedImage(int index) {
    final images = List<XFile>.from(state.selectedImages);
    final removed = images.removeAt(index);
    final bytesMap = Map<String, Uint8List>.from(state.selectedImageBytes);
    bytesMap.remove(removed.path);

    state = state.copyWith(
      selectedImages: images,
      selectedImageBytes: bytesMap,
      hasUnsavedChanges: true,
    );
  }

  void removeExistingImage(int index) {
    final urls = List<String>.from(state.existingImageUrls);
    urls.removeAt(index);
    state = state.copyWith(
      existingImageUrls: urls,
      hasUnsavedChanges: true,
    );
  }

  void setVideo(XFile video) {
    state = state.copyWith(
      selectedVideo: () => video,
      hasUnsavedChanges: true,
    );
  }

  void removeSelectedVideo() {
    state = state.copyWith(
      selectedVideo: () => null,
      hasUnsavedChanges: true,
    );
  }

  void removeExistingVideo() {
    state = state.copyWith(
      existingVideoUrl: () => null,
      removeVideo: true,
      hasUnsavedChanges: true,
    );
  }

  void setHasUnsavedChanges(bool val) {
    state = state.copyWith(hasUnsavedChanges: val);
  }

  Future<void> saveDraft({
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    int? discountPercentage,
    required int stock,
    required String brand,
    required Map<String, String> specs,
    void Function(String msg)? onFinished,
    void Function(String err)? onError,
  }) async {
    if (name.isEmpty) {
      onError?.call('Please enter a product name first');
      return;
    }
    state = state.copyWith(draftSaving: true);
    try {
      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;
      final form = ProductForm(
        isDraft: true,
        name: name,
        description: description,
        price: price,
        originalPrice: originalPrice,
        discountPercentage: discountPercentage,
        stock: stock,
        status: state.status,
        categoryId: state.selectedCategoryId,
        brand: brand.isEmpty ? null : brand,
        unit: state.selectedUnit,
        tags: List.from(state.tags),
        specifications: specs,
        colorVariations: [
          ...state.colorSelections.entries.where((e) => e.value).map((e) => e.key),
          ...state.customColors.map((c) => c.hex),
        ],
        latitude: null,
        longitude: null,
        images: List.from(state.existingImageUrls),
        removeVideo: state.removeVideo,
      );

      Product result;
      final effectiveId = state.currentDraftId;
      if (effectiveId != null) {
        if (state.selectedImages.isNotEmpty || state.selectedVideo != null) {
          result = await repo.updateProductMultipart(
            id: effectiveId,
            form: form,
            images: state.selectedImages,
            video: state.selectedVideo,
          );
        } else {
          result = await repo.updateProduct(effectiveId, form);
        }
      } else {
        result = await repo.createProductMultipart(
          form: form,
          images: state.selectedImages,
          video: state.selectedVideo,
        );
      }

      state = state.copyWith(
        hasUnsavedChanges: false,
        existingImageUrls: List.from(result.imageUrls),
        selectedImages: const [],
        selectedImageBytes: const {},
        selectedVideo: () => null,
        existingVideoUrl: () => result.videoUrl,
        currentDraftId: () => result.id,
      );
      onFinished?.call('Draft saved!');
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      state = state.copyWith(draftSaving: false);
    }
  }

  Future<void> submitProduct({
    required bool isEditing,
    required Product? initialProduct,
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    int? discountPercentage,
    required int stock,
    required String brand,
    required Map<String, String> specs,
    void Function(String msg)? onFinished,
    void Function(String err)? onError,
  }) async {
    state = state.copyWith(loading: true);
    try {
      final form = ProductForm(
        isDraft: false,
        name: name,
        description: description,
        price: price,
        originalPrice: originalPrice,
        discountPercentage: discountPercentage,
        stock: stock,
        status: state.status,
        categoryId: state.selectedCategoryId,
        brand: brand.isEmpty ? null : brand,
        unit: state.selectedUnit,
        tags: List.from(state.tags),
        specifications: specs,
        colorVariations: [
          ...state.colorSelections.entries.where((e) => e.value).map((e) => e.key),
          ...state.customColors.map((c) => c.hex),
        ],
        latitude: null,
        longitude: null,
        images: List.from(state.existingImageUrls),
        removeVideo: state.removeVideo,
      );

      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;

      if (isEditing) {
        if (state.selectedImages.isNotEmpty || state.selectedVideo != null) {
          await repo.updateProductMultipart(
            id: initialProduct!.id,
            form: form,
            images: state.selectedImages,
            video: state.selectedVideo,
          );
        } else {
          await repo.updateProduct(initialProduct!.id, form);
        }
        ref.invalidate(productDetailProvider(initialProduct.id));
      } else {
        await repo.createProductMultipart(
          form: form,
          images: state.selectedImages,
          video: state.selectedVideo,
        );
      }

      state = state.copyWith(hasUnsavedChanges: false);
      ref.invalidate(productsNotifierProvider);
      ref.invalidate(dashboardNotifierProvider);
      onFinished?.call(isEditing ? 'Product updated!' : 'Product added successfully');
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> publishProduct({
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    int? discountPercentage,
    required int stock,
    required String brand,
    required Map<String, String> specs,
    void Function(String msg)? onFinished,
    void Function(String err)? onError,
  }) async {
    state = state.copyWith(loading: true);
    try {
      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;
      final effectiveId = state.currentDraftId;
      if (effectiveId != null) {
        await repo.publishDraft(effectiveId);
      } else {
        final form = ProductForm(
          isDraft: false,
          name: name,
          description: description,
          price: price,
          originalPrice: originalPrice,
          discountPercentage: discountPercentage,
          stock: stock,
          status: state.status,
          categoryId: state.selectedCategoryId,
          brand: brand.isEmpty ? null : brand,
          unit: state.selectedUnit,
          tags: List.from(state.tags),
          specifications: specs,
          colorVariations: [
            ...state.colorSelections.entries.where((e) => e.value).map((e) => e.key),
            ...state.customColors.map((c) => c.hex),
          ],
          latitude: null,
          longitude: null,
          images: List.from(state.existingImageUrls),
          removeVideo: state.removeVideo,
        );
        await repo.createProductMultipart(
          form: form,
          images: state.selectedImages,
          video: state.selectedVideo,
        );
      }
      ref.invalidate(productsNotifierProvider);
      ref.invalidate(dashboardNotifierProvider);
      onFinished?.call('Product published!');
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  static const _colorSwatches = [
    ('#EF4444', 'Red'),
    ('#3B82F6', 'Blue'),
    ('#22C55E', 'Green'),
    ('#1C1C23', 'Dark'),
    ('#FFFFFF', 'White'),
    ('#EAB308', 'Yellow'),
    ('#EC4899', 'Pink'),
    ('#A855F7', 'Purple'),
    ('#F97316', 'Orange'),
    ('#6B7280', 'Grey'),
  ];
}
