import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/main_shell.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../providers/shop_provider.dart';
import '../../domain/shop_models.dart';

class ShopProfileScreen extends ConsumerStatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  ConsumerState<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends ConsumerState<ShopProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Details controllers
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();

  // Address controllers
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();

  // Contact controllers
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();

  // Location controllers
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  String? _businessType;
  String? _idType;

  GoogleMapController? _mapController;
  LatLng? _markerPosition;

  bool _initialized = false;
  bool _saving = false;
  bool _verifying = false;
  bool _locationLoading = false;

  static const _businessTypes = ['Retail', 'Wholesale', 'Service', 'Food & Beverage', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(
      () => ref.read(shopNotifierProvider.notifier).refreshInBackground(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _gstCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _stateCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _whatsappCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _populateControllers(Shop shop) {
    _nameCtrl.text = shop.shopName ?? shop.businessName;
    _descCtrl.text = shop.description ?? '';
    _gstCtrl.text = shop.gstNumber ?? '';
    _streetCtrl.text = shop.address ?? '';
    _cityCtrl.text = shop.city ?? '';
    _postalCtrl.text = shop.pincode ?? '';
    _stateCtrl.text = shop.state ?? '';
    _phoneCtrl.text = shop.contactPhone ?? '';
    _emailCtrl.text = shop.contactEmail ?? '';
    _whatsappCtrl.text = shop.whatsappNumber ?? '';
    _latCtrl.text = shop.latitude?.toString() ?? '';
    _lngCtrl.text = shop.longitude?.toString() ?? '';
    _businessType = _businessTypes.firstWhere(
      (t) => t.toUpperCase().replaceAll(' & ', '_').replaceAll(' ', '_') ==
          (shop.businessType ?? '').toUpperCase(),
      orElse: () => _businessTypes.first,
    );
    _idType = shop.idType;
    if (shop.latitude != null && shop.longitude != null) {
      _markerPosition = LatLng(shop.latitude!, shop.longitude!);
    }
    _initialized = true;
  }

  Future<void> _requestVerification() async {
    setState(() => _verifying = true);
    try {
      await ref.read(shopNotifierProvider.notifier).requestVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification request submitted! We\'ll review your shop soon.')),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'business_type': _businessType?.toUpperCase().replaceAll(' & ', '_').replaceAll(' ', '_'),
      'gst_number': _gstCtrl.text.trim(),
      'id_type': _idType,
      'address': _streetCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'pincode': _postalCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'contact_phone': _phoneCtrl.text.trim(),
      'contact_email': _emailCtrl.text.trim(),
      'whatsapp_number': _whatsappCtrl.text.trim(),
      if (_latCtrl.text.isNotEmpty) 'latitude': double.tryParse(_latCtrl.text),
      if (_lngCtrl.text.isNotEmpty) 'longitude': double.tryParse(_lngCtrl.text),
    };

    await ref.read(shopNotifierProvider.notifier).save(data);

    if (mounted) {
      setState(() => _saving = false);
      final error = ref.read(shopNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error != null ? 'Failed to save: $error' : 'Shop profile saved'),
          backgroundColor: error != null ? Colors.red : Colors.green,
        ),
      );
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text(
                'Please enable location services to pick your shop location.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        if (open == true) await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Location permission denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied. Enable in settings.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _markerPosition = latlng;
        _latCtrl.text = pos.latitude.toStringAsFixed(6);
        _lngCtrl.text = pos.longitude.toStringAsFixed(6);
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 15));
    } catch (e) {
      _showSnack('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickAndUploadLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    await ref.read(shopNotifierProvider.notifier).uploadLogo(file);
    if (mounted) {
      final err = ref.read(shopNotifierProvider).error;
      _showSnack(err != null ? 'Logo upload failed' : 'Logo updated');
    }
  }

  Future<void> _pickAndUploadBanner() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    await ref.read(shopNotifierProvider.notifier).uploadBanner(file);
    if (mounted) {
      final err = ref.read(shopNotifierProvider).error;
      _showSnack(err != null ? 'Banner upload failed' : 'Banner updated');
    }
  }

  Future<void> _pickAndUploadGallery(int currentCount) async {
    final remaining = 10 - currentCount;
    if (remaining <= 0) {
      _showSnack('Gallery is full (max 10 images)');
      return;
    }
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85, limit: remaining);
    if (files.isEmpty) return;
    await ref.read(shopNotifierProvider.notifier).uploadGallery(files);
    if (mounted) {
      final err = ref.read(shopNotifierProvider).error;
      _showSnack(err != null ? 'Gallery upload failed' : '${files.length} image(s) added');
    }
  }

  Future<void> _removeGalleryImage(String url) async {
    await ref.read(shopNotifierProvider.notifier).removeGalleryImage(url);
    if (mounted) {
      final err = ref.read(shopNotifierProvider).error;
      if (err != null) _showSnack('Remove failed');
    }
  }

  Future<void> _pickAndUploadIdDocument() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    await ref.read(shopNotifierProvider.notifier).uploadIdDocument(file);
    if (mounted) {
      final err = ref.read(shopNotifierProvider).error;
      _showSnack(err != null ? 'Document upload failed' : 'Document uploaded');
    }
  }

  bool _isProfileComplete(Shop shop, int totalProducts) {
    final checks = [
      shop.shopName != null && shop.shopName!.isNotEmpty,
      shop.description != null && shop.description!.isNotEmpty,
      shop.address != null && shop.address!.isNotEmpty,
      shop.city != null && shop.city!.isNotEmpty,
      shop.state != null && shop.state!.isNotEmpty,
      shop.pincode != null && shop.pincode!.isNotEmpty,
      shop.logoUrl != null,
      shop.contactPhone != null && shop.contactPhone!.isNotEmpty,
      shop.contactEmail != null && shop.contactEmail!.isNotEmpty,
      shop.latitude != null,
      shop.longitude != null,
      shop.idDocumentUrl != null,
      shop.gallery.isNotEmpty,
      totalProducts >= 5,
    ];
    return checks.every((c) => c);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isDarkModeProvider);
    final shopAsync = ref.watch(shopNotifierProvider);
    final totalProducts =
        ref.watch(dashboardNotifierProvider).valueOrNull?.totalProducts ?? 0;

    final shop = shopAsync.valueOrNull;
    final isComplete = shop != null && _isProfileComplete(shop, totalProducts);

    ref.listen(shopNotifierProvider, (prev, next) {
      if (!_initialized && next.hasValue) {
        _populateControllers(next.value!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shop Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Your shop details and gallery',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          if (shop != null && shop.verified)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                avatar: const Icon(Icons.verified_rounded, size: 14, color: Colors.green),
                label: const Text('Verified', style: TextStyle(fontSize: 12, color: Colors.green)),
                backgroundColor: Colors.green.withValues(alpha: 0.12),
                side: BorderSide(color: Colors.green.withValues(alpha: 0.4)),
                padding: EdgeInsets.zero,
              ),
            )
          else if (shop != null && shop.verificationRequested)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                avatar: const Icon(Icons.hourglass_top_rounded, size: 14, color: Colors.orange),
                label: const Text('Under Review', style: TextStyle(fontSize: 12, color: Colors.orange)),
                backgroundColor: Colors.orange.withValues(alpha: 0.12),
                side: BorderSide(color: Colors.orange.withValues(alpha: 0.4)),
                padding: EdgeInsets.zero,
              ),
            )
          else
            Tooltip(
              message: isComplete ? '' : 'Complete your profile 100% to verify',
              child: _verifying
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : TextButton.icon(
                      onPressed: isComplete ? _requestVerification : null,
                      icon: const Icon(Icons.verified_outlined, size: 16),
                      label: const Text('Verify Now'),
                    ),
            ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: _saving ? null : _saveChanges,
            icon: _saving
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined, size: 16),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab( text: 'Details'),
            Tab(text: 'Media'),
            Tab( text: 'Location'),
          ],
        ),
      ),
      body: shopAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(shopNotifierProvider),
        ),
        data: (shop) {
          // Populate on first load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_initialized) _populateControllers(shop);
          });
          final totalProducts = ref
              .watch(dashboardNotifierProvider)
              .valueOrNull
              ?.totalProducts ?? 0;
          return Column(
            children: [
              if(!shop.verified)
              _ProfileCompletionBar(shop: shop, totalProducts: totalProducts),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DetailsTab(
                        nameCtrl: _nameCtrl,
                        descCtrl: _descCtrl,
                        gstCtrl: _gstCtrl,
                        streetCtrl: _streetCtrl,
                        cityCtrl: _cityCtrl,
                        postalCtrl: _postalCtrl,
                        stateCtrl: _stateCtrl,
                        phoneCtrl: _phoneCtrl,
                        emailCtrl: _emailCtrl,
                        whatsappCtrl: _whatsappCtrl,
                        businessType: _businessType,
                        idType: _idType,
                        idDocumentUrl: shop.idDocumentUrl,
                        onBusinessTypeChanged: (v) => setState(() => _businessType = v),
                        onIdTypeChanged: (v) => setState(() => _idType = v),
                        onUploadDocument: _pickAndUploadIdDocument,
                      ),
                      _MediaTab(
                        shop: shop,
                        onUploadLogo: _pickAndUploadLogo,
                        onUploadBanner: _pickAndUploadBanner,
                        onUploadGallery: () => _pickAndUploadGallery(shop.gallery.length),
                        onRemoveGallery: _removeGalleryImage,
                      ),
                      _LocationTab(
                        latCtrl: _latCtrl,
                        lngCtrl: _lngCtrl,
                        markerPosition: _markerPosition,
                        locationLoading: _locationLoading,
                        onUseCurrentLocation: _useCurrentLocation,
                        onMapCreated: (ctrl) => _mapController = ctrl,
                        onMarkerDragEnd: (latlng) {
                          setState(() {
                            _markerPosition = latlng;
                            _latCtrl.text = latlng.latitude.toStringAsFixed(6);
                            _lngCtrl.text = latlng.longitude.toStringAsFixed(6);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Profile Completion Bar ───────────────────────────────────────────────────

class _ProfileCompletionBar extends StatelessWidget {
  final Shop shop;
  final int totalProducts;
  const _ProfileCompletionBar({required this.shop, required this.totalProducts});

  @override
  Widget build(BuildContext context) {
    final checks = [
      ('Shop name',    shop.shopName != null && shop.shopName!.isNotEmpty),
      ('Description',  shop.description != null && shop.description!.isNotEmpty),
      ('Address',      shop.address != null && shop.address!.isNotEmpty),
      ('City',         shop.city != null && shop.city!.isNotEmpty),
      ('State',        shop.state != null && shop.state!.isNotEmpty),
      ('Pincode',      shop.pincode != null && shop.pincode!.isNotEmpty),
      ('Logo',         shop.logoUrl != null),
      ('Phone',        shop.contactPhone != null && shop.contactPhone!.isNotEmpty),
      ('Email',        shop.contactEmail != null && shop.contactEmail!.isNotEmpty),
      ('Latitude',     shop.latitude != null),
      ('Longitude',    shop.longitude != null),
      ('ID document',  shop.idDocumentUrl != null),
      ('Gallery',      shop.gallery.isNotEmpty),
      ('5+ products',  totalProducts >= 5),
    ];

    final filled = checks.where((c) => c.$2).length;
    final score = (filled / checks.length * 100).round();
    final pending = checks.where((c) => !c.$2).toList();

    final scoreColor = score >= 80
        ? Colors.green
        : score >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Profile Completion',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 8),
              Text('$score%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: scoreColor)),
              if (pending.isNotEmpty) ...[
                const Spacer(),
                Text('${pending.length} left',
                    style: TextStyle(
                        fontSize: 11,
                        color: scoreColor,
                        fontWeight: FontWeight.w500)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: Colors.white12,
              color: scoreColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: checks
                .map((c) => _CheckChip(label: c.$1, done: c.$2))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CheckChip extends StatelessWidget {
  final String label;
  final bool done;
  const _CheckChip({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          done ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: 13,
          color: done ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: done ? Colors.white70 : Colors.orange,
            fontWeight: done ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Details Tab ──────────────────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController gstCtrl;
  final TextEditingController streetCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController postalCtrl;
  final TextEditingController stateCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController whatsappCtrl;
  final String? businessType;
  final String? idType;
  final String? idDocumentUrl;
  final void Function(String?) onBusinessTypeChanged;
  final void Function(String?) onIdTypeChanged;
  final VoidCallback onUploadDocument;

  static const _businessTypes = ['Retail', 'Wholesale', 'Service', 'Food & Beverage', 'Other'];
  static const _idTypes = ['Aadhaar Card', 'PAN Card', 'Passport', 'Voter ID', 'Driving License'];

  const _DetailsTab({
    required this.nameCtrl,
    required this.descCtrl,
    required this.gstCtrl,
    required this.streetCtrl,
    required this.cityCtrl,
    required this.postalCtrl,
    required this.stateCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.whatsappCtrl,
    required this.businessType,
    required this.idType,
    required this.idDocumentUrl,
    required this.onBusinessTypeChanged,
    required this.onIdTypeChanged,
    required this.onUploadDocument,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Shop Information',
          children: [
            _field(nameCtrl, 'Shop Name', required: true, maxLength: 100),
            const SizedBox(height: 12),
            _field(descCtrl, 'Description', maxLines: 4, maxLength: 1000),
            const SizedBox(height: 12),
            _dropdown(context, 'Business Type', businessType, _businessTypes, onBusinessTypeChanged),
            const SizedBox(height: 12),
            _field(gstCtrl, 'GST Number', maxLength: 50),
            const SizedBox(height: 12),
            _dropdown(context, 'Identity Type', idType, _idTypes, onIdTypeChanged,
                hint: 'Select Identity Type'),
            const SizedBox(height: 12),
            _DocumentUploader(url: idDocumentUrl, onTap: onUploadDocument),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Address',
          children: [
            _field(streetCtrl, 'Street Address', required: true, maxLength: 200),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field(cityCtrl, 'City', required: true, maxLength: 20)),
              const SizedBox(width: 12),
              Expanded(child: _field(postalCtrl, 'Postal Code',
                  required: true, maxLength: 8, keyboard: TextInputType.number)),
            ]),
            const SizedBox(height: 12),
            _field(stateCtrl, 'State', required: true, maxLength: 50),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Contact Details',
          children: [
            _fieldWithVerify(context, phoneCtrl, 'Phone Number',
                maxLength: 10, keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            _fieldWithVerify(context, emailCtrl, 'Email',
                maxLength: 100, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _field(whatsappCtrl, 'WhatsApp Number',
                maxLength: 10, keyboard: TextInputType.phone),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false,
      int maxLines = 1,
      int? maxLength,
      TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: required ? '$label *' : label),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) {
                return '$label is required';
              }
              if (maxLength != null && v.length > maxLength) {
                return '$label cannot exceed $maxLength characters';
              }
              return null;
            }
          : (maxLength != null
              ? (v) => (v != null && v.length > maxLength)
                  ? '$label cannot exceed $maxLength characters'
                  : null
              : null),
    );
  }

  Widget _fieldWithVerify(BuildContext context, TextEditingController ctrl,
      String label,
      {int? maxLength,
      TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      maxLength: maxLength,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: '$label *',
        suffixIcon: TextButton(
          onPressed: () {},
          child: const Text('Verify', style: TextStyle(fontSize: 12)),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return '$label is required';
        }
        if (maxLength != null && v.length > maxLength) {
          return '$label cannot exceed $maxLength characters';
        }
        return null;
      },
    );
  }

  Widget _dropdown(BuildContext context, String label, String? value,
      List<String> items, void Function(String?) onChanged,
      {String? hint}) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label),
      hint: hint != null ? Text(hint) : null,
      items: items
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DocumentUploader extends StatelessWidget {
  final String? url;
  final VoidCallback onTap;
  const _DocumentUploader({required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Document *',
            style: TextStyle(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 8),
        if (url != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url!, height: 100, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink()),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.upload_file_outlined, size: 16),
          label: Text(url != null ? 'Replace Document' : 'Choose File'),
        ),
        const SizedBox(height: 4),
        const Text('Upload a clear scan or photo of your Identity Card',
            style: TextStyle(fontSize: 11, color: Colors.white38)),
      ],
    );
  }
}

// ─── Media Tab ────────────────────────────────────────────────────────────────

class _MediaTab extends StatelessWidget {
  final Shop shop;
  final VoidCallback onUploadLogo;
  final VoidCallback onUploadBanner;
  final VoidCallback onUploadGallery;
  final void Function(String) onRemoveGallery;

  const _MediaTab({
    required this.shop,
    required this.onUploadLogo,
    required this.onUploadBanner,
    required this.onUploadGallery,
    required this.onRemoveGallery,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Shop Logo / Photo',
          titleSuffix: const Text('PNG, JPG · Recommended 200×200',
              style: TextStyle(fontSize: 11, color: Colors.white38)),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      shop.logoUrl != null ? NetworkImage(shop.logoUrl!) : null,
                  child: shop.logoUrl == null
                      ? const Icon(Icons.store_outlined, size: 32)
                      : null,
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: onUploadLogo,
                  icon: const Icon(Icons.upload_outlined, size: 16),
                  label: const Text('Upload Logo'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Shop Banner',
          titleSuffix: const Text('Recommended 1200×300px',
              style: TextStyle(fontSize: 11, color: Colors.white38)),
          children: [
            if (shop.bannerUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  shop.bannerUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: onUploadBanner,
              icon: const Icon(Icons.upload_outlined, size: 16),
              label: const Text('Upload Banner'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Shop Gallery',
          titleSuffix: Text('${shop.gallery.length} / 10 images',
              style: const TextStyle(fontSize: 12, color: Colors.white54)),
          children: [
            _GalleryGrid(
              images: shop.gallery,
              onRemove: onRemoveGallery,
              onAdd: onUploadGallery,
              maxImages: 10,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  final List<String> images;
  final void Function(String) onRemove;
  final VoidCallback onAdd;
  final int maxImages;

  const _GalleryGrid({
    required this.images,
    required this.onRemove,
    required this.onAdd,
    required this.maxImages,
  });

  @override
  Widget build(BuildContext context) {
    final showAdd = images.length < maxImages;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length + (showAdd ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, i) {
        if (i == images.length) {
          return GestureDetector(
            onTap: onAdd,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white38),
            ),
          );
        }
        final url = images[i];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                      color: Colors.white10,
                      child: const Icon(Icons.broken_image_outlined))),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () => onRemove(url),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Location Tab ─────────────────────────────────────────────────────────────

class _LocationTab extends StatelessWidget {
  final TextEditingController latCtrl;
  final TextEditingController lngCtrl;
  final LatLng? markerPosition;
  final bool locationLoading;
  final VoidCallback onUseCurrentLocation;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(LatLng) onMarkerDragEnd;

  const _LocationTab({
    required this.latCtrl,
    required this.lngCtrl,
    required this.markerPosition,
    required this.locationLoading,
    required this.onUseCurrentLocation,
    required this.onMapCreated,
    required this.onMarkerDragEnd,
  });

  static const _indiaCenter = LatLng(20.5937, 78.9629);

  @override
  Widget build(BuildContext context) {
    final initialPosition = markerPosition ?? _indiaCenter;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Google Map Location',
          titleSuffix: locationLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : TextButton.icon(
                  onPressed: onUseCurrentLocation,
                  icon: const Icon(Icons.my_location, size: 14),
                  label: const Text('Use Current Location',
                      style: TextStyle(fontSize: 12)),
                ),
          children: [
            SizedBox(
              height: 420,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialPosition,
                    zoom: markerPosition != null ? 14 : 5,
                  ),
                  onMapCreated: onMapCreated,
                  markers: markerPosition != null
                      ? {
                          Marker(
                            markerId: const MarkerId('shop'),
                            position: markerPosition!,
                            draggable: true,
                            onDragEnd: onMarkerDragEnd,
                          )
                        }
                      : {},
                  onTap: (latlng) => onMarkerDragEnd(latlng),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click on the map or drag the marker to set your precise shop location.',
              style: TextStyle(fontSize: 11, color: Colors.white38),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: latCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]'))
                ],
                decoration: const InputDecoration(labelText: 'Latitude *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: lngCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]'))
                ],
                decoration: const InputDecoration(labelText: 'Longitude *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget? titleSuffix;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.titleSuffix,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              if (titleSuffix != null) titleSuffix!,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
