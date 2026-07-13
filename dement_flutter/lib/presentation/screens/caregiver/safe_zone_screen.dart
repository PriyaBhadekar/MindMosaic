// CREATE lib/presentation/screens/caregiver/safe_zone_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/geofence_service.dart';
import '../../../data/storage/local_storage.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/soft_text_field.dart';

class SafeZoneScreen extends StatefulWidget {
  const SafeZoneScreen({super.key});

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  double _radius = 200;
  bool _isLoading = false;
  Map<String, dynamic>? _existing;
  bool _loadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    try {
      final g = await GeofenceService.getGeofence();
      setState(() {
        _latCtrl.text = g.latitude.toString();
        _lngCtrl.text = g.longitude.toString();
        _addressCtrl.text = g.address ?? '';
        _radius = g.radius;
        _loadingExisting = false;
      });
    } catch (_) {
      setState(() => _loadingExisting = false);
    }
  }

  Future<void> _save() async {
    final lat = double.tryParse(_latCtrl.text);
    final lng = double.tryParse(_lngCtrl.text);
    if (lat == null || lng == null) {
      _snack('Please enter valid coordinates', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await GeofenceService.setGeofence(
        latitude: lat,
        longitude: lng,
        radius: _radius,
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      );
      _snack('Safe zone saved successfully');
    } catch (e) {
      _snack('Failed to save: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Safe Zone', style: TextStyle(fontSize: 26,
                              fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
                          SizedBox(height: 4),
                          Text('Define patient\'s safe area',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ]),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _loadingExisting
                ? const Center(child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: CircularProgressIndicator(color: AppColors.success)))
                : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success.withOpacity(0.20)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.success, size: 20),
                    SizedBox(width: 10),
                    Expanded(child: Text(
                      'Set the centre of the safe zone and radius. '
                          'If your patient moves outside this area, you will receive an alert.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    )),
                  ]),
                ),
                const SizedBox(height: 24),

                const _Label('Zone Centre — Coordinates'),
                const SizedBox(height: 12),
                SoftTextField(
                  hint: 'e.g. 18.5204',
                  label: 'Latitude',
                  controller: _latCtrl,
                  prefixIcon: Icons.my_location_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 14),
                SoftTextField(
                  hint: 'e.g. 73.8567',
                  label: 'Longitude',
                  controller: _lngCtrl,
                  prefixIcon: Icons.location_on_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 14),
                SoftTextField(
                  hint: 'e.g. Home, Nigdi Pune',
                  label: 'Address (optional)',
                  controller: _addressCtrl,
                  prefixIcon: Icons.home_rounded,
                ),
                const SizedBox(height: 24),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const _Label('Radius'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${_radius.round()} m', style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14,
                    )),
                  ),
                ]),
                Slider(
                  value: _radius,
                  min: 50,
                  max: 2000,
                  divisions: 39,
                  activeColor: AppColors.success,
                  inactiveColor: AppColors.borderLight,
                  onChanged: (v) => setState(() => _radius = v),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('50 m', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                  const Text('2000 m', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                ]),
                const SizedBox(height: 32),

                GradientButton(
                  text: 'Save Safe Zone',
                  onTap: _isLoading ? null : _save,
                  isLoading: _isLoading,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  height: 56,
                ),

                const SizedBox(height: 20),

                // Check patient location section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Check Patient Location', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    )),
                    const SizedBox(height: 6),
                    const Text(
                      'Patient\'s device will automatically report location. '
                          'A geofence breach will trigger an emergency alert.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(children: [
                        Icon(Icons.circle, color: AppColors.success, size: 8),
                        SizedBox(width: 8),
                        Text('Location monitoring active', style: TextStyle(
                          fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w600,
                        )),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.3,
  ));
}