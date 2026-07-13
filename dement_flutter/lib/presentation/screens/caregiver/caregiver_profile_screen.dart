import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/routes/app_routes.dart';

class CaregiverProfileScreen extends StatelessWidget {
  const CaregiverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<AuthProvider>(

        builder: (_, auth, __) {

          return SingleChildScrollView(

            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [

                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),

                  child: Text(
                    auth.userName.isNotEmpty
                        ? auth.userName[0].toUpperCase()
                        : 'C',

                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  auth.userName,

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  auth.email,

                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 30),

                _ProfileTile(
                  icon: Icons.phone_rounded,
                  title: 'Phone',
                  value: auth.phoneNumber ?? 'Not provided',
                ),

                const SizedBox(height: 14),

                _ProfileTile(
                  icon: Icons.email_rounded,
                  title: 'Email',
                  value: auth.email.isNotEmpty
                      ? auth.email
                      : 'Not provided',
                ),

                const SizedBox(height: 14),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(

                    onPressed: () async {

                      await auth.logout();

                      if (context.mounted) {

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.roleSelection,
                              (route) => false,
                        );
                      }
                    },

                    icon: const Icon(Icons.logout_rounded),

                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {

  final IconData icon;
  final String title;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),

      child: Row(
        children: [

          Icon(icon, color: AppColors.primary),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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