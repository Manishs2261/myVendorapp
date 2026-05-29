import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../data/products_repository.dart';
import '../../domain/product_models.dart';
import '../providers/ai_image_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/image_processing_dialog.dart';
import '../../../../core/router/route_names.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _units = ['pcs', 'kg', 'litre', 'g', 'ml', 'box', 'pair', 'dozen', 'set'];

const _colorSwatches = [
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

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AddProductScreen extends ConsumerStatefulWidget {
  final Product? initialProduct;
  const AddProductScreen({super.key, this.initialProduct});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  bool get _isEditing => widget.initialProduct != null;
  bool get _isDraft => _isEditing
      ? (widget.initialProduct?.isDraft ?? false)
      : true;
  int? get _effectiveDraftId =>
      _currentDraftId ?? (_isEditing ? widget.initialProduct?.id : null);

  int get _completionPct {
    int score = 0;
    if (_nameCtrl.text.trim().isNotEmpty) score += 20;
    if (_priceCtrl.text.trim().isNotEmpty) score += 20;
    if (_selectedCategoryId != null) score += 20;
    if (_descCtrl.text.trim().isNotEmpty) score += 15;
    if (_selectedImages.isNotEmpty || _existingImageUrls.isNotEmpty) score += 15;
    if (_brandCtrl.text.trim().isNotEmpty) score += 5;
    if (_tags.isNotEmpty) score += 5;
    return score;
  }

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _draftSaving = false;
  bool _hasUnsavedChanges = false;
  int? _currentDraftId;
  Timer? _autoSaveTimer;

  // Basic Info
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();
  final List<String> _tags = [];

  // Media — existing URLs (edit mode) + newly picked files
  final _picker = ImagePicker();
  final List<String> _existingImageUrls = [];
  final List<XFile> _selectedImages = [];
  XFile? _selectedVideo;

  // Specifications: each entry = (key controller, value controller)
  final List<({TextEditingController key, TextEditingController value})> _specs =
      [];

  // Color variations: hex → selected
  final Map<String, bool> _colorSelections = {
    for (final (hex, _) in _colorSwatches) hex: false,
  };

  // Pricing & Stock
  final _mrpCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String? _selectedUnit;
  String _status = 'active';

  // Category
  int? _selectedCategoryId;

  // Location
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  void _markDirty() {
    if (!_hasUnsavedChanges && mounted) setState(() => _hasUnsavedChanges = true);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) _prefillFromProduct(widget.initialProduct!);
    for (final ctrl in [
      _nameCtrl, _descCtrl, _brandCtrl, _mrpCtrl,
      _priceCtrl, _discountCtrl, _stockCtrl, _latCtrl, _lngCtrl,
    ]) {
      ctrl.addListener(_markDirty);
    }
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (_hasUnsavedChanges && _isDraft && _nameCtrl.text.trim().isNotEmpty) {
        _saveDraft(silent: true);
      }
    });
  }

  void _prefillFromProduct(Product p) {
    _nameCtrl.text = p.name;
    _descCtrl.text = p.description;
    _brandCtrl.text = p.brand ?? '';
    _tags.addAll(p.tags);
    _existingImageUrls.addAll(p.imageUrls);
    for (final e in p.specifications.entries) {
      _specs.add((
        key: TextEditingController(text: e.key),
        value: TextEditingController(text: e.value),
      ));
    }
    for (final hex in p.colorVariations) {
      _colorSelections[hex] = true;
    }
    _priceCtrl.text = p.price.toString();
    _mrpCtrl.text = p.originalPrice?.toString() ?? '';
    _discountCtrl.text = p.discountPercentage?.toString() ?? '';
    _stockCtrl.text = p.stock.toString();
    _status = (p.status == ProductStatus.outOfStock) ? 'inactive' : p.status.name;
    _selectedUnit = p.unit;
    _selectedCategoryId = p.categoryId;
    _latCtrl.text = p.latitude?.toString() ?? '';
    _lngCtrl.text = p.longitude?.toString() ?? '';
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _brandCtrl.dispose();
    _tagInputCtrl.dispose();
    _mrpCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _stockCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    for (final row in _specs) {
      row.key.dispose();
      row.value.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Draft helpers
  // ---------------------------------------------------------------------------

  ProductForm _buildForm({bool isDraft = false}) => ProductForm(
        isDraft: isDraft,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        originalPrice: double.tryParse(_mrpCtrl.text.trim()),
        discountPercentage: int.tryParse(_discountCtrl.text.trim()),
        stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
        status: _status,
        categoryId: _selectedCategoryId,
        brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
        unit: _selectedUnit,
        tags: List.from(_tags),
        specifications: {
          for (final row in _specs)
            if (row.key.text.trim().isNotEmpty)
              row.key.text.trim(): row.value.text.trim(),
        },
        colorVariations: _colorSelections.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        latitude: double.tryParse(_latCtrl.text.trim()),
        longitude: double.tryParse(_lngCtrl.text.trim()),
        images: List.from(_existingImageUrls),
      );

  Future<void> _saveDraft({bool silent = false}) async {
    if (_nameCtrl.text.trim().isEmpty) {
      if (!silent) _showSnack('Please enter a product name first');
      return;
    }
    if (!silent) setState(() => _draftSaving = true);
    try {
      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;
      final form = _buildForm(isDraft: true);
      Product result;
      if (_effectiveDraftId != null) {
        result = await repo.updateProduct(_effectiveDraftId!, form);
      } else {
        result = await repo.createProductMultipart(
          form: form,
          images: _selectedImages,
          video: _selectedVideo,
        );
        if (mounted) setState(() => _currentDraftId = result.id);
      }
      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
        if (!silent) _showSnack('Draft saved!');
      }
    } catch (e) {
      if (mounted && !silent) _showSnack('Failed to save draft: $e');
    } finally {
      if (mounted && !silent) setState(() => _draftSaving = false);
    }
  }

  Future<void> _publishProduct() async {
    if (_nameCtrl.text.trim().isEmpty || _selectedCategoryId == null) {
      _showSnack('Please fill in name and category before publishing');
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;
      if (_effectiveDraftId != null) {
        await repo.publishDraft(_effectiveDraftId!);
      } else {
        final form = _buildForm();
        await repo.createProductMultipart(
          form: form,
          images: _selectedImages,
          video: _selectedVideo,
        );
      }
      if (mounted) {
        _showSnack(_isEditing ? 'Product updated!' : 'Product published!');
        ref.invalidate(productsNotifierProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Image helpers
  // ---------------------------------------------------------------------------

  Future<ImageSource?> _showSourcePicker() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final source = await _showSourcePicker();
    if (source == null) return;

    if (source == ImageSource.camera) {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;
      await _processPickedImages([picked]);
    } else {
      final picked = await _picker.pickMultiImage();
      if (picked.isEmpty) return;
      await _processPickedImages(picked);
    }
  }

  Future<void> _processPickedImages(List<XFile> picked) async {
    for (final raw in picked) {
      if (_selectedImages.length >= 10) break;
      if (!mounted) break;

      final choice = await showDialog<ImageProcessingChoice>(
        context: context,
        builder: (_) => const ImageProcessingDialog(),
      );
      if (choice == null) continue;
      if (!mounted) break;

      XFile? finalImage;
      if (choice == ImageProcessingChoice.removeBackground) {
        // Reset notifier so AiPreviewScreen starts fresh each time.
        ref.read(aiImageNotifierProvider.notifier).reset();
        if (!mounted) break;
        finalImage = await context.push<XFile>(RouteNames.aiPreview, extra: raw);
      } else if (choice == ImageProcessingChoice.crop) {
        finalImage = await context.push<XFile>(RouteNames.cropEditor, extra: raw);
      } else {
        finalImage =
            await ref.read(aiImageServiceProvider).compressFinalImage(raw);
      }

      if (finalImage != null && mounted) {
        setState(() { _selectedImages.add(finalImage!); _hasUnsavedChanges = true; });
      }
    }
  }

  void _removeImage(int index) =>
      setState(() { _selectedImages.removeAt(index); _hasUnsavedChanges = true; });

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) setState(() { _selectedVideo = picked; _hasUnsavedChanges = true; });
  }

  // ---------------------------------------------------------------------------
  // Spec helpers
  // ---------------------------------------------------------------------------

  void _addSpec() => setState(() => _specs.add((
        key: TextEditingController(),
        value: TextEditingController(),
      )));

  void _removeSpec(int index) {
    _specs[index].key.dispose();
    _specs[index].value.dispose();
    setState(() => _specs.removeAt(index));
  }

  // ---------------------------------------------------------------------------
  // Tag helpers
  // ---------------------------------------------------------------------------

  void _addTag() {
    final tag = _tagInputCtrl.text.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagInputCtrl.clear();
      _hasUnsavedChanges = true;
    });
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      _showSnack('Please select a category');
      return;
    }
    if (!_isEditing && _selectedImages.isEmpty) {
      _showSnack('Please add at least one product image');
      return;
    }

    setState(() => _loading = true);
    try {
      final form = _buildForm();

      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;

      if (_isEditing) {
        await repo.updateProduct(widget.initialProduct!.id, form);
        ref.invalidate(productDetailProvider(widget.initialProduct!.id));
      } else {
        await repo.createProductMultipart(
          form: form,
          images: _selectedImages,
          video: _selectedVideo,
        );
      }

      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
        _showSnack(_isEditing ? 'Product updated!' : 'Product added successfully');
        ref.invalidate(productsNotifierProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final pct = _completionPct;
    final progressColor = pct >= 80
        ? Colors.green
        : pct >= 40
            ? Colors.orange
            : AppColors.secondary;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final leave = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Leave without saving?'),
              content: const Text('Your unsaved changes will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Stay'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Leave'),
                ),
              ],
            ),
          );
          if (leave == true && context.mounted) context.pop();
        }
      },
      child: LoadingOverlay(
        isLoading: _loading,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEditing
                ? (_isDraft ? 'Edit Draft' : 'Edit Product')
                : 'Add Product'),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress + auto-save status
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(progressColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$pct%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                  if (_isDraft) ...[
                    const SizedBox(height: 4),
                    Text(
                      _draftSaving
                          ? 'Saving draft...'
                          : _hasUnsavedChanges
                              ? 'Unsaved changes'
                              : 'Draft saved',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 16),
                  _buildMediaSection(),
                  const SizedBox(height: 16),
                  _buildSpecificationsSection(),
                  const SizedBox(height: 16),
                  _buildColorVariationsSection(),
                  const SizedBox(height: 16),
                  _buildPricingSection(),
                  const SizedBox(height: 16),
                  _buildCategorySection(),
                  const SizedBox(height: 16),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  // Save as Draft button
                  OutlinedButton(
                    onPressed: _draftSaving ? null : () => _saveDraft(),
                    child: _draftSaving
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Saving...'),
                            ],
                          )
                        : const Text('Save as Draft'),
                  ),
                  const SizedBox(height: 10),
                  // Publish / Save button
                  AppButton(
                    label: _isDraft
                        ? 'Publish Product'
                        : (_isEditing ? 'Save Changes' : 'Add Product'),
                    loading: _loading,
                    onTap: _isDraft ? _publishProduct : _submit,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Basic Information
  // ---------------------------------------------------------------------------

  Widget _buildBasicInfoSection() {
    return _SectionCard(
      title: 'Basic Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _nameCtrl,
            label: 'Product Name',
            hint: 'e.g. Premium Silk Saree',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _descCtrl,
            label: 'Description',
            hint: 'Describe your product in detail...',
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _brandCtrl,
            label: 'Brand',
            hint: 'Brand name',
          ),
          const SizedBox(height: 12),
          _buildTagInput(),
        ],
      ),
    );
  }

  Widget _buildTagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _tagInputCtrl,
                label: 'Tags',
                hint: 'Add tag...',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            AppButton(
              label: 'Add',
              variant: AppButtonVariant.outlined,
              onTap: _addTag,
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _tags
                .map((tag) => Chip(
                      label: Text(tag,
                          style:
                              const TextStyle(color: AppColors.textPrimary)),
                      backgroundColor: AppColors.surface3,
                      deleteIconColor: AppColors.textMuted,
                      onDeleted: () =>
                          setState(() => _tags.remove(tag)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Media
  // ---------------------------------------------------------------------------

  Widget _buildMediaSection() {
    return _SectionCard(
      title: 'Media',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Images',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
              Text(
                '${_existingImageUrls.length + _selectedImages.length}/10',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildImageGrid(),
          const SizedBox(height: 4),
          Text(
            'PNG, JPG, WebP · Max 10 images · 5 MB each',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          _buildVideoPicker(),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    const tileSize = 90.0;
    final totalCount = _existingImageUrls.length + _selectedImages.length;
    final canAdd = !_isEditing && totalCount < 10;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Existing URL thumbnails (edit mode)
        ..._existingImageUrls.asMap().entries.map((entry) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  entry.value,
                  width: tileSize,
                  height: tileSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: tileSize,
                    height: tileSize,
                    color: AppColors.surface3,
                    child: const Icon(Icons.broken_image_outlined,
                        color: AppColors.textMuted),
                  ),
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => setState(
                      () => _existingImageUrls.removeAt(entry.key)),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),

        // Newly picked local image tiles (create mode only)
        ..._selectedImages.asMap().entries.map((entry) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<Uint8List>(
                  future: entry.value.readAsBytes(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Container(
                        width: tileSize,
                        height: tileSize,
                        color: AppColors.surface3,
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    return Image.memory(
                      snap.data!,
                      width: tileSize,
                      height: tileSize,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => _removeImage(entry.key),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),

        if (canAdd)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.border, style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.textMuted),
                  SizedBox(height: 4),
                  Text('Upload',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Video (optional)',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectedVideo == null ? _pickVideo : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface3,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.border),
            ),
            child: _selectedVideo == null
                ? const Column(
                    children: [
                      Icon(Icons.videocam_outlined,
                          color: AppColors.textMuted),
                      SizedBox(height: 4),
                      Text('Upload product video',
                          style: TextStyle(color: AppColors.primary)),
                      SizedBox(height: 2),
                      Text('MP4, MOV · Max 100 MB',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.videocam,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedVideo!.name,
                          style: const TextStyle(
                              color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textMuted),
                        onPressed: () =>
                            setState(() => _selectedVideo = null),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Specifications
  // ---------------------------------------------------------------------------

  Widget _buildSpecificationsSection() {
    return _SectionCard(
      title: 'Specifications',
      trailing: TextButton.icon(
        onPressed: _addSpec,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('+ Add Row'),
      ),
      child: _specs.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No specifications yet. Add one.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          : Column(
              children: _specs.asMap().entries.map((entry) {
                final i = entry.key;
                final row = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: row.key,
                          label: 'Key',
                          hint: 'e.g. Material',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextField(
                          controller: row.value,
                          label: 'Value',
                          hint: 'e.g. Cotton',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.textMuted),
                        onPressed: () => _removeSpec(i),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Color Variations
  // ---------------------------------------------------------------------------

  Widget _buildColorVariationsSection() {
    return _SectionCard(
      title: 'Color Variations',
      subtitle: 'For clothing/accessories',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _colorSwatches.map(((String, String) swatch) {
          final hex = swatch.$1;
          final label = swatch.$2;
          final selected = _colorSelections[hex] ?? false;
          final color = _hexToColor(hex);
          return GestureDetector(
            onTap: () =>
                setState(() => _colorSelections[hex] = !selected),
            child: Tooltip(
              message: label,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.border,
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: selected
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: _isLight(color)
                            ? Colors.black
                            : Colors.white,
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  bool _isLight(Color c) =>
      c.computeLuminance() > 0.5;

  // ---------------------------------------------------------------------------
  // Section: Pricing & Stock
  // ---------------------------------------------------------------------------

  Widget _buildPricingSection() {
    return _SectionCard(
      title: 'Pricing & Stock',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _mrpCtrl,
                  label: 'MRP / Original Price (INR)',
                  hint: 'e.g. 999',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    if (double.tryParse(v.trim()) == null) {
                      return 'Invalid price';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _priceCtrl,
                  label: 'Selling Price (INR) *',
                  hint: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) {
                      return 'Invalid price';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _discountCtrl,
                  label: 'Discount Badge (%)',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0 || n > 100) {
                      return '0–100 only';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration:
                      const InputDecoration(labelText: 'Unit'),
                  hint: const Text('Select unit'),
                  items: _units
                      .map((u) => DropdownMenuItem(
                            value: u,
                            child: Text(u),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedUnit = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _stockCtrl,
                  label: 'Stock Quantity *',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (int.tryParse(v.trim()) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration:
                      const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                        value: 'active',
                        child: Text('Active')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Category
  // ---------------------------------------------------------------------------

  Widget _buildCategorySection() {
    return _SectionCard(
      title: 'Category',
      child: ref.watch(categoriesProvider).when(
            data: (cats) => DropdownButtonFormField<int>(
              initialValue: _selectedCategoryId,
              decoration:
                  const InputDecoration(labelText: 'Category *'),
              hint: const Text('Select category'),
              isExpanded: true,
              items: cats
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedCategoryId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Row(
              children: [
                const Text('Failed to load categories',
                    style: TextStyle(color: AppColors.error)),
                TextButton(
                  onPressed: () => ref.invalidate(categoriesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Product Location
  // ---------------------------------------------------------------------------

  Widget _buildLocationSection() {
    return _SectionCard(
      title: 'Product Location',
      subtitle: 'Optional',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _latCtrl,
                  label: 'Latitude',
                  hint: '21.2514',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = double.tryParse(v.trim());
                    if (n == null || n < -90 || n > 90) {
                      return 'Invalid latitude';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _lngCtrl,
                  label: 'Longitude',
                  hint: '81.6296',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = double.tryParse(v.trim());
                    if (n == null || n < -180 || n > 180) {
                      return 'Invalid longitude';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Set precise location for hyperlocal search visibility',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SectionCard helper
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

