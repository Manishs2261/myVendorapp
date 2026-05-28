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

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

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

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) _prefillFromProduct(widget.initialProduct!);
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
  // Image helpers
  // ---------------------------------------------------------------------------

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    await _processPickedImages(picked);
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
        setState(() => _selectedImages.add(finalImage!));
      }
    }
  }

  void _removeImage(int index) =>
      setState(() => _selectedImages.removeAt(index));

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedVideo = picked);
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
      final form = ProductForm(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        originalPrice: _mrpCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(_mrpCtrl.text.trim()),
        discountPercentage: _discountCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_discountCtrl.text.trim()),
        stock: int.parse(_stockCtrl.text.trim()),
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
        _showSnack(_isEditing ? 'Product updated!' : 'Product added successfully');
        ref.invalidate(productsListProvider);
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
    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                AppButton(
                  label: _isEditing ? 'Save Changes' : 'Add Product',
                  loading: _loading,
                  onTap: _submit,
                ),
                const SizedBox(height: 32),
              ],
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

