// REPLACE lib/presentation/screens/patient/patient_link_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/storage/local_storage.dart';
import '../../../data/services/patient_service.dart';
import '../../../data/services/auth_service.dart';

class PatientLinkScreen extends StatefulWidget {
  const PatientLinkScreen({super.key});

  @override
  State<PatientLinkScreen> createState() => _PatientLinkScreenState();
}

class _PatientLinkScreenState extends State<PatientLinkScreen>
    with SingleTickerProviderStateMixin {
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  late AnimationController _entryCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter the caregiver code');
      return;
    }
    setState(() { _isLoading = true; _error = null; });

    try {
      final patient = await AuthService.linkPatient(patientCode: code);

      await LocalStorage.savePatientId(patient.id);
      await LocalStorage.saveUserName(patient.name);
      await LocalStorage.saveRole('PATIENT');
      await LocalStorage.saveToken('patient_${patient.id}');

      // CRITICAL: store caregiverId so flashcard game can load
      if (patient.caregiverId != null) {
        await LocalStorage.saveCaregiverId(patient.caregiverId!);
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.patientHome, (r) => false);
    } catch (e) {
      setState(() {
        _error = e.toString().contains('404') || e.toString().contains('Invalid')
            ? 'Invalid code. Please check with your caregiver.'
            : 'Cannot reach server. Check backend is running.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.patientGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hero
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.link_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Connect to\nyour caregiver',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter the unique code your caregiver shared',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.80),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form card
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Caregiver Code',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Ask your caregiver for their unique code',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Code input — large, elder-friendly
                              TextField(
                                controller: _codeCtrl,
                                textCapitalization:
                                TextCapitalization.characters,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 6,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'PAT-XXXXXXXX',
                                  hintStyle: const TextStyle(
                                    fontSize: 22,
                                    letterSpacing: 4,
                                    color: AppColors.textHint,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                        color: AppColors.borderLight,
                                        width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                        color: AppColors.secondary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 22),
                                  errorText: _error,
                                ),
                                onChanged: (_) {
                                  if (_error != null) {
                                    setState(() => _error = null);
                                  }
                                },
                                onSubmitted: (_) => _link(),
                              ),
                              const SizedBox(height: 32),

                              // Link button
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.patientGradient,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: AppColors.primaryShadow(
                                        AppColors.secondary),
                                  ),
                                  child: TextButton(
                                    onPressed: _isLoading ? null : _link,
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white),
                                    )
                                        : const Text(
                                      'Link to Caregiver',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Info card
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: AppColors.secondary
                                          .withOpacity(0.20)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        color: AppColors.secondary, size: 22),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Your caregiver can find their unique code on the dashboard under "Your unique code".',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}