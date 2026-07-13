// CREATE lib/presentation/screens/caregiver/patient_add_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/patient_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/soft_text_field.dart';

class PatientAddScreen extends StatefulWidget {
  final bool isEdit;
  const PatientAddScreen({super.key, this.isEdit = false});

  @override
  State<PatientAddScreen> createState() => _PatientAddScreenState();
}

class _PatientAddScreenState extends State<PatientAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      final p = context.read<PatientProvider>().selected;
      if (p != null) {
        _nameCtrl.text = p.name;
        _ageCtrl.text = p.age?.toString() ?? '';
        _addressCtrl.text = p.address ?? '';
        _phoneCtrl.text = p.phoneNumber ?? '';
        _emergencyCtrl.text = p.emergencyContactNumber ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 800,
    );
    if (img != null) setState(() => _pickedImage = File(img.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final prov = context.read<PatientProvider>();

    if (widget.isEdit) {
      final p = prov.selected;
      if (p == null) return;

      final ok = await prov.updatePatient(p.id, {
        'name': _nameCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text),
        'address': _addressCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'emergencyContactNumber': _emergencyCtrl.text.trim(),
      });

      if (ok && _pickedImage != null) {
        await prov.uploadPhoto(p.id, _pickedImage!);
      }

      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
        _snack('Patient updated successfully');
      } else {
        _snack(prov.error ?? 'Update failed', isError: true);
      }
    } else {
      final ok = await prov.addPatient(
        name: _nameCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text),
        address: _addressCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        emergencyContactNumber: _emergencyCtrl.text.trim(),
      );

      if (!mounted) return;
      if (ok) {
        // Upload photo if picked
        final added = prov.patients.last;
        if (_pickedImage != null) {
          await prov.uploadPhoto(added.id, _pickedImage!);
        }
        Navigator.pop(context);
        _snack('Patient added successfully');
      } else {
        _snack(prov.error ?? 'Failed to add patient', isError: true);
      }
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PatientProvider>();
    final title = widget.isEdit ? 'Edit Patient' : 'Add Patient';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.surface,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Photo picker ───────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.softShadow,
                      ),
                      child: _pickedImage != null
                          ? ClipOval(
                        child: Image.file(
                          _pickedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.background, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap to add photo',
                style: TextStyle(fontSize: 13, color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 28),

            // ── Fields ────────────────────────────────────
            _SectionLabel('Basic Information'),
            const SizedBox(height: 12),
            SoftTextField(
              hint: "Patient's full name",
              label: 'Full name',
              controller: _nameCtrl,
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) =>
              (v == null || v.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            SoftTextField(
              hint: 'e.g. 72',
              label: 'Age',
              controller: _ageCtrl,
              prefixIcon: Icons.cake_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            SoftTextField(
              hint: 'Home or care facility address',
              label: 'Address',
              controller: _addressCtrl,
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            _SectionLabel('Contact Details'),
            const SizedBox(height: 12),
            SoftTextField(
              hint: "Patient's phone number",
              label: 'Phone number',
              controller: _phoneCtrl,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            SoftTextField(
              hint: 'Emergency contact number',
              label: 'Emergency contact',
              controller: _emergencyCtrl,
              prefixIcon: Icons.emergency_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            GradientButton(
              text: widget.isEdit ? 'Save Changes' : 'Add Patient',
              onTap: prov.isLoading ? null : _submit,
              isLoading: prov.isLoading,
              gradient: AppColors.caregiverGradient,
              height: 56,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}