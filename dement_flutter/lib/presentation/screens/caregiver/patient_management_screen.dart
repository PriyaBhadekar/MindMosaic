import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../../providers/patient_provider.dart';
import '../../widgets/common/gradient_button.dart';
import 'patient_add_screen.dart';
import 'patient_detail_screen.dart';
import 'package:flutter/services.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  State<PatientManagementScreen> createState() =>
      _PatientManagementScreenState();
}

class _PatientManagementScreenState
    extends State<PatientManagementScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatients();
    });
  }

  @override
  Widget build(BuildContext context) {

    final prov = context.watch<PatientProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),

        slivers: [

          /// HEADER
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.transparent,

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,

              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.caregiverGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),

                child: const Align(
                  alignment: Alignment.bottomLeft,

                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 24),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(
                          'My Patients',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Manage and monitor your patients',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            leading: GestureDetector(
              onTap: () => Navigator.pop(context),

              child: Container(
                margin: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),

          /// CONTENT
          SliverPadding(
            padding: const EdgeInsets.all(20),

            sliver: prov.isLoading

                ? const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),

                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            )

                : prov.error != null

                ? SliverToBoxAdapter(
              child: _ErrorState(
                message: prov.error!,
                onRetry: () => prov.fetchPatients(),
              ),
            )

                : prov.patients.isEmpty

                ? SliverToBoxAdapter(
              child: _EmptyState(
                onAdd: () => _openAdd(context),
              ),
            )

                : SliverList(

              delegate: SliverChildBuilderDelegate(

                    (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),

                  child: _PatientCard(
                    patient: prov.patients[i],

                    onTap: () {

                      prov.selectPatient(prov.patients[i]);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const PatientDetailScreen(),
                        ),
                      );
                    },
                  ),
                ),

                childCount: prov.patients.length,
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(

        onPressed: () => _openAdd(context),

        backgroundColor: AppColors.primary,

        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),

        label: const Text(
          'Add Patient',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        elevation: 4,
      ),
    );
  }

  void _openAdd(BuildContext context) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientAddScreen(),
      ),
    ).then(
          (_) => context.read<PatientProvider>().fetchPatients(),
    );
  }
}

class _PatientCard extends StatelessWidget {

  final PatientModel patient;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),

        child: Row(

          children: [

            /// AVATAR
            Container(
              width: 60,
              height: 60,

              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),

              child: patient.photoPath != null &&
                  patient.photoPath!.isNotEmpty

                  ? ClipRRect(
                borderRadius: BorderRadius.circular(18),

                child: Image.network(
                  _buildImageUrl(patient.photoPath!),
                  fit: BoxFit.cover,

                  errorBuilder: (_, __, ___) =>
                      _DefaultAvatar(name: patient.name),
                ),
              )

                  : _DefaultAvatar(name: patient.name),
            ),

            const SizedBox(width: 16),

            /// INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    patient.name,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [

                      if (patient.age != null) ...[

                        _Tag(
                          label: '${patient.age} yrs',
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 8),
                      ],

                      if (patient.phoneNumber != null &&
                          patient.phoneNumber!.isNotEmpty)

                        _Tag(
                          label: patient.phoneNumber!,
                          color: AppColors.secondary,
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          'Code: ${patient.linkedCode ?? ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () async {

                          await Clipboard.setData(
                            ClipboardData(
                              text: patient.linkedCode ?? '',
                            ),
                          );

                          if (context.mounted) {

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Patient code copied'),
                              ),
                            );
                          }
                        },

                        borderRadius: BorderRadius.circular(8),

                        child: Container(
                          padding: const EdgeInsets.all(6),

                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: const Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (patient.address != null &&
                      patient.address!.isNotEmpty) ...[

                    const SizedBox(height: 4),

                    Text(
                      patient.address!,

                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  String _buildImageUrl(String path) {

    final clean = path.replaceAll('\\', '/');

    return 'http://localhost:8080/$clean';
  }
}

class _DefaultAvatar extends StatelessWidget {

  final String name;

  const _DefaultAvatar({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Text(

        name.isNotEmpty
            ? name[0].toUpperCase()
            : '?',

        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {

  final String label;
  final Color color;

  const _Tag({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),

      child: Text(
        label,

        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {

  final VoidCallback onAdd;

  const _EmptyState({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        const SizedBox(height: 60),

        Container(
          width: 90,
          height: 90,

          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),

          child: const Icon(
            Icons.people_outline_rounded,
            size: 44,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'No patients yet',

          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Add your first patient to get started',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 32),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),

          child: GradientButton(
            text: 'Add Patient',
            onTap: onAdd,
            gradient: AppColors.primaryGradient,
            height: 52,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {

  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        const SizedBox(height: 60),

        const Icon(
          Icons.wifi_off_rounded,
          size: 48,
          color: AppColors.textHint,
        ),

        const SizedBox(height: 16),

        Text(
          message,
          textAlign: TextAlign.center,

          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 20),

        TextButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}