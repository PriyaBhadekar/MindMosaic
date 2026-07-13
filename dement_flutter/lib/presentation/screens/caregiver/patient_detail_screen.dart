import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/patient_provider.dart';
import '../../../data/models/game_model.dart';
import 'patient_add_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  State<PatientDetailScreen> createState() =>
      _PatientDetailScreenState();
}

class _PatientDetailScreenState
    extends State<PatientDetailScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PatientProvider>();

      if (provider.selected != null) {
        provider.loadPatientPerformance(
          provider.selected!.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PatientProvider>();
    final patient = prov.selected;

    if (patient == null) {
      return const Scaffold(
        body: Center(
          child: Text("No patient selected"),
        ),
      );
    }

    final imgUrl =
        patient.photoPath != null &&
                patient.photoPath!.isNotEmpty
            ? "http://10.0.2.2:8080/${patient.photoPath!.replaceAll("\\", "/")}"
            : null;

    final history = prov.gameHistory;
    final stats = prov.gameStats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,

            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),

            actions: [

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PatientAddScreen(
                        isEdit: true,
                      ),
                    ),
                  ).then((_) {
                    prov.fetchPatients();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(
                    right: 12,
                    top: 10,
                    bottom: 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient:
                      AppColors.caregiverGradient,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [

                    const SizedBox(height: 50),

                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                            .withOpacity(.2),
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(.4),
                          width: 2,
                        ),
                      ),
                      child: imgUrl != null
                          ? ClipOval(
                              child: Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        _initial(
                                  patient.name,
                                ),
                              ),
                            )
                          : _initial(patient.name),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      patient.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    if (patient.age != null)
                      Text(
                        "${patient.age} years old",
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(.8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  _InfoCard(
                    title: "Contact Information",
                    items: [

                      _InfoItem(
                        icon: Icons.phone,
                        label: "Phone",
                        value:
                            patient.phoneNumber ??
                                "Not Provided",
                        color: AppColors.primary,
                      ),

                      _InfoItem(
                        icon: Icons.emergency,
                        label: "Emergency",
                        value: patient
                                .emergencyContactNumber ??
                            "Not Provided",
                        color: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _InfoCard(
                    title: "Location",
                    items: [

                      _InfoItem(
                        icon: Icons.location_on,
                        label: "Address",
                        value:
                            patient.address ??
                                "Not Provided",
                        color: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _InfoCard(
                    title: "Account",
                    items: [

                      _InfoItem(
                        icon: Icons.link,
                        label: "Linked Code",
                        value: patient.linkedCode,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                                    _GamePerformanceCard(
                    history: history,
                    stats: stats,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "?",
        style: const TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
class _GamePerformanceCard extends StatelessWidget {
  final List<GameScoreModel> history;
  final Map<String, dynamic> stats;

  const _GamePerformanceCard({
    required this.history,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: const Column(
          children: [
            Icon(
              Icons.sports_esports_rounded,
              size: 52,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              "No game records available",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    double overall = 0;

    for (final game in history) {
      overall += game.percentageScore ?? 0;
    }

    overall /= history.length;

    final lastPlayed = history.first.playedAt ?? "-";

    String recommendation;

    if (overall >= 80) {
      recommendation =
          "Excellent cognitive performance. Continue regular memory exercises.";
    } else if (overall >= 60) {
      recommendation =
          "Moderate performance. Encourage daily cognitive games.";
    } else {
      recommendation =
          "Low performance detected. Increase memory training and monitor the patient's progress.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: AppColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                "Cognitive Game Performance",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                Text(
                  "${overall.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Overall Cognitive Score",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          ...history.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          g.gameType.replaceAll("_", " "),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      Text(
                        "${g.score}/${g.maxScore}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: (g.percentageScore ?? 0) / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      Text(
                        "${g.percentageScore?.toStringAsFixed(1) ?? "0"}%",
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          g.grade ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 36),

          Row(
            children: [

              const Icon(Icons.history_rounded),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  "Last Played\n$lastPlayed",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.orange,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(
                      fontSize: 14,
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
}class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...items.map((e) => _ItemRow(item: e)),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _ItemRow extends StatelessWidget {
  final _InfoItem item;

  const _ItemRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    if (item.label == "Linked Code")
                      InkWell(
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: item.value),
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Code copied"),
                              ),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.copy_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}