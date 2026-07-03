import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../providers/profile_provider.dart';
import '../../domain/profile_models.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameCtrl = TextEditingController();
  final _alternatePhoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _languageCtrl = TextEditingController();

  String? _gender;
  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _alternatePhoneCtrl.dispose();
    _dobCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _languageCtrl.dispose();
    super.dispose();
  }

  void _initFields(VendorProfile profile) {
    if (_initialized) return;
    _nameCtrl.text = profile.name ?? '';
    _alternatePhoneCtrl.text = profile.alternatePhone ?? '';
    _dobCtrl.text = profile.dateOfBirth ?? '';
    _cityCtrl.text = profile.city ?? '';
    _stateCtrl.text = profile.state ?? '';
    _pincodeCtrl.text = profile.pincode ?? '';
    _languageCtrl.text = profile.language ?? '';

    final genderVal = profile.gender?.toString() ?? '';
    _gender = _genders.firstWhere(
      (g) => g.toLowerCase() == genderVal.toLowerCase(),
      orElse: () => 'Prefer not to say',
    );
    _initialized = true;
  }

  Future<void> _selectDob(BuildContext context) async {
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    if (_dobCtrl.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_dobCtrl.text);
      if (parsed != null) initialDate = parsed;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.surface,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final payload = {
      'name': _nameCtrl.text.trim(),
      'business_name': _nameCtrl.text.trim(),
      'alternate_phone': _alternatePhoneCtrl.text.trim().isEmpty ? null : _alternatePhoneCtrl.text.trim(),
      'gender': _gender == 'Prefer not to say' ? null : _gender,
      'date_of_birth': _dobCtrl.text.trim().isEmpty ? null : _dobCtrl.text.trim(),
      'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim().isEmpty ? null : _pincodeCtrl.text.trim(),
      'language': _languageCtrl.text.trim().isEmpty ? null : _languageCtrl.text.trim(),
    };

    try {
      await ref.read(profileNotifierProvider.notifier).save(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: profileAsync.when(
        loading: () => const ShimmerList(count: 4, itemHeight: 80),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (profile) {
          _initFields(profile);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionCard(
                  title: 'Personal Info',
                  children: [
                    _buildTextField(
                      controller: _nameCtrl,
                      label: 'Business / Personal Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _buildInputDecoration(
                        label: 'Gender',
                        icon: Icons.wc_outlined,
                      ),
                      dropdownColor: AppColors.surface,
                      items: _genders.map((g) {
                        return DropdownMenuItem(
                          value: g,
                          child: Text(
                            g,
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _gender = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dobCtrl,
                      readOnly: true,
                      decoration: _buildInputDecoration(
                        label: 'Date of Birth',
                        icon: Icons.cake_outlined,
                      ),
                      style: TextStyle(color: AppColors.textPrimary),
                      onTap: () => _selectDob(context),
                    ),
                  ],
                ),
                
                _buildSectionCard(
                  title: 'Location & Address',
                  children: [
                    _buildTextField(
                      controller: _cityCtrl,
                      label: 'City',
                      icon: Icons.location_city_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _stateCtrl,
                      label: 'State',
                      icon: Icons.map_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _pincodeCtrl,
                      label: 'Pincode',
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.trim().length != 6 || int.tryParse(value.trim()) == null) {
                            return 'Pincode must be a 6-digit number';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                _buildSectionCard(
                  title: 'Additional Contact & Language',
                  children: [
                    _buildTextField(
                      controller: _alternatePhoneCtrl,
                      label: 'Alternate Phone',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.trim().length != 10 || int.tryParse(value.trim()) == null) {
                            return 'Phone number must be a 10-digit number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _languageCtrl,
                      label: 'Preferred Language',
                      icon: Icons.translate_outlined,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Profile',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _buildInputDecoration(label: label, icon: icon),
      validator: validator,
      style: TextStyle(color: AppColors.textPrimary),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
