import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
  String? _existingVideoUrl;
  bool _removeVideo = false;

  // Custom color variations (hex values not in the predefined palette)
  final List<({String hex, String name})> _customColors = [];
  final _customColorNameCtrl = TextEditingController();
  Color _customPickerColor = const Color(0xFFE91E63);

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



  void _markDirty() {
    if (!_hasUnsavedChanges && mounted) setState(() => _hasUnsavedChanges = true);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) _prefillFromProduct(widget.initialProduct!);
    for (final ctrl in [
      _nameCtrl, _descCtrl, _brandCtrl, _mrpCtrl,
      _priceCtrl, _discountCtrl, _stockCtrl,
    ]) {
      ctrl.addListener(_markDirty);
    }
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (_hasUnsavedChanges && _effectiveDraftId != null && _nameCtrl.text.trim().isNotEmpty) {
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
    _existingVideoUrl = p.videoUrl;
    for (final e in p.specifications.entries) {
      final keyCtrl = TextEditingController(text: e.key);
      final valCtrl = TextEditingController(text: e.value);
      keyCtrl.addListener(_markDirty);
      valCtrl.addListener(_markDirty);
      _specs.add((
        key: keyCtrl,
        value: valCtrl,
      ));
    }
    final knownHexes = _colorSwatches.map((s) => s.$1).toSet();
    for (final hex in p.colorVariations) {
      if (knownHexes.contains(hex)) {
        _colorSelections[hex] = true;
      } else {
        _customColors.add((hex: hex, name: hex));
      }
    }
    _priceCtrl.text = p.price.toString();
    _mrpCtrl.text = p.originalPrice?.toString() ?? '';
    _discountCtrl.text = p.discountPercentage?.toString() ?? '';
    _stockCtrl.text = p.stock.toString();
    _status = (p.status == ProductStatus.outOfStock) ? 'inactive' : p.status.name;
    _selectedUnit = p.unit;
    _selectedCategoryId = p.categoryId;

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

    _customColorNameCtrl.dispose();
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
        colorVariations: [
          ..._colorSelections.entries.where((e) => e.value).map((e) => e.key),
          ..._customColors.map((c) => c.hex),
        ],
        latitude: null,
        longitude: null,
        images: List.from(_existingImageUrls),
        removeVideo: _removeVideo,
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
        if (_selectedImages.isNotEmpty || _selectedVideo != null) {
          result = await repo.updateProductMultipart(
            id: _effectiveDraftId!,
            form: form,
            images: _selectedImages,
            video: _selectedVideo,
          );
        } else {
          result = await repo.updateProduct(_effectiveDraftId!, form);
        }
      } else {
        result = await repo.createProductMultipart(
          form: form,
          images: _selectedImages,
          video: _selectedVideo,
        );
        if (mounted) setState(() => _currentDraftId = result.id);
      }
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
          _existingImageUrls.clear();
          _existingImageUrls.addAll(result.imageUrls);
          _selectedImages.clear();
          _selectedVideo = null;
          if (result.videoUrl != null) {
            _existingVideoUrl = result.videoUrl;
          }
        });
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
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      await _processPickedImages([picked]);
    }
  }

  Future<void> _processPickedImages(List<XFile> picked) async {
    if (picked.isEmpty || !mounted) return;

    // Ask once — apply the same processing choice to every picked image.
    final choice = await showDialog<ImageProcessingChoice>(
      context: context,
      builder: (_) => const ImageProcessingDialog(),
    );
    if (choice == null || !mounted) return;

    for (final raw in picked) {
      if (_selectedImages.length >= 10) break;
      if (!mounted) break;

      XFile? finalImage;
      if (choice == ImageProcessingChoice.removeBackground) {
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
    if (picked == null) return;

    final bytes = await picked.length();
    const maxSizeBytes = 30 * 1024 * 1024; // 30 MB
    if (bytes > maxSizeBytes) {
      _showSnack('Video size must be less than 30 MB');
      return;
    }

    setState(() {
      _selectedVideo = picked;
      _hasUnsavedChanges = true;
    });
  }

  // ---------------------------------------------------------------------------
  // Spec helpers
  // ---------------------------------------------------------------------------

  void _addSpec() {
    if (_specs.length >= 30) {
      _showSnack('Maximum of 30 specifications allowed');
      return;
    }
    final keyCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    keyCtrl.addListener(_markDirty);
    valCtrl.addListener(_markDirty);
    setState(() {
      _specs.add((
        key: keyCtrl,
        value: valCtrl,
      ));
      _hasUnsavedChanges = true;
    });
  }

  void _removeSpec(int index) {
    _specs[index].key.dispose();
    _specs[index].value.dispose();
    setState(() => _specs.removeAt(index));
  }

  void _showBulkSpecPasteDialog() {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bulk Paste Specifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste specifications copy-pasted from spreadsheets or documents. Use one key-value pair per line.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Storage\t128GB\nBattery: 8000mAh\n...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = textCtrl.text.trim();
              if (text.isNotEmpty) {
                _parseAndAddBulkSpecs(text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _parseAndAddBulkSpecs(String text) {
    final lines = text.split('\n');
    int addedCount = 0;
    bool reachedLimit = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (_specs.length >= 30) {
        reachedLimit = true;
        break;
      }

      String key = '';
      String value = '';

      if (trimmed.contains('\t')) {
        final idx = trimmed.indexOf('\t');
        key = trimmed.substring(0, idx).trim();
        value = trimmed.substring(idx + 1).trim();
      } else if (trimmed.contains(':')) {
        final idx = trimmed.indexOf(':');
        key = trimmed.substring(0, idx).trim();
        value = trimmed.substring(idx + 1).trim();
      } else if (trimmed.contains('=')) {
        final idx = trimmed.indexOf('=');
        key = trimmed.substring(0, idx).trim();
        value = trimmed.substring(idx + 1).trim();
      } else {
        key = trimmed;
      }

      if (key.length > 100) key = key.substring(0, 100);
      if (value.length > 200) value = value.substring(0, 200);

      final keyCtrl = TextEditingController(text: key);
      final valCtrl = TextEditingController(text: value);
      keyCtrl.addListener(_markDirty);
      valCtrl.addListener(_markDirty);

      setState(() {
        _specs.add((
          key: keyCtrl,
          value: valCtrl,
        ));
      });
      addedCount++;
    }

    if (addedCount > 0) {
      setState(() => _hasUnsavedChanges = true);
      _showSnack('Imported $addedCount specifications');
    }
    if (reachedLimit) {
      _showSnack('Maximum of 30 specifications allowed');
    }
  }



  // ---------------------------------------------------------------------------
  // Tag helpers
  // ---------------------------------------------------------------------------

  void _addTag() {
    final rawText = _tagInputCtrl.text.trim();
    if (rawText.isEmpty) return;

    final parsedTags = rawText
        .split(RegExp(r'[\n,]'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (parsedTags.isEmpty) return;

    setState(() {
      for (var tag in parsedTags) {
        if (tag.length > 20) {
          tag = tag.substring(0, 20);
        }
        if (!_tags.contains(tag)) {
          if (_tags.length >= 50) {
            _showSnack('Maximum of 50 tags allowed');
            break;
          }
          _tags.add(tag);
        }
      }
      _tagInputCtrl.clear();
      _hasUnsavedChanges = true;
    });
  }

  void _onTagInputChanged(String val) {
    if (val.contains('\n') || val.contains(',')) {
      _addTag();
    } else {
      if (val.length > 20) {
        _tagInputCtrl.value = TextEditingValue(
          text: val.substring(0, 20),
          selection: const TextSelection.collapsed(offset: 20),
        );
      }
      setState(() {});
    }
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
        if (_selectedImages.isNotEmpty || _selectedVideo != null) {
          await repo.updateProductMultipart(
            id: widget.initialProduct!.id,
            form: form,
            images: _selectedImages,
            video: _selectedVideo,
          );
        } else {
          await repo.updateProduct(widget.initialProduct!.id, form);
        }
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
            builder: (ctx) => AlertDialog(
              title: const Text('Leave without saving?'),
              content: const Text('Your unsaved changes will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Stay'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
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
                  if (_effectiveDraftId != null) ...[
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
            maxLength: 100,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (v.trim().length > 100) return 'Name cannot exceed 100 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _descCtrl,
            label: 'Description',
            hint: 'Describe your product in detail...',
            maxLines: 4,
            maxLength: 2000,
            validator: (v) {
              if (v != null && v.trim().length > 2000) {
                return 'Description cannot exceed 2000 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _brandCtrl,
            label: 'Brand',
            hint: 'Brand name',
            maxLength: 50,
            validator: (v) {
              if (v != null && v.trim().length > 50) {
                return 'Brand name cannot exceed 50 characters';
              }
              return null;
            },
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
                hint: 'Add one or paste multiple (one per line)',
                maxLines: null,
                onChanged: _onTagInputChanged,
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
    final canAdd = totalCount < 10;

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
        // Show existing uploaded video (edit mode, before user picks a new one)
        if (_existingVideoUrl != null && _selectedVideo == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface3,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.videocam, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Product video uploaded',
                    style: TextStyle(color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _existingVideoUrl = null;
                    _removeVideo = true;
                    _markDirty();
                  }),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE05A5A),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Remove video', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: _selectedVideo == null ? _pickVideo : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
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
                        Text('MP4, MOV · Max 30 MB',
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: _showBulkSpecPasteDialog,
            icon: const Icon(Icons.paste, size: 16),
            label: const Text('Bulk Paste'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _addSpec,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Row'),
          ),
        ],
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
                          maxLength: 100,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              if (row.value.text.trim().isNotEmpty) {
                                return 'Key is required';
                              }
                            } else if (v.trim().length > 100) {
                              return 'Key cannot exceed 100 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextField(
                          controller: row.value,
                          label: 'Value',
                          hint: 'e.g. Cotton',
                          maxLength: 200,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              if (row.key.text.trim().isNotEmpty) {
                                return 'Value is required';
                              }
                            } else if (v.trim().length > 200) {
                              return 'Value cannot exceed 200 characters';
                            }
                            return null;
                          },
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

  void _addCustomColor() {
    final hex = _colorToHex(_customPickerColor);
    String name = _customColorNameCtrl.text.trim();
    if (name.isEmpty) name = hex;
    final currentTotal = _colorSelections.entries.where((e) => e.value).length + _customColors.length;
    if (currentTotal >= 5) {
      _showSnack('Maximum of 5 colors allowed');
      return;
    }
    final duplicate = _customColors.any(
      (c) => c.name.toLowerCase() == name.toLowerCase() || c.hex == hex,
    );
    if (duplicate) {
      _showSnack('This color or name is already added');
      return;
    }
    setState(() {
      _customColors.add((hex: hex, name: name));
      _customColorNameCtrl.clear();
      _customPickerColor = const Color(0xFFE91E63);
    });
    _markDirty();
  }

  Widget _buildColorVariationsSection() {
    return _SectionCard(
      title: 'Color Variations',
      subtitle: 'For clothing/accessories',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Predefined swatches
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorSwatches.map(((String, String) swatch) {
              final hex = swatch.$1;
              final label = swatch.$2;
              final selected = _colorSelections[hex] ?? false;
              final color = _hexToColor(hex);
              return GestureDetector(
                onTap: () {
                  final currentTotal = _colorSelections.entries.where((e) => e.value).length + _customColors.length;
                  if (!selected && currentTotal >= 5) {
                    _showSnack('Maximum of 5 colors allowed');
                    return;
                  }
                  setState(() => _colorSelections[hex] = !selected);
                },
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

          // Custom colors added by vendor
          if (_customColors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _customColors.map((c) {
                final color = _hexToColor(c.hex);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Tooltip(
                      message: c.name,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary, width: 2),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 18,
                          color: _isLight(color)
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => setState(() => _customColors.remove(c)),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE05A5A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Custom color input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Color preview / picker trigger
              GestureDetector(
                onTap: () async {
                  Color tempColor = _customPickerColor;
                  await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Pick a color'),
                      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      content: SingleChildScrollView(
                        child: StatefulBuilder(
                          builder: (ctx, setInner) => ColorPicker(
                            pickerColor: tempColor,
                            onColorChanged: (c) {
                              tempColor = c;
                              setInner(() {});
                            },
                            enableAlpha: false,
                            labelTypes: const [],
                            pickerAreaHeightPercent: 0.7,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            setState(() => _customPickerColor = tempColor);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Select'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _customPickerColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Icon(Icons.colorize,
                      size: 16, color: Colors.white70),
                ),
              ),
              const SizedBox(width: 8),

              // Color name input
              Expanded(
                child: TextField(
                  controller: _customColorNameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Color name (e.g. Navy Blue)',
                    hintStyle:
                        const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    filled: true,
                    fillColor: AppColors.surface3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: (_) => _addCustomColor(),
                ),
              ),
              const SizedBox(width: 8),

              // Add button
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: _addCustomColor,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('+ Add',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String _colorToHex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

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
                  maxLength: 10,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    if (double.tryParse(v.trim()) == null) {
                      return 'Invalid price';
                    }
                    if (v.trim().length > 10) {
                      return 'Maximum 10 digits allowed';
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
                  maxLength: 10,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) {
                      return 'Invalid price';
                    }
                    if (v.trim().length > 10) {
                      return 'Maximum 10 digits allowed';
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
                  maxLength: 2,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0 || n > 99) {
                      return '0–99 only';
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
                  maxLength: 5,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (int.tryParse(v.trim()) == null) {
                      return 'Invalid number';
                    }
                    if (v.trim().length > 5) {
                      return 'Maximum 5 digits allowed';
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

