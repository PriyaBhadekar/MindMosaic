// REPLACE lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/role_selection_screen.dart';
import '../../presentation/screens/caregiver/caregiver_login_screen.dart';
import '../../presentation/screens/caregiver/caregiver_register_screen.dart';
import '../../presentation/screens/caregiver/caregiver_dashboard_screen.dart';
import '../../presentation/screens/caregiver/patient_management_screen.dart';
import '../../presentation/screens/caregiver/memories_screen.dart';
import '../../presentation/screens/caregiver/schedules_screen.dart';
import '../../presentation/screens/caregiver/songs_screen.dart';
import '../../presentation/screens/caregiver/emergency_contacts_screen.dart';
import '../../presentation/screens/caregiver/patient_detail_screen.dart';
import '../../presentation/screens/caregiver/patient_add_screen.dart';
import '../../presentation/screens/caregiver/alerts_screen.dart';
import '../../presentation/screens/caregiver/safe_zone_screen.dart';
import '../../presentation/screens/patient/patient_link_screen.dart';
import '../../presentation/screens/patient/patient_home_screen.dart';
import '../../presentation/screens/patient/patient_voice_screen.dart';
import '../../presentation/screens/patient/patient_music_screen.dart';
import '../../presentation/screens/patient/patient_memories_screen.dart';
import '../../presentation/screens/patient/patient_games_screen.dart';
import '../../presentation/screens/patient/games/memory_flashcard_game.dart';
import '../../presentation/screens/caregiver/caregiver_profile_screen.dart';
import '../../presentation/screens/caregiver/dementia_detection_screen.dart';
class AppRoutes {
  static const String splash = '/';
  static const String roleSelection = '/role-selection';
  static const String caregiverLogin = '/caregiver/login';
  static const String caregiverRegister = '/caregiver/register';
  static const String caregiverDashboard = '/caregiver/dashboard';
  static const String patients = '/caregiver/patients';
  static const String memories = '/caregiver/memories';
  static const String schedules = '/caregiver/schedules';
  static const String songs = '/caregiver/songs';
  static const String emergencyContacts = '/caregiver/emergency-contacts';
  static const String geofence = '/caregiver/geofence';
  static const String mri = '/caregiver/mri';
  static const String alerts = '/caregiver/alerts';
  static const String patientLink = '/patient/link';
  static const String patientHome = '/patient/home';
  static const String patientVoice = '/patient/voice';
  static const String patientMusic = '/patient/music';
  static const String patientMemories = '/patient/memories';
  static const String patientGames = '/patient/games';
  static const String memoryFlashcard = '/patient/games/memory-flashcard';
  static const String wordSearch = '/patient/games/word-search';
  static const caregiverProfile = '/caregiver-profile';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    roleSelection: (_) => const RoleSelectionScreen(),
    caregiverLogin: (_) => const CaregiverLoginScreen(),
    caregiverRegister: (_) => const CaregiverRegisterScreen(),
    caregiverDashboard: (_) => const CaregiverDashboardScreen(),
    patients: (_) => const PatientManagementScreen(),
    memories: (_) => const MemoriesScreen(),
    schedules: (_) => const SchedulesScreen(),
    songs: (_) => const SongsScreen(),
    emergencyContacts: (_) => const EmergencyContactsScreen(),
    geofence: (_) => const SafeZoneScreen(),
    alerts: (_) => const AlertsScreen(),
   mri: (_) => const DementiaDetectionScreen(),
    patientLink: (_) => const PatientLinkScreen(),
    patientHome: (_) => const PatientHomeScreen(),
    patientVoice: (_) => const PatientVoiceScreen(),
    patientMusic: (_) => const PatientMusicScreen(),
    patientMemories: (_) => const PatientMemoriesScreen(),
    patientGames: (_) => const PatientGamesScreen(),
    memoryFlashcard: (_) => const MemoryFlashcardGame(),
    wordSearch: (_) => const _StubScreen(title: 'Word Search', icon: Icons.search_rounded),
    caregiverProfile: (_) => const CaregiverProfileScreen(),
  };
}

class _StubScreen extends StatelessWidget {
  final String title;

  final IconData icon;
  const _StubScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Coming soon', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}