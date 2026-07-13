import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/navigation/navigation_service.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

import 'data/storage/local_storage.dart';

import 'providers/auth_provider.dart';
import 'providers/assessment_provider.dart';
import 'providers/emergency_provider.dart';
import 'providers/game_provider.dart';
import 'providers/geofence_provider.dart';
import 'providers/memory_provider.dart';
import 'providers/mri_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/song_provider.dart';
import 'providers/voice_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  runApp(const DementApp());
}

class DementApp extends StatelessWidget {
  const DementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PatientProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MemoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => EmergencyProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SongProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => VoiceProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GameProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MriProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AssessmentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GeofenceProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'MindMosaic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        navigatorKey: navigatorKey,
      ),
    );
  }
}