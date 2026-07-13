// CREATE lib/presentation/screens/caregiver/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/voice_service.dart';
import 'dart:async';
import '../../../data/services/geofence_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<dynamic> _sosAlerts = [];
  List<dynamic> _distressLogs = [];
  List<dynamic> _geofenceAlerts = [];
  bool _loading = true;


  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
    // Auto-refresh every 15 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _load());
  }

  @override
  void dispose() {
    _tab.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }


  Future<void> _load() async {
    try {
      final sos = await VoiceService.getSosAlerts();
      final distress = await VoiceService.getDistressLogs();
      final geofence =
      await GeofenceService.getAlerts();

      print(geofence);

      if (mounted) setState(() {
        _sosAlerts = sos;
        _distressLogs = distress;
        _geofenceAlerts = geofence;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resolve(int alertId) async {
    try {
      await VoiceService.resolveSosAlert(alertId);
      await _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final unresolved = _sosAlerts.where((a) => a['resolved'] == false).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
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
                  gradient: AppColors.sosGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24,0,24,60),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(children: [
                        const Text('Patient Alerts', style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.4,
                        )),
                        if (unresolved > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('$unresolved new', style: const TextStyle(
                              fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w800,
                            )),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('SOS & distress monitoring',
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'SOS Alerts (${_sosAlerts.length})'),
                Tab(text: 'Distress (${_distressLogs.length})'),
                Tab(
                  text:
                  'Location (${_geofenceAlerts.length})',
                ),
              ],
            ),
          ),

          SliverFillRemaining(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.danger))
                : TabBarView(
              controller: _tab,
              children: [
                _SosAlertList(alerts: _sosAlerts, onResolve: _resolve),
                _DistressList(logs: _distressLogs),
                _GeofenceAlertList(
                  alerts: _geofenceAlerts,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SosAlertList extends StatelessWidget {
  final List<dynamic> alerts;
  final Future<void> Function(int) onResolve;
  const _SosAlertList({required this.alerts, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return _EmptyState(
      icon: Icons.notifications_none_rounded,
      message: 'No SOS alerts yet.\nAll patients are safe.',
    );

    return RefreshIndicator(
      color: AppColors.danger,
      onRefresh: () async {},
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final a = alerts[i];
          final resolved = a['resolved'] == true;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.cardShadow,
              border: resolved ? null : Border.all(color: AppColors.danger.withOpacity(0.3)),
            ),
            child: Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: (resolved ? AppColors.success : AppColors.danger).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  resolved ? Icons.check_circle_rounded : Icons.sos_rounded,
                  color: resolved ? AppColors.success : AppColors.danger,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a['patientName'] ?? 'Patient', style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                const SizedBox(height: 3),
                Text(a['alertMessage'] ?? a['alertType'] ?? 'SOS Alert',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(_formatDt(a['triggeredAt']), style: const TextStyle(
                  fontSize: 11, color: AppColors.textHint,
                )),
              ])),
              if (!resolved)
                GestureDetector(
                  onTap: () => onResolve(a['id']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Resolve', style: TextStyle(
                      fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w700,
                    )),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Resolved', style: TextStyle(
                    fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600,
                  )),
                ),
            ]),
          );
        },
      ),
    );
  }

  String _formatDt(dynamic dt) {
    if (dt == null) return '';
    final s = dt.toString();
    if (s.length >= 16) return s.substring(0, 16).replaceAll('T', ' ');
    return s;
  }
}

class _DistressList extends StatelessWidget {
  final List<dynamic> logs;
  const _DistressList({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return _EmptyState(
      icon: Icons.sentiment_satisfied_rounded,
      message: 'No distress signals detected.\nPatient is communicating well.',
    );

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final l = logs[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l['patientName'] ?? 'Patient', style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                Text('Keyword: "${l['distressKeyword'] ?? 'unknown'}"',
                    style: const TextStyle(fontSize: 12, color: AppColors.warning,
                        fontWeight: FontWeight.w600)),
              ]),
              const Spacer(),
              Text(_formatDt(l['loggedAt']), style: const TextStyle(
                fontSize: 11, color: AppColors.textHint,
              )),
            ]),
            if (l['patientResponse'] != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('"${l['patientResponse']}"', style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic, height: 1.4,
                )),
              ),
            ],
          ]),
        );
      },
    );
  }

  String _formatDt(dynamic dt) {
    if (dt == null) return '';
    final s = dt.toString();
    if (s.length >= 16) return s.substring(0, 16).replaceAll('T', ' ');
    return s;
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 64, color: AppColors.textHint),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
      ]),
    ),
  );
}

class _GeofenceAlertList extends StatelessWidget {

  final List<dynamic> alerts;

  const _GeofenceAlertList({
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {

    if (alerts.isEmpty) {
      return const Center(
        child: Text(
          'No location alerts',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {

        final alert = alerts[index];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          child: ListTile(

            leading: const Icon(
              Icons.location_off,
              color: Colors.red,
            ),

            title: Text(
              alert['patientName'] ??
                  alert['patient']?['name'] ??
                  'Unknown Patient',
            ),

            subtitle: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  'Distance: ${alert['distanceFromZone']} m',
                ),

                Text(
                  alert['lastLocationUpdate']
                      ?.toString() ??
                      alert['triggeredAt']
                          ?.toString() ??
                      '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}