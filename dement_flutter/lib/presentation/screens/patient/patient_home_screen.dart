// REPLACE lib/presentation/screens/patient/patient_home_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/geofence_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/services/schedule_service.dart';
import '../../../data/storage/local_storage.dart';
import '../../../data/services/voice_service.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/api_client.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late AnimationController _cardsCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _cardsSlide;
  late Animation<double> _cardsFade;

  Timer? _locationTimer;

  List<ScheduleModel> _todaySchedules = [];
  bool _schedulesLoading = true;

  String get _patientName => LocalStorage.getUserName() ?? 'Friend';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _cardsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _cardsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOutCubic));
    _cardsFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOut));
    _headerCtrl.forward().then((_) => _cardsCtrl.forward());

    _loadSchedules();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<GeofenceProvider>()
          .checkCurrentLocation();
    });

    _locationTimer = Timer.periodic(
      const Duration(minutes: 2),
          (_) {
        context.read<GeofenceProvider>()
            .checkCurrentLocation();
      },
    );
  }

  // In patient_home_screen.dart, REPLACE _loadSchedules:
  Future<void> _loadSchedules() async {
    try {
      final patientId = LocalStorage.getPatientId();
      if (patientId == null) {
        setState(() => _schedulesLoading = false);
        return;
      }
      final response = await ApiClient.get('/api/schedules/patient/$patientId');
      final List raw = response['data'] ?? [];
      final schedules = raw.map((e) => ScheduleModel.fromJson(e)).toList();
      if (mounted) setState(() {
        _todaySchedules = schedules;
        _schedulesLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _schedulesLoading = false);
    }
  }



// ADD import at top of patient_home_screen.dart:


  @override
  void dispose() {
    _locationTimer?.cancel();
    _headerCtrl.dispose();
    _cardsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero header card ──────────────────────────────────────
            FadeTransition(
              opacity: _headerFade,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 52, 16, 0),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.patientGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.primaryShadow(AppColors.secondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_greeting(now.hour), style: TextStyle(
                                fontSize: 14, color: Colors.white.withOpacity(0.80),
                              )),
                              const SizedBox(height: 2),
                              Text(_patientName, style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: -0.3,
                              )),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await LocalStorage.clearAll();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, AppRoutes.roleSelection, (r) => false);
                            }
                          },
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text('${_formatDate(now)}   ${_formatTime(now)}',
                              style: const TextStyle(fontSize: 15,
                                  fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SlideTransition(
              position: _cardsSlide,
              child: FadeTransition(
                opacity: _cardsFade,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── TOP ROW: Voice Assistant + SOS (primary actions) ──
                      Row(
                        children: [
                          // VOICE ASSISTANT — primary, larger
                          Expanded(
                            flex: 3,
                            child: _VoiceOrbButton(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.patientVoice),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // SOS — secondary
                          Expanded(
                            flex: 2,
                            child: _SosQuickButton(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const _SectionLabel("Today's Schedule"),
                      const SizedBox(height: 12),

                      // ── Real schedules from backend ───────────────────────
                      if (_schedulesLoading)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ))
                      else if (_todaySchedules.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, color: AppColors.textHint),
                              SizedBox(width: 12),
                              Text('No schedules for today',
                                  style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      else
                        ...(_todaySchedules.take(5).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ScheduleCard(schedule: s),
                        ))),

                      const SizedBox(height: 24),
                      const _SectionLabel('Quick Access'),
                      const SizedBox(height: 14),

                      // ── 2×2 grid: Memories, Music, Brain Games ────────────
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.15,
                        children: [
                          _ActionCard(
                            label: 'My Memories',
                            icon: Icons.photo_library_rounded,
                            gradient: AppColors.cardGradient2,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.patientMemories),
                          ),
                          _ActionCard(
                            label: 'Music',
                            icon: Icons.music_note_rounded,
                            gradient: AppColors.cardGradient3,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.patientMusic),
                          ),
                          _ActionCard(
                            label: 'Brain Games',
                            icon: Icons.sports_esports_rounded,
                            gradient: AppColors.cardGradient1,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.patientGames),
                          ),
                          _ActionCard(
                            label: 'Voice Helper',
                            icon: Icons.mic_rounded,
                            gradient: AppColors.caregiverGradient,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.patientVoice),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const _SectionLabel('Your Caregiver'),
                      const SizedBox(height: 12),
                      _CaregiverCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting(int h) {
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤';
    return 'Good evening 🌙';
  }

  String _formatDate(DateTime dt) {
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final display = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$display:$m $suffix';
  }
}

// ── Large voice orb button at top ─────────────────────────────────────
class _VoiceOrbButton extends StatefulWidget {
  final VoidCallback onTap;
  const _VoiceOrbButton({required this.onTap});

  @override
  State<_VoiceOrbButton> createState() => _VoiceOrbButtonState();
}

class _VoiceOrbButtonState extends State<_VoiceOrbButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: AppColors.caregiverGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.primaryShadow(AppColors.primary),
          ),
          child: Stack(
            children: [
              Positioned(right: -10, top: -10, child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.10),
                ),
              )),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_rounded, color: Colors.white, size: 40),
                    SizedBox(height: 8),
                    Text('Voice\nAssistant', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: Colors.white, height: 1.2)),
                    SizedBox(height: 4),
                    Text('Tap to speak', style: TextStyle(
                        fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SOS quick button ──────────────────────────────────────────────────
class _SosQuickButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSosDialog(context),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: AppColors.sosGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.primaryShadow(AppColors.danger),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sos_rounded, color: Colors.white, size: 44),
              SizedBox(height: 8),
              Text('SOS', style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1)),
              SizedBox(height: 2),
              Text('Tap for help', style: TextStyle(
                  fontSize: 11, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSosDialog(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.sosGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.primaryShadow(AppColors.danger),
                ),
                child: const Icon(
                    Icons.sos_rounded, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('Send SOS Alert?', style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              )),
              const SizedBox(height: 10),
              const Text('Your caregiver will be notified immediately.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.sosGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      HapticFeedback.heavyImpact();
                      try {
                        final patientId = LocalStorage.getPatientId();
                        if (patientId != null) {
                          await VoiceService.triggerSos(patientId: patientId);
                        }
                      } catch (_) {}
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Row(children: [
                            Icon(
                                Icons.check_circle_rounded, color: Colors.white,
                                size: 18),
                            SizedBox(width: 10),
                            Expanded(child: Text(
                                'SOS sent! Your caregiver has been notified.')),
                          ]),
                          backgroundColor: AppColors.danger,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ));
                      }
                    },
                    style: TextButton.styleFrom(shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                    child: const Text('YES, SEND ALERT', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 0.5,
                    )),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                    'Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ]),
          ),
    );
  }
}
// ── Schedule card — real data ─────────────────────────────────────────
class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(schedule.title);
    final icon = _iconFor(schedule.title);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(schedule.title, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
            )),
            if (schedule.voiceDescription != null && schedule.voiceDescription!.isNotEmpty)
              Text(schedule.voiceDescription!, style: const TextStyle(
                fontSize: 12, color: AppColors.textHint,
              ), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_formatTime(schedule.scheduledTime), style: TextStyle(
            fontSize: 12, color: color, fontWeight: FontWeight.w700,
          )),
        ),
      ]),
    );
  }

  Color _colorFor(String t) {
    final l = t.toLowerCase();
    if (l.contains('medicine') || l.contains('tablet')) return AppColors.primary;
    if (l.contains('breakfast') || l.contains('lunch') || l.contains('dinner')) return AppColors.success;
    if (l.contains('sleep') || l.contains('bed')) return const Color(0xFF8B5CF6);
    if (l.contains('walk') || l.contains('exercise')) return AppColors.secondary;
    if (l.contains('call')) return AppColors.accent;
    return AppColors.primary;
  }

  IconData _iconFor(String t) {
    final l = t.toLowerCase();
    if (l.contains('medicine') || l.contains('tablet') || l.contains('pill')) return Icons.medication_rounded;
    if (l.contains('breakfast')) return Icons.free_breakfast_rounded;
    if (l.contains('lunch') || l.contains('dinner') || l.contains('meal')) return Icons.restaurant_rounded;
    if (l.contains('sleep') || l.contains('bed') || l.contains('rest')) return Icons.bedtime_rounded;
    if (l.contains('walk') || l.contains('exercise')) return Icons.directions_walk_rounded;
    if (l.contains('call') || l.contains('phone')) return Icons.call_rounded;
    if (l.contains('bath') || l.contains('hygiene')) return Icons.shower_rounded;
    return Icons.alarm_rounded;
  }

  String _formatTime(String time) {
    try {
      final p = time.split(':');
      int h = int.parse(p[0]);
      final m = p[1].padLeft(2, '0');
      final suffix = h >= 12 ? 'PM' : 'AM';
      h = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$h:$m $suffix';
    } catch (_) { return time; }
  }
}

// ── Action card ───────────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _ActionCard({required this.label, required this.icon,
    required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.primaryShadow(gradient.colors.first),
        ),
        child: Stack(children: [
          Positioned(right: -10, bottom: -10, child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Text(label, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _CaregiverCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: const Row(children: [
        CircleAvatar(radius: 24, backgroundColor: AppColors.primary,
            child: Icon(Icons.medical_services_rounded, color: Colors.white, size: 22)),
        SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your Caregiver', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
          )),
          Text('Is monitoring your health and safety',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ])),
        Icon(Icons.verified_rounded, color: AppColors.success, size: 22),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.2,
  ));
}