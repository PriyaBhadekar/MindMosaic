// REPLACE lib/presentation/screens/caregiver/caregiver_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/patient_provider.dart';
import '../../../providers/schedule_provider.dart';

import '../../widgets/common/animated_feature_card.dart';
import '../../widgets/common/dashboard_stat_card.dart';
import '../../../data/services/voice_service.dart';


class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen>
    with TickerProviderStateMixin {
  int _currentTab = 0;
  int _alertCount = 0;

  Future<void> _loadAlerts() async {

    try {

      final sosAlerts =
      await VoiceService.getSosAlerts();

      final distressLogs =
      await VoiceService.getDistressLogs();

      if (mounted) {
        setState(() {
          _alertCount =
              sosAlerts.length +
                  distressLogs.length;
        });
      }

    } catch (e) {

      print('ALERT LOAD ERROR: $e');

    }
  }

  late AnimationController _headerCtrl;
  late AnimationController _cardsCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _cardsSlide;
  late Animation<double> _cardsFade;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Home'),
    _NavItem(icon: Icons.people_rounded, label: 'Patients'),
    _NavItem(icon: Icons.notifications_rounded, label: 'Alerts'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<PatientProvider>().fetchPatients();
      await context.read<ScheduleProvider>().fetchSchedules();

      _loadAlerts();
    });

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut),
    );
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOutCubic),
    );
    _cardsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOut),
    );

    _headerCtrl.forward().then((_) => _cardsCtrl.forward());
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _cardsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.userName.isNotEmpty ? auth.userName : 'Caregiver';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context, auth, name),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium SliverAppBar ──────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            leading: Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: Container(
                  margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.alerts),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.caregiverGradient,
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      bottom: 10,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),

                    // Hero greeting
                    Positioned(
                      bottom: 28,
                      left: 24,
                      right: 24,
                      child: FadeTransition(
                        opacity: _headerFade,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.80),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Color(0xFF4ADE80),
                                    size: 8,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Active · All patients monitored',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Dashboard body ────────────────────────────────────
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _cardsSlide,
              child: FadeTransition(
                opacity: _cardsFade,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Stat row ─────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: DashboardStatCard(
                              label: 'Patients',
                              value: context
                      .watch<PatientProvider>()
                      .patients
                      .length
                      .toString(),
                              icon: Icons.people_rounded,
                              color: AppColors.primary,
                              trend: '+0',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.patients,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DashboardStatCard(
                              label: 'Schedules',
                              value: context
                                .watch<ScheduleProvider>()
                                .schedules
                                .length
                                .toString(),
                              icon: Icons.calendar_today_rounded,
                              color: AppColors.secondary,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.schedules,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DashboardStatCard(
                              label: 'Alerts',
                              value:  _alertCount.toString(),
                              icon: Icons.warning_amber_rounded,
                              color: AppColors.warning,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.alerts,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── SOS / emergency banner ────────────────
                      _SosBanner(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.alerts),
                      ),

                      const SizedBox(height: 28),

                      // ── Quick actions label ───────────────────
                      _SectionHeader(
                        title: 'Quick Actions',
                        subtitle: 'Tap a module to get started',
                        onMore: null,
                      ),
                      const SizedBox(height: 16),

                      // ── Feature cards grid ────────────────────
                      _FeatureGrid(context),

                      const SizedBox(height: 28),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Navigation ─────────────────────────────────────
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: _currentTab,
        items: _navItems,
        onTap: (i) {
          setState(() => _currentTab = i);
          switch (i) {
            case 1:
              Navigator.pushNamed(context, AppRoutes.patients);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.alerts);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.caregiverProfile);
              break;
          }
        },
      ),
    );
  }

  Widget _FeatureGrid(BuildContext context) {
    final modules = [
      _Module(
        'Patients',
        'Manage care',
        Icons.people_alt_rounded,
        AppColors.cardGradient1,
        AppRoutes.patients,
      ),
      _Module(
        'Memories',
        'Photos & stories',
        Icons.photo_library_rounded,
        AppColors.cardGradient2,
        AppRoutes.memories,
      ),
      _Module(
        'Schedules',
        'Daily reminders',
        Icons.calendar_month_rounded,
        AppColors.cardGradient4,
        AppRoutes.schedules,
      ),
      _Module(
        'Music',
        'Therapy sessions',
        Icons.music_note_rounded,
        AppColors.cardGradient3,
        AppRoutes.songs,
      ),
      _Module(
        'Contacts',
        'Emergency list',
        Icons.contact_emergency_rounded,
        LinearGradient(
          colors: [
            const Color(0xFF8B5CF6),
            const Color(0xFFA78BFA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppRoutes.emergencyContacts,
      ),
      _Module(
        'Safe Zone',
        'GPS geofence',
        Icons.location_on_rounded,
        LinearGradient(
          colors: [
            const Color(0xFF059669),
            const Color(0xFF34D399),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppRoutes.geofence,
      ),
      _Module(
        'MRI Scan',
        'AI detection',
        Icons.biotech_rounded,
        LinearGradient(
          colors: [
            const Color(0xFF0EA5E9),
            const Color(0xFF38BDF8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppRoutes.mri,
      ),
      _Module(
        'Alerts',
        'SOS history',
        Icons.notifications_active_rounded,
        AppColors.sosGradient,
        AppRoutes.alerts,
      ),
    ];

    final cardW = (MediaQuery.of(context).size.width - 40 - 12) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: modules
          .map(
            (m) => AnimatedFeatureCard(
          title: m.title,
          subtitle: m.subtitle,
          icon: m.icon,
          gradient: m.gradient,
          width: cardW,
          height: cardW * 0.85,
          onTap: () => Navigator.pushNamed(context, m.route),
        ),
      )
          .toList(),
    );
  }

  Widget _buildDrawer(
      BuildContext context,
      AuthProvider auth,
      String name,
      ) {
    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
            decoration: const BoxDecoration(
              gradient: AppColors.caregiverGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Caregiver · MindMosaic',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 8),
                if (auth.uniqueCode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Code: ${auth.uniqueCode}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Drawer items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                _DrawerItem(
                  icon: Icons.people_rounded,
                  label: 'Patients',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.patients);
                  },
                ),
                _DrawerItem(
                  icon: Icons.photo_library_rounded,
                  label: 'Memories',
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.memories);
                  },
                ),
                _DrawerItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Schedules',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.schedules);
                  },
                ),
                _DrawerItem(
                  icon: Icons.music_note_rounded,
                  label: 'Music Therapy',
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.songs);
                  },
                ),
                _DrawerItem(
                  icon: Icons.location_on_rounded,
                  label: 'Safe Zone',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.geofence);
                  },
                ),
                _DrawerItem(
                  icon: Icons.biotech_rounded,
                  label: 'MRI Detection',
                  color: const Color(0xFF0EA5E9),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.mri);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Divider(color: AppColors.borderLight),
                ),
                _DrawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign out',
                  color: AppColors.danger,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.roleSelection,
                            (r) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'MindMosaic v1.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 🌤';
    if (h < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }
}

// ── Supporting data class ──────────────────────────────────────────────
class _Module {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final String route;
  const _Module(this.title, this.subtitle, this.icon, this.gradient, this.route);
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ── Private widgets ────────────────────────────────────────────────────

class _SosBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _SosBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.sosGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.primaryShadow(AppColors.danger),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.emergency_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Monitoring',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'All systems active · Tap to view alerts',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}



class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onMore;
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (onMore != null)
          TextButton(
            onPressed: onMore,
            child: const Text('See all'),
          ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.textHint,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  const _PremiumBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withOpacity(0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textHint,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}